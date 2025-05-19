//
//  MinecraftDownloader.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/19.
//

import Foundation

public class MinecraftDownloader {
    private init() {}
    
    public static func getJson(_ minecraftVersion: String, _ callback: @escaping (Data) -> Void) {
        let url = URL(string: "https://bmclapi2.bangbang93.com/version/\(minecraftVersion)/json")!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                let headers = httpResponse.allHeaderFields
                log("重定向: \(headers.keys)")
            }
        }
        task.resume()
        log("任务已创建")
    }
}
