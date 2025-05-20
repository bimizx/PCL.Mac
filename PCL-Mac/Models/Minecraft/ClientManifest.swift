//
//  MinecraftManifest.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/20.
//

import Foundation

public struct MinecraftManifest: Codable {
    public struct AssetIndex: Codable {
        public let id: String
        public let sha1: String
        public let size: Int
        public let totalSize: Int
        public let url: String
    }
    
    public struct DownloadInfo: Codable {
        public let sha1: String
        public let size: Int
        public let url: String
    }
    
    public struct Library: Codable {
        public struct Artifact: Codable {
            public let path: String
            public let sha1: String
            public let size: Int
            public let url: String
        }
        
        public let downloads: [String: Artifact]
        public let rules: [Rule]?
        
        public func getArtifact() -> Artifact {
            return self.downloads["artifact"]!
        }
    }
    
    public enum VersionType: String, Codable {
        case release = "release"
        case snapshot = "snapshot"
        case oldBeta = "old_beta"
        case oldAlpha = "oldAlpha"
    }
    
    public struct Rule: Codable {
        public struct OSRule: Codable {
            public let name: String?
            public let arch: String?
            
            public func match() -> Bool {
                var matches = true
                
                if let name = self.name {
                    matches = matches && (name == "osx")
                }
                
                // TODO 判断转译是否启用及架构是否匹配
                
                return matches
            }
        }
        
        public enum Action: String, Codable {
            case allow = "allow"
            case disallow = "disallow"
        }
        
        public let os: OSRule
        public let action: Action
    }
    
    
    
    public let assetIndex: AssetIndex
    public let assets: String
    public let downloads: [String: DownloadInfo]
    public let id: String
    public let libraries: [Library]
    public let mainClass: String
    public let type: VersionType
    
    public func getNeededLibrary() -> [Library] {
        return self.libraries.filter { library in
            var isAllowed: Bool = true
            for rule in library.rules ?? [] {
                isAllowed = isAllowed && rule.os.match()
            }
            return isAllowed
        }
    }
}
