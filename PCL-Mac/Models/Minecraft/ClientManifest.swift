//
//  MinecraftManifest.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/20.
//

import Foundation

public struct ClientManifest: Codable {
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
        public struct Downloads: Codable {
            public struct Artifact: Codable {
                public let path: String
                public let sha1: String
                public let size: Int
                public let url: String
            }
            
            public struct Classifiers: Codable {
                public let nativesMacOS: Artifact?
                public let nativesOsx: Artifact?
                
                public enum CodingKeys: String, CodingKey {
                    case nativesMacOS = "natives-macos"
                    case nativesOsx = "natives-osx"
                }
            }
            
            public let artifact: Artifact
            public let classifiers: Classifiers?
        }
        
        public struct Natives: Codable {
            public let osx: String?
        }
        
        public let downloads: Downloads
        public let rules: [Rule]?
        public let natives: Natives
        
        public func getArtifact() -> Downloads.Artifact {
            return self.downloads.artifact
        }
        
        public func getArtifactUrl() -> URL? {
            if let key = natives.osx,
               let classifiers = downloads.classifiers {
                if let nativeArtifact: Downloads.Artifact = switch key {
                case "natives-osx": classifiers.nativesOsx
                case "natives-macos": classifiers.nativesMacOS
                default: nil
                } {
                    return URL(string: nativeArtifact.url)
                }
            }
            return nil
        }
    }
    
    public enum VersionType: String, Codable {
        case release = "release"
        case snapshot = "snapshot"
        case oldBeta = "old_beta"
        case oldAlpha = "oldAlpha"
    }
    
    
    
    public struct Arguments: Codable {
        public enum Value: Codable {
            case string(String)
            case list([String])
            
            public init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                if let string = try? container.decode(String.self) {
                    self = .string(string)
                } else {
                    self = .list(try container.decode([String].self))
                }
            }
            
            public func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                switch self {
                case .string(let value):
                    try container.encode(value)
                case .list(let value):
                    try container.encode(value)
                }
            }
        }
        
        public enum GameArgument: Codable {
            case string(String)
            case rules(RulesTag)
            
            public init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                if let stringValue = try? container.decode(String.self) {
                    self = .string(stringValue)
                } else {
                    self = .rules(try container.decode(RulesTag.self))
                }
            }
            
            public func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                switch self {
                case .string(let value):
                    try container.encode(value)
                case .rules(let value):
                    try container.encode(value)
                }
            }
            
            public struct RulesTag: Codable {
                public struct Rule: Codable {
                    public struct Features: Codable {
                        public let isDemoUser: Bool?
                        public let hasCustomResolution: Bool?
                        public let hasQuickPlaysSupport: Bool?
                        public let isQuickPlaySingleplayer: Bool?
                        public let isQuickPlayMultiplayer: Bool?
                        public let isQuickPlayRealms: Bool?
                        
                        public enum CodingKeys: String, CodingKey {
                            case isDemoUser = "is_demo_user"
                            case hasCustomResolution = "has_custom_resolution"
                            case hasQuickPlaysSupport = "has_quickplay_support"
                            case isQuickPlaySingleplayer = "is_quickplay_singleplayer"
                            case isQuickPlayMultiplayer = "is_quickplay_multiplayer"
                            case isQuickPlayRealms = "is_quickplay_realms"
                        }
                        
                        public func match() -> Bool {
                            if let isDemoUser = self.isDemoUser, isDemoUser {
                                return false
                            }
                            
                            if let hasCustomResolution = hasCustomResolution, hasCustomResolution {
                                return false
                            }
                            
                            if let hasQuickPlaysSupport = hasQuickPlaysSupport, hasQuickPlaysSupport {
                                return false
                            }
                            
                            if let isQuickPlaySingleplayer = isQuickPlaySingleplayer, isQuickPlaySingleplayer {
                                return false
                            }
                            
                            if let isQuickPlayMultiplayer = isQuickPlayMultiplayer, isQuickPlayMultiplayer {
                                return false
                            }
                            
                            if let isQuickPlayRealms = isQuickPlayRealms, isQuickPlayRealms {
                                return false
                            }
                            
                            return true
                        }
                    }
                    
                    public let action: Action
                    public let features: Features
                    
                    public func match() -> Bool {
                        return features.match() && action == .allow
                    }
                }
                
                public let rules: [Rule]
                public let value: Value
                
                public func match() -> Bool {
                    var match = true
                    for rule in rules {
                        match = match && rule.match()
                    }
                    return match
                }
            }
        }
        
        public struct JvmArgument: Codable {
            public struct RulesTag {
                public let rules: [Rule]
                public let value: Value
            }
        }
        
        public let game: [GameArgument]
        public let jvm: [JvmArgument]
        
        public func getAllowedGameArguments() -> [String] {
            let filted: [GameArgument] = game.filter { gameArgument in
                return switch gameArgument {
                case .rules(let rules): rules.match()
                default: true
                }
            }
            
            var arguments: [String] = []
            for argument in filted {
                switch argument {
                case .string(let string): arguments.append(string)
                case .rules(let rules):
                    if rules.match() {
                        switch rules.value {
                        case .string(let string): arguments.append(string)
                        case .list(let list): arguments.append(contentsOf: list)
                        }
                    }
                }
            }
            
            return arguments // 什么史山
        }
    }
    
    public let arguments: Arguments
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
                isAllowed = isAllowed && rule.os?.match() ?? true
            }
            return isAllowed
        }
    }
}

public enum Action: String, Codable {
    case allow = "allow"
    case disallow = "disallow"
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
    
    public let os: OSRule?
    public let action: Action
    
    public func match() -> Bool {
        return os?.match() ?? true && action == .allow
    }
}
