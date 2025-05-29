//
//  MinecraftVersion.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/23.
//

import Foundation

public protocol MinecraftVersion: Comparable {
    func getDisplayName() -> String
    static func fromString(_ string: String) -> Self?
}

public final class ReleaseMinecraftVersion: MinecraftVersion {
    private let major: Int
    private let minor: Int
    private let patch: Int
    
    public init(major: Int, minor: Int, patch: Int = 0) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }
    
    public static func fromString(_ string: String) -> ReleaseMinecraftVersion? {
        let components = string.components(separatedBy: ".")
        guard components.count >= 2,
              let major = Int(components[0]),
              let minor = Int(components[1]),
              let patch = Int(components.count == 3 ? components[2] : "0") else {
            return nil
        }
        return ReleaseMinecraftVersion(major: major, minor: minor, patch: patch)
    }
    
    public func getDisplayName() -> String {
        return "\(major).\(minor)" + (patch == 0 ? "" : ".\(patch)")
    }
    
    public static func ==(lhs: ReleaseMinecraftVersion, rhs: ReleaseMinecraftVersion) -> Bool {
        return lhs.major == rhs.major && lhs.minor == rhs.minor && lhs.patch == rhs.patch
    }
    
    public static func <(lhs: ReleaseMinecraftVersion, rhs: ReleaseMinecraftVersion) -> Bool {
        if lhs.major != rhs.major {
            return lhs.major < rhs.major
        } else if lhs.minor != rhs.minor {
            return lhs.minor < rhs.minor
        } else {
            return lhs.patch < rhs.patch
        }
    }
}

public final class SnapshotMinecraftVersion: MinecraftVersion {
    private let year: Int
    private let week: Int
    private let id: Character
    
    public init(year: Int, week: Int, id: Character) {
        self.year = year
        self.week = week
        self.id = id
    }
    
    public static func fromString(_ string: String) -> SnapshotMinecraftVersion? {
        let pattern = #"^(\d{2})w(\d{2})([a-z])$"#
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let range = NSRange(location: 0, length: string.utf16.count)
            
            if let match = regex.firstMatch(in: string, range: range) {
                guard let yearRange = Range(match.range(at: 1), in: string) else {
                    return nil
                }
                
                guard let weekRange = Range(match.range(at: 2), in: string) else {
                    return nil
                }
                
                var id: Character = "a"
                
                if let idRange = Range(match.range(at: 3), in: string) {
                    id = string[idRange].first!
                }
                
                return SnapshotMinecraftVersion(year: Int(string[yearRange])!, week: Int(string[weekRange])!, id: id)
            }
        } catch {
            err("正则表达式错误: \(error.localizedDescription)")
        }
        return nil
    }
    
    public func getDisplayName() -> String {
        return String(format: "%02dw%02d%@", self.year, self.week, String(self.id))
    }
    
    public static func ==(lhs: SnapshotMinecraftVersion, rhs: SnapshotMinecraftVersion) -> Bool {
        return lhs.year == rhs.year && lhs.week == rhs.week && lhs.id == rhs.id
    }
    
    public static func <(lhs: SnapshotMinecraftVersion, rhs: SnapshotMinecraftVersion) -> Bool {
        if lhs.year == rhs.year {
            if lhs.week == rhs.week {
                return lhs.id < rhs.id
            } else {
                return lhs.week < rhs.week
            }
        } else {
            return lhs.year < rhs.year
        }
    }
}
