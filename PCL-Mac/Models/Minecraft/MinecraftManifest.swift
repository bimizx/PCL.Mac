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
    
    
    
    public let assetIndex: AssetIndex
    public let assets: String
    public let downloads: [String: DownloadInfo]
    public let id: String
    public let libraries: [Library]
    public let mainClass: String
    public let type: VersionType
}
