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
        
        URLSession.shared.dataTask(with: request) { data, response, error in
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
        }.resume()
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
    
    public static func downloadJson(_ minecraftVersion: String, _ saveUrl: URL, _ callback: @escaping () -> Void) {
        getJson(URL(string: "https://bmclapi2.bangbang93.com/version/\(minecraftVersion)/json")!, saveUrl) { json, response in
            getBinary(URL(string: (json["downloads"] as! [String: [String: Any]])["client"]!["url"] as! String)!, saveUrl.parent().appending(path: "\(minecraftVersion).jar"))
            callback()
        }
    }
    
    public static func downloadHashResourceFiles(_ versionUrl: URL, _ saveUrl: URL? = nil, _ callback: @escaping () -> Void) {
        if let data = try? Data(contentsOf: versionUrl.appending(path: "\(versionUrl.lastPathComponent).json")),
           let jsonDictionary = try? JSONSerialization.jsonObject(with: data) as? [String: Any]{
            let assetIndex: String = (jsonDictionary["assetIndex"] as! [String: Any])["id"] as! String
            let downloadIndexUrl: URL = URL(string: (jsonDictionary["assetIndex"] as! [String: Any])["url"] as! String)!
            
            let saveUrl = saveUrl ?? versionUrl.parent().parent().appending(path: "assets")
            let indexUrl = saveUrl.appending(path: "indexes").appending(path: "\(assetIndex).json")
            
            getJson(downloadIndexUrl, indexUrl) { json, _ in
                let index = json as! [String: [String: [String: Any]]]
                var leftObjects = index["objects"]!.keys.count
                log("发现 \(leftObjects) 个文件")
                
                for (_, object) in index["objects"]! {
                    let hash: String = object["hash"] as! String
                    let assetUrl: URL = saveUrl.appending(path: "objects").appending(path: hash.prefix(2)).appending(path: hash)
                    let downloadUrl: URL = URL(string: "https://resources.download.minecraft.net")!.appending(path: hash.prefix(2)).appending(path: hash)
                    
                    if FileManager.default.fileExists(atPath: assetUrl.path()) {
                        log("\(downloadUrl.path()) 已存在，跳过")
                        leftObjects -= 1
                        continue
                    }
                    
                    getBinary(downloadUrl, assetUrl) { _, _ in
                        leftObjects -= 1
                    }
                }
                log("资源文件请求已全部发送完成")
                
                Task {
                    while leftObjects > 0 {}
                    log("下载完毕")
                    callback()
                }
            }
        }
    }
}
