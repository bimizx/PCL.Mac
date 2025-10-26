//
//  MinecraftVersion.swift
//  PCL.Mac
//
//  Created by YiZhiMCQiu on 2025/5/23.
//

import Foundation

public class MinecraftVersion: Comparable, Hashable {
    public let displayName: String
    public let type: VersionType
    public let releaseDate: Date
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(displayName)
    }
    
    public init(displayName: String) {
        self.displayName = displayName
        if let version = VersionManifest.latest.versionMap[displayName] {
            self.type = version.type
            self.releaseDate = version.releaseTime
        } else {
            self.type = .release
            self.releaseDate = Date(timeIntervalSince1970: 0)
        }
    }
    
    public static func < (lhs: MinecraftVersion, rhs: MinecraftVersion) -> Bool {
        lhs.releaseDate < rhs.releaseDate
    }
    
    public static func == (lhs: MinecraftVersion, rhs: MinecraftVersion) -> Bool {
        lhs.displayName == rhs.displayName && lhs.type == rhs.type
    }
}

public enum VersionType: String, Codable {
    case release = "release"
    case snapshot = "snapshot"
    case prerelease = "pre-release"
    case rc = "rc"
    case alpha = "old_alpha"
    case beta = "old_beta"
    case aprilFool = "april_fool"
    case pending = "pending"
    
    public func getIconName() -> String {
        switch self {
        case .release: "ReleaseVersionIcon"
        case .snapshot, .pending: "SnapshotVersionIcon"
        case .beta, .alpha: "OldVersionIcon"
        case .aprilFool: "AprilFoolVersionIcon"
        default: "ReleaseVersionIcon"
        }
    }
}
