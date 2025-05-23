//
//  MinecraftDownloader.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/19.
//

import Foundation
import Zip

public class MinecraftInstaller {
    private init() {}
    
    // MARK: 下载二进制和普通文件
    private static func getBinary(_ sourceUrl: URL, _ saveUrl: URL, _ callback: @escaping (Data, HTTPURLResponse) throws -> Void) {
        let url = sourceUrl
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
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
        debug("向 \(url.absoluteString) 发送了请求")
    }
    
    // MARK: 下载 JSON 文件并解析
    private static func getJson(_ sourceUrl: URL, _ saveUrl: URL, _ callback: @escaping ([String: Any], String, HTTPURLResponse) throws -> Void) {
        let url = sourceUrl
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    debug("200 OK GET \(url.path())")
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
        debug("向 \(url.absoluteString) 发送了请求")
    }
    
    // MARK: 下载客户端本体
    public static func downloadClientJar(_ task: InstallTask, _ callback: @escaping () -> Void) {
        task.updateStage(.clientJar)
        let clientJarUrl = task.versionUrl.appending(path: task.minecraftVersion.getDisplayName() + ".jar")
        if FileManager.default.fileExists(atPath: clientJarUrl.path()) {
            task.decrement()
            callback()
            return
        }
        
        getBinary(URL(string: "https://bmclapi2.bangbang93.com/version/\(task.minecraftVersion.getDisplayName())/client")!, clientJarUrl) { _, _ in
            task.decrement()
            callback()
        }
    }
    
    // MARK: 下载客户端清单
    public static func downloadClientManifest(_ task: InstallTask, _ callback: @escaping () -> Void) {
        debug("正在下载客户端清单")
        let minecraftVersion = task.minecraftVersion.getDisplayName()
        let clientJsonUrl = task.versionUrl.appending(path: "\(minecraftVersion).json")
        let onJsonDownloadSuccessfully: (String) -> Void = { json in
            task.decrement()
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                task.manifest = try decoder.decode(ClientManifest.self, from: json.data(using: .utf8)!)
            } catch {
                err("无法解析 JSON: \(error)")
                return
            }
            downloadClientJar(task, callback)
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
    public static func downloadHashResourceFiles(_ task: InstallTask, _ saveUrl: URL? = nil, _ callback: @escaping () -> Void) {
        let versionUrl = task.versionUrl
        let assetIndex: String = task.manifest!.assetIndex.id
        let downloadIndexUrl: URL = URL(string: task.manifest!.assetIndex.url)!
        
        let saveUrl = saveUrl ?? versionUrl.parent().parent().appending(path: "assets")
        let indexUrl = saveUrl.appending(path: "indexes").appending(path: "\(assetIndex).json")
        debug("正在获取散列资源索引")
        
        getJson(downloadIndexUrl, indexUrl) { dict, json, _ in
            task.updateStage(.clientResources)
            let index = dict as! [String: [String: [String: Any]]] // TODO 需要实现 Codable 结构体
            var leftObjects = index["objects"]!.keys.count
            updateTotalFiles(task, leftObjects)
            DispatchQueue.main.async {
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
                    task.decrement()
                    continue
                }
                
                task.addOperation {
                    getBinary(downloadUrl, assetUrl) { _, _ in
                        leftObjects -= 1
                        task.decrement()
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
    public static func downloadLibraries(_ task: InstallTask, _ saveUrl: URL? = nil, _ callback: @escaping () -> Void) {
        let librariesUrl = task.versionUrl.parent().parent().appending(path: "libraries")
        let libraries = task.manifest!.getNeededLibraries()
        DispatchQueue.main.async {
            task.remainingFiles += libraries.count
        }
        var leftObjects = libraries.count
        debug("本地库数量: \(leftObjects)")
        
        for library in libraries {
            guard let artifact = library.getArtifact() else {
                leftObjects -= 1
                task.decrement()
                continue
            }
            let path: URL = librariesUrl.appending(path: artifact.path)
            let downloadUrl: URL = URL(string: artifact.url)!
            
            if FileManager.default.fileExists(atPath: path.path()) {
                log("\(downloadUrl.path()) 已存在，跳过")
                leftObjects -= 1
                task.decrement()
                continue
            }
            
            task.addOperation {
                getBinary(downloadUrl, path) { _, _ in
                    leftObjects -= 1
                    task.decrement()
                }
            }
        }
        while leftObjects > 0 {}
        log("客户端依赖项下载完成")
        callback()
    }
    
    // MARK: 下载本地库
    public static func downloadNatives(_ task: InstallTask, _ callback: @escaping () -> Void) {
        let natives = task.manifest!.libraries.map { $0.getNativesArtifact() }.filter{ $0 != nil }.map { $0! }
        let nativesUrl = task.versionUrl.appending(path: "natives")
        var leftObjects = natives.count
        
        // MARK: 下载
        for native in natives {
            let saveUrl = task.versionUrl.parent().parent().appending(path: "libraries").appending(path: native.path)
            
            if FileManager.default.fileExists(atPath: saveUrl.path()) {
                log(saveUrl.path() + "已存在，跳过")
                leftObjects -= 1
                task.decrement()
            }
            
            task.addOperation {
                getBinary(URL(string: native.url)!, saveUrl) {_, _ in
                    leftObjects -= 1
                    task.decrement()
                    // MARK: 解压
                    do {
                        try Zip.unzipFile(saveUrl, destination: nativesUrl, overwrite: true, password: nil)
                        // 只保留 dylib
                        let fileManager = FileManager.default
                        let contents = try fileManager.contentsOfDirectory(at: nativesUrl, includingPropertiesForKeys: nil)
                        for fileURL in contents {
                            if !fileURL.pathExtension.lowercased().hasSuffix("dylib") {
                                try fileManager.removeItem(at: fileURL)
                            }
                        }
                        debug("解压 \(native.url) 成功")
                    } catch {
                        err("无法解压本地库: \(error)")
                    }
                }
            }
        }
        
        while leftObjects > 0 { }
        log("本地库下载完成")
        callback()
    }
    
    // MARK: 拷贝 log4j2.xml
    public static func copyLog4j2(_ task: InstallTask) {
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
    
    // MARK: 检测需要下载的文件数
    private static func updateTotalFiles(_ task: InstallTask, _ hashFilesCount: Int) {
        DispatchQueue.main.async {
            task.totalFiles = 2 + hashFilesCount + task.manifest!.getNeededLibraries().count + task.manifest!.getNeededNatives().count
            task.remainingFiles = task.totalFiles! - 3
        }
    }
    
    // MARK: 创建下载任务
    public static func createTask(_ versionUrl: URL, _ minecraftVersion: String, _ completeCallback: (() -> Void)? = nil) -> InstallTask {
        let task = InstallTask(versionUrl: versionUrl, minecraftVersion: minecraftVersion) { task in
            Task {
                task.updateStage(.clientJson)
                downloadClientManifest(task) {
                    task.updateStage(.clientIndex)
                    downloadHashResourceFiles(task) {
                        task.updateStage(.cliendLibraries)
                        downloadLibraries(task) {
                            downloadNatives(task) {
                                copyLog4j2(task)
                                task.complete()
                                completeCallback?()
                            }
                        }
                    }
                }
            }
        }
        
        return task
    }
}

public class InstallTask: ObservableObject {
    @Published public var stage: InstallStage = .before
    @Published public var remainingFiles: Int = 2
    @Published public var totalFiles: Int?
    @Published public var isCompleted: Bool = false
    @Published public var leftObjects: Int = 0
    
    public var manifest: ClientManifest?
    
    public let versionUrl: URL
    public let minecraftVersion: any MinecraftVersion
    public let startTask: (InstallTask) -> Void
    public let downloadQueue: OperationQueue
    
    init(versionUrl: URL, minecraftVersion: String, startTask: @escaping (InstallTask) -> Void) {
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
            self.remainingFiles = 0
            self.isCompleted = true
        }
    }
    
    public func start() {
        self.startTask(self)
    }
    
    public func updateStage(_ stage: InstallStage) {
        DispatchQueue.main.async {
            self.stage = stage
        }
    }
    
    public func addOperation(_ operation: @escaping () -> Void) {
        self.downloadQueue.addOperation(BlockOperation(block: operation))
    }
    
    public func decrement() {
        DispatchQueue.main.async {
            self.remainingFiles -= 1
        }
    }
}

public enum InstallStage {
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

public class InstallOperation: Operation, @unchecked Sendable {
    public let task: () -> Void
    
    public init(task: @escaping () -> Void) {
        self.task = task
    }
    
    public override func main() {
        task()
    }
}
