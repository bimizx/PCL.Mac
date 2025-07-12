//
//  MinecraftDirectory.swift
//  PCL.Mac
//
//  Created by YiZhiMCQiu on 2025/5/30.
//

import Foundation

public struct MinecraftDirectory: Codable, Identifiable, Hashable {
    public static let `default`: MinecraftDirectory = .init(rootUrl: URL(fileURLWithUserPath: "~/PCL-Mac-minecraft"), name: "默认文件夹")
    
    public var id: UUID
    public let rootUrl: URL
    public var name: String
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rootUrl)
    }
    
    public var versionsUrl: URL {
        rootUrl.appendingPathComponent("versions")
    }
    
    public var assetsUrl: URL {
        rootUrl.appendingPathComponent("assets")
    }
    
    public var librariesUrl: URL {
        rootUrl.appendingPathComponent("libraries")
    }
    
    public init(rootUrl: URL, name: String) {
        self.id = .init()
        self.rootUrl = rootUrl
        self.name = name
    }
    
    public func getInnerInstances() -> [MinecraftInstance] {
        var instances: [MinecraftInstance] = []
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: versionsUrl, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles])
            let folderUrls = contents.filter { url in
                (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true
            }
            for folderUrl in folderUrls {
                if let version = MinecraftInstance.create(runningDirectory: folderUrl) {
                    instances.append(version)
                }
            }
        } catch {
            err("读取版本目录失败: \(error)")
        }
        return instances
    }
}
