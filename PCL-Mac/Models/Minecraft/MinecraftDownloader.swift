//
//  MinecraftDownloader.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/19.
//

import Foundation

public class MinecraftDownloader {
    private init() {}
    
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
    
    private static func getJson(_ sourceUrl: URL, _ saveUrl: URL, _ callback: @escaping ([String: Any], HTTPURLResponse) throws -> Void) {
        let url = sourceUrl
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
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
                            try callback(JSONSerialization.jsonObject(with: data) as! [String : Any], httpResponse)
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
    }
    
    private static func getBinary(_ sourceUrl: URL, _ saveUrl: URL) {
        getBinary(sourceUrl, saveUrl) { _, __ in}
    }
    
    private static func getJson(_ sourceUrl: URL, _ saveUrl: URL) {
        getJson(sourceUrl, saveUrl) { _, __ in}
    }
    
    public static func downloadJson(_ task: DownloadTask, _ callback: @escaping () -> Void) {
        let minecraftVersion = task.minecraftVersion
        let clientJsonUrl = task.versionUrl.appending(path: "\(minecraftVersion).json")
        let onJsonDownloadSuccessfully: ([String: Any]) -> Void = { json in
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
            getBinary(URL(string: (json["downloads"] as! [String: [String: Any]])["client"]!["url"] as! String)!, clientJsonUrl.parent().appending(path: "\(minecraftVersion).jar")) { _, _ in
                onJarDownloadSuccessfully()
            }
        }
        
        if FileManager.default.fileExists(atPath: clientJsonUrl.path()) {
            if let data = try? Data(contentsOf: clientJsonUrl),
               let jsonDictionary = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                onJsonDownloadSuccessfully(jsonDictionary)
            } else {
                err("无法获取客户端 JSON (\(clientJsonUrl.path())")
            }
        } else {
            getJson(URL(string: "https://bmclapi2.bangbang93.com/version/\(minecraftVersion)/json")!, clientJsonUrl) { json, response in
                onJsonDownloadSuccessfully(json)
            }
        }
    }
    
    public static func downloadHashResourceFiles(_ task: DownloadTask, _ saveUrl: URL? = nil, _ callback: @escaping () -> Void) {
        let versionUrl = task.versionUrl
        if let data = try? Data(contentsOf: versionUrl.appending(path: "\(versionUrl.lastPathComponent).json")),
           let jsonDictionary = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            let assetIndex: String = (jsonDictionary["assetIndex"] as! [String: Any])["id"] as! String
            let downloadIndexUrl: URL = URL(string: (jsonDictionary["assetIndex"] as! [String: Any])["url"] as! String)!
            
            let saveUrl = saveUrl ?? versionUrl.parent().parent().appending(path: "assets")
            let indexUrl = saveUrl.appending(path: "indexes").appending(path: "\(assetIndex).json")
            
            getJson(downloadIndexUrl, indexUrl) { json, _ in
                task.updateStage(.clientResources)
                let index = json as! [String: [String: [String: Any]]]
                var leftObjects = index["objects"]!.keys.count
                DispatchQueue.main.async {
                    task.totalFiles += leftObjects
                    task.remainingFiles += leftObjects
                }
                log("发现 \(leftObjects) 个文件")
                
                for (_, object) in index["objects"]! {
                    let hash: String = object["hash"] as! String
                    let assetUrl: URL = saveUrl.appending(path: "objects").appending(path: hash.prefix(2)).appending(path: hash)
                    let downloadUrl: URL = URL(string: "https://resources.download.minecraft.net")!.appending(path: hash.prefix(2)).appending(path: hash)
                    
                    if FileManager.default.fileExists(atPath: assetUrl.path()) {
                        log("\(downloadUrl.path()) 已存在，跳过")
                        leftObjects -= 1
                        DispatchQueue.main.async {
                            task.remainingFiles -= 1
                        }
                        continue
                    }
                    
                    getBinary(downloadUrl, assetUrl) { _, _ in
                        leftObjects -= 1
                        DispatchQueue.main.async {
                            task.remainingFiles -= 1
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
    }
    
    public static func downloadLibraries(_ task: DownloadTask, _ saveUrl: URL? = nil, _ callback: @escaping () -> Void) {
        let versionUrl = task.versionUrl
        let librariesUrl = task.versionUrl.parent().parent().appending(path: "libraries")
        if let data = try? Data(contentsOf: versionUrl.appending(path: "\(versionUrl.lastPathComponent).json")),
           let jsonDictionary = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            let libraries = jsonDictionary["libraries"] as! [[String: Any]]
            DispatchQueue.main.async {
                task.remainingFiles += libraries.count
                task.totalFiles += libraries.count
            }
            var leftObjects = libraries.count
            
            for library in libraries {
                let artifact = (library["downloads"] as! [String: [String: Any]])["artifact"]!
                let path: URL = librariesUrl.appending(path: artifact["path"] as! String)
                let downloadUrl: URL = URL(string: artifact["url"] as! String)!
                
                if FileManager.default.fileExists(atPath: path.path()) {
                    log("\(downloadUrl.path()) 已存在，跳过")
                    leftObjects -= 1
                    DispatchQueue.main.async {
                        task.remainingFiles -= 1
                    }
                }
                
                getBinary(downloadUrl, path) { _, _ in
                    leftObjects -= 1
                    DispatchQueue.main.async {
                        task.remainingFiles -= 1
                    }
                }
            }
            while leftObjects > 0 {}
            log("客户端依赖项下载完成")
        }
    }
    
    public static func createTask(_ versionUrl: URL, _ minecraftVersion: String) -> DownloadTask {
        let task = DownloadTask(versionUrl: versionUrl, minecraftVersion: minecraftVersion) { task in
            task.updateStage(.clientJson)
            downloadJson(task) {
                task.updateStage(.clientIndex)
                downloadHashResourceFiles(task) {
                    task.updateStage(.cliendLibraries)
                    downloadLibraries(task) {
                        task.complete()
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
    
    public let versionUrl: URL
    public let minecraftVersion: String
    public let startTask: (DownloadTask) -> Void
    
    init(versionUrl: URL, minecraftVersion: String, startTask: @escaping (DownloadTask) -> Void) {
        self.versionUrl = versionUrl
        self.minecraftVersion = minecraftVersion
        self.startTask = startTask
    }
    
    public func complete() {
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
}

public enum DownloadStage {
    case before, clientJson, clientJar, clientIndex, clientResources, cliendLibraries, end
    public func getDisplayName() -> String {
        switch self {
        case .before: "未启动"
        case .clientJson: "客户端 JSON 文件"
        case .clientJar: "客户端本体"
        case .clientIndex: "客户端资源索引"
        case .clientResources: "客户端散列资源"
        case .cliendLibraries: "客户端依赖项"
        case .end: "结束"
        }
    }
}
