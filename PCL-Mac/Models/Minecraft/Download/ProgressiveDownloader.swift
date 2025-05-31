//
//  ProgressiveDownloader.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/31.
//

import Foundation

public final class ProgressiveDownloader: NSObject, URLSessionDownloadDelegate {
    public let urls: [URL]
    public let destinations: [URL]
    public let concurrentLimit: Int
    public let skipIfExists: Bool
    public let progressCallback: ((Int, Int, Double, Double) -> Void)?
    public let completion: (() -> Void)?
    public var finishedCount = 0
    public var totalCount: Int { urls.count }
    public var session: URLSession!
    public var startTime: Date?
    public var fileSizeMap: [Int: Int64] = [:]
    public var bytesMap: [Int: Int64] = [:]
    public let lock = NSLock()
    public var nextIndex: Int = 0

    public init(urls: [URL], destinations: [URL], concurrentLimit: Int = 4, skipIfExists: Bool = false,
                progress: ((Int, Int, Double, Double) -> Void)? = nil,
                completion: (() -> Void)? = nil) {
        self.urls = urls
        self.destinations = destinations
        self.concurrentLimit = concurrentLimit
        self.skipIfExists = skipIfExists
        self.progressCallback = progress
        self.completion = completion
        super.init()
        let config = URLSessionConfiguration.default
        config.httpMaximumConnectionsPerHost = concurrentLimit
        session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())
    }

    public func start() {
        startTime = Date()
        lock.lock()
        nextIndex = 0
        lock.unlock()
        for _ in 0..<min(concurrentLimit, urls.count) {
            startNextTask()
        }
    }

    public func startNextTask() {
        while true {
            lock.lock()
            let index = nextIndex
            nextIndex += 1
            lock.unlock()
            guard index < urls.count else { return }
            let dest = destinations[index]
            if skipIfExists && FileManager.default.fileExists(atPath: dest.path) {
                lock.lock()
                finishedCount += 1
                lock.unlock()
                updateProgress()
                if finishedCount == urls.count {
                    session.invalidateAndCancel()
                    DispatchQueue.main.async {
                        self.completion?()
                    }
                }
                continue
            }
            let request = URLRequest(url: urls[index])
            let task = session.downloadTask(with: request)
            task.taskDescription = "\(index)"
            task.resume()
            break
        }
    }

    // 只统计已知大小的文件
    private func computeProgress() -> (progress: Double, downloaded: Int64, expected: Int64, speed: Double) {
        let expected = fileSizeMap.values.filter { $0 > 0 }.reduce(0, +)
        let downloaded = bytesMap.reduce(0) { sum, pair in
            let (i, v) = pair
            return (fileSizeMap[i] ?? 0) > 0 ? sum + Int(v) : sum
        }
        let elapsed = Date().timeIntervalSince(startTime ?? Date())
        let speed = elapsed > 0 ? Double(downloaded) / elapsed : 0
        let progress = (expected > 0) ? min(1.0, Double(downloaded) / Double(expected)) : 0
        return (progress, Int64(downloaded), expected, speed)
    }

    private func updateProgress() {
        let (progress, _, _, speed) = computeProgress()
        DispatchQueue.main.async {
            self.progressCallback?(self.finishedCount, self.totalCount, progress, speed)
            DataManager.shared.downloadSpeed = speed
            DataManager.shared.currentStagePercentage = progress
        }
    }

    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                           didWriteData bytesWritten: Int64,
                           totalBytesWritten: Int64,
                           totalBytesExpectedToWrite: Int64) {
        guard let strIndex = downloadTask.taskDescription, let index = Int(strIndex) else { return }
        lock.lock()
        bytesMap[index] = totalBytesWritten
        // 只在首次且 totalBytesExpectedToWrite > 0 时写入 fileSizeMap，之后只允许变大不允许变小
        if totalBytesExpectedToWrite > 0 {
            if let old = fileSizeMap[index] {
                if totalBytesExpectedToWrite > old {
                    fileSizeMap[index] = totalBytesExpectedToWrite
                }
            } else {
                fileSizeMap[index] = totalBytesExpectedToWrite
            }
        }
        lock.unlock()
        updateProgress()
    }

    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let strIndex = downloadTask.taskDescription, let index = Int(strIndex) else { return }
        let dest = destinations[index]
        var fileSize: Int64 = 0
        do {
            let dir = dest.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
            if FileManager.default.fileExists(atPath: dest.path) {
                try FileManager.default.removeItem(at: dest)
            }
            try FileManager.default.moveItem(at: location, to: dest)
            let attr = try FileManager.default.attributesOfItem(atPath: dest.path)
            fileSize = (attr[.size] as? Int64) ?? 0
        } catch {}

        lock.lock()
        finishedCount += 1
        // 用实际文件大小覆盖（只增不减）
        if fileSize > 0, (fileSizeMap[index] ?? 0) < fileSize {
            fileSizeMap[index] = fileSize
            bytesMap[index] = fileSize
        }
        lock.unlock()
        updateProgress()
        startNextTask()
        if finishedCount == urls.count {
            session.invalidateAndCancel()
            DispatchQueue.main.async {
                self.completion?()
            }
        }
    }
}
