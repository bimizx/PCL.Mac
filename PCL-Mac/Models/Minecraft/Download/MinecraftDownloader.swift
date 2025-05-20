//
//  MinecraftDownloader.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/19.
//

import Foundation

public class MinecraftDownloader {
    private init() {}
    
    // MARK: 下载二进制和普通文件
    private static func getBinary(_ sourceUrl: URL, _ saveUrl: URL, _ callback: @escaping (Data, HTTPURLResponse) throws -> Void) {
        let url = sourceUrl
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let semaphore = DispatchSemaphore(value: 0)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            semaphore.signal()
            if let error = error as? URLError {
                warn("下载失败: \(error)，正在重试")
                getBinary(sourceUrl, saveUrl, callback)
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    debug("200 OK GET \(url.path())")
                    if let data = data {
                        do {
                            try FileManager.default.createDirectory(
                                at: saveUrl.parent(),
                                withIntermediateDirectories: true,
                                attributes: nil
                            )
                            FileManager.default.createFile(atPath: saveUrl.path(), contents: nil)
                            
                            let handle = try FileHandle(forWritingTo: saveUrl)
                            try handle.write(contentsOf: data)
                            try handle.close()
                            try callback(data, httpResponse)
                        } catch {
                            err("在写入文件时发生错误: \(error)")
                        }
                    }
                } else {
                    err("请求 \(url.absoluteString) 时出现错误: \(httpResponse.statusCode)")
                }
            }
        }
        task.resume()
        semaphore.wait()
        debug("向 \(url.absoluteString) 发送了请求")
    }
    
    // MARK: 下载 JSON 文件并解析
    private static func getJson(_ sourceUrl: URL, _ saveUrl: URL, _ callback: @escaping ([String: Any], String, HTTPURLResponse) throws -> Void) {
        let url = sourceUrl
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let semaphore = DispatchSemaphore(value: 0)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            semaphore.signal()
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    log("200 OK GET \(url.path())")
                    if let data = data, let result = String(data: data, encoding: .utf8) {
                        do {
                            try FileManager.default.createDirectory(
                                at: saveUrl.parent(),
                                withIntermediateDirectories: true,
                                attributes: nil
                            )
                            FileManager.default.createFile(atPath: saveUrl.path(), contents: nil)
                            
                            let handle = try FileHandle(forWritingTo: saveUrl)
                            try handle.write(contentsOf: Data(JsonUtils.formatJSON(result)!.utf8))
                            try handle.close()
                            try callback(JSONSerialization.jsonObject(with: data) as! [String : Any], result, httpResponse)
                        } catch {
                            err("在写入文件时发生错误: \(error)")
                        }
                    }
                } else {
                    err("请求 \(url.absoluteString) 时出现错误: \(httpResponse.statusCode)")
                }
            }
        }.resume()
        log("向 \(url.absoluteString) 发送了请求")
        semaphore.wait()
    }
    
    // MARK: 下载客户端清单
    public static func downloadClientManifest(_ task: DownloadTask, _ callback: @escaping () -> Void) {
        let minecraftVersion = task.minecraftVersion.getDisplayName()
        let clientJsonUrl = task.versionUrl.appending(path: "\(minecraftVersion).json")
        let onJsonDownloadSuccessfully: (String) -> Void = { json in
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                task.manifest = try decoder.decode(ClientManifest.self, from: json.data(using: .utf8)!)
            } catch {
                err("无法解析 JSON: \(error)")
                return
            }
            let onJarDownloadSuccessfully: () -> Void = {
                DispatchQueue.main.async {
                    task.remainingFiles -= 1
                }
                callback()
            }
            DispatchQueue.main.async {
                task.remainingFiles -= 1
            }
            task.updateStage(.clientJar)
            let clientJarUrl = clientJsonUrl.parent().appending(path: "\(minecraftVersion).jar")
            if FileManager.default.fileExists(atPath: clientJarUrl.path()) {
                onJarDownloadSuccessfully()
                return
            }
            getBinary(URL(string: task.manifest!.downloads["client"]!.url)!, clientJsonUrl.parent().appending(path: "\(minecraftVersion).jar")) { _, _ in
                onJarDownloadSuccessfully()
            }
        }
        
        if FileManager.default.fileExists(atPath: clientJsonUrl.path()) {
            if let data = try? Data(contentsOf: clientJsonUrl),
               let result = String(data: data, encoding: .utf8) {
                onJsonDownloadSuccessfully(result)
            } else {
                err("无法获取客户端 JSON (\(clientJsonUrl.path())")
            }
        } else {
            getJson(URL(string: "https://bmclapi2.bangbang93.com/version/\(minecraftVersion)/json")!, clientJsonUrl) { dict, json, response in
                onJsonDownloadSuccessfully(json)
            }
        }
    }
    
    // MARK: 下载散列资源文件
    public static func downloadHashResourceFiles(_ task: DownloadTask, _ saveUrl: URL? = nil, _ callback: @escaping () -> Void) {
        let versionUrl = task.versionUrl
        let assetIndex: String = task.manifest!.assetIndex.id
        let downloadIndexUrl: URL = URL(string: task.manifest!.assetIndex.url)!
        
        let saveUrl = saveUrl ?? versionUrl.parent().parent().appending(path: "assets")
        let indexUrl = saveUrl.appending(path: "indexes").appending(path: "\(assetIndex).json")
        
        getJson(downloadIndexUrl, indexUrl) { dict, json, _ in
            task.updateStage(.clientResources)
            let index = dict as! [String: [String: [String: Any]]] // TODO 需要实现 Codable 结构体
            var leftObjects = index["objects"]!.keys.count
            DispatchQueue.main.async {
                task.totalFiles += leftObjects
                task.remainingFiles += leftObjects
            }
            log("发现 \(leftObjects) 个文件")
            
            for (_, object) in index["objects"]! {
                let hash: String = object["hash"] as! String
                let assetUrl: URL = saveUrl.appending(path: "objects").appending(path: hash.prefix(2)).appending(path: hash)
                let downloadUrl: URL = URL(string: "https://resources.download.minecraft.net")!.appending(path:hash.prefix(2)).appending(path: hash)
                
                if FileManager.default.fileExists(atPath: assetUrl.path()) {
                    log("\(downloadUrl.path()) 已存在，跳过")
                    leftObjects -= 1
                    DispatchQueue.main.async {
                        task.remainingFiles -= 1
                    }
                    continue
                }
                
                task.addOperation {
                    getBinary(downloadUrl, assetUrl) { _, _ in
                       leftObjects -= 1
                       DispatchQueue.main.async {
                           task.remainingFiles -= 1
                       }
                   }
                }
            }
            log("资源文件请求已全部发送完成")
            
            Task {
                while leftObjects > 0 {}
                log("客户端散列资源下载完毕")
                callback()
            }
        }
    }
    
    // MARK: 下载依赖项
    public static func downloadLibraries(_ task: DownloadTask, _ saveUrl: URL? = nil, _ callback: @escaping () -> Void) {
        let librariesUrl = task.versionUrl.parent().parent().appending(path: "libraries")
        let libraries = task.manifest!.getNeededLibrary()
        DispatchQueue.main.async {
            task.remainingFiles += libraries.count
            task.totalFiles += libraries.count
        }
        var leftObjects = libraries.count
        debug(leftObjects)
        
        for library in libraries {
            let artifact = library.getArtifact()
            let path: URL = librariesUrl.appending(path: artifact.path)
            let downloadUrl: URL = URL(string: artifact.url)!
            
            if FileManager.default.fileExists(atPath: path.path()) {
                log("\(downloadUrl.path()) 已存在，跳过")
                leftObjects -= 1
                DispatchQueue.main.async {
                    task.remainingFiles -= 1
                }
                continue
            }
            
            task.addOperation {
                getBinary(downloadUrl, path) { _, _ in
                    leftObjects -= 1
                    DispatchQueue.main.async {
                        task.remainingFiles -= 1
                    }
                }
            }
        }
        while leftObjects > 0 {}
        log("客户端依赖项下载完成")
        callback()
    }
    
    // MARK: 拷贝 log4j2.xml
    public static func copyLog4j2(_ task: DownloadTask) {
        let targetUrl: URL = task.versionUrl.appending(path: "log4j2.xml")
        if FileManager.default.fileExists(atPath: targetUrl.path()) {
            return
        }
        do {
            try FileManager.default.copyItem(
                at: Constants.ApplicationResourcesUrl.appending(path: task.minecraftVersion as! ReleaseMinecraftVersion >= ReleaseMinecraftVersion.fromString("1.12.2")! ? "log4j2.xml" : "log4j2-1.12-.xml"),
                to: targetUrl)
        } catch {
            err("无法拷贝 log4j2.xml: \(error)")
        }
    }
    
    // MARK: 创建下载任务
    public static func createTask(_ versionUrl: URL, _ minecraftVersion: String, _ completeCallback: (() -> Void)? = nil) -> DownloadTask {
        let task = DownloadTask(versionUrl: versionUrl, minecraftVersion: minecraftVersion) { task in
            task.updateStage(.clientJson)
            downloadClientManifest(task) {
                task.updateStage(.clientIndex)
                downloadHashResourceFiles(task) {
                    task.updateStage(.cliendLibraries)
                    downloadLibraries(task) {
                        copyLog4j2(task)
                        task.complete()
                        completeCallback?()
                    }
                }
            }
        }
        
        return task
    }
}

public class DownloadTask: ObservableObject {
    @Published public var stage: DownloadStage = .before
    @Published public var remainingFiles: Int = 2
    @Published public var totalFiles: Int = 2
    @Published public var isCompleted: Bool = false
    
    public var manifest: ClientManifest?
    
    public let versionUrl: URL
    public let minecraftVersion: any MinecraftVersion
    public let startTask: (DownloadTask) -> Void
    public let downloadQueue: OperationQueue
    
    init(versionUrl: URL, minecraftVersion: String, startTask: @escaping (DownloadTask) -> Void) {
        self.versionUrl = versionUrl
        self.minecraftVersion = ReleaseMinecraftVersion.fromString(minecraftVersion)!
        self.startTask = startTask
        self.downloadQueue = OperationQueue()
        self.downloadQueue.maxConcurrentOperationCount = 16
    }
    
    public func complete() {
        log("下载任务完成")
        self.updateStage(.end)
        DispatchQueue.main.async {
            self.isCompleted = true
        }
    }
    
    public func start() {
        self.startTask(self)
    }
    
    public func updateStage(_ stage: DownloadStage) {
        DispatchQueue.main.async {
            self.stage = stage
        }
    }
    
    public func addOperation(_ operation: @escaping () -> Void) {
        self.downloadQueue.addOperation(BlockOperation(block: operation))
    }
}

public enum DownloadStage {
    case before, clientJson, clientJar, clientIndex, clientResources, cliendLibraries, natives, end
    public func getDisplayName() -> String {
        switch self {
        case .before: "未启动"
        case .clientJson: "客户端 JSON 文件"
        case .clientJar: "客户端本体"
        case .clientIndex: "客户端资源索引"
        case .clientResources: "客户端散列资源"
        case .cliendLibraries: "客户端依赖项"
        case .natives: "本地库"
        case .end: "结束"
        }
    }
}

public class DownloadOperation: Operation, @unchecked Sendable {
    public let task: () -> Void
    
    public init(task: @escaping () -> Void) {
        self.task = task
    }
    
    public override func main() {
        task()
    }
}
