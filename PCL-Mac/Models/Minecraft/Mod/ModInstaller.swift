//
//  ModDownloader.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/6/19.
//

import Foundation
import Alamofire
import SwiftyJSON
import SwiftUI

public struct ModPlatformKey: Hashable, Comparable {
    public static func < (lhs: ModPlatformKey, rhs: ModPlatformKey) -> Bool {
        lhs.minecraftVersion < rhs.minecraftVersion
    }
    
    let loader: ClientBrand
    let minecraftVersion: MinecraftVersion
}

public struct ModVersion: Hashable, Identifiable {
    public let id: UUID = .init()
    
    let name: String
    let version: String
    let releaseDate: Date
    let type: String
    let downloadUrl: URL
    let filename: String
    
    func getDescription() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.unitsStyle = .full
        let result = formatter.localizedString(for: releaseDate, relativeTo: Date()).replacingOccurrences(of: "(\\d+)", with: " $1 ", options: .regularExpression)
        let typeText = switch type {
        case "release":
            "正式版"
        case "beta", "alpha":
            "测试版"
        default:
            "未知"
        }
        return filename[filename.startIndex...filename.index(filename.endIndex, offsetBy: -5)]
        + "，更新于\(result)"
        + "，\(typeText)"
    }
}

public typealias ModVersionMap = [ModPlatformKey: [ModVersion]]

@MainActor
public class ModSummary: ObservableObject, Identifiable, Hashable, Equatable {
    public let id: UUID = UUID()
    public let title: String
    public let description: String
    public let infoUrl: URL
    private let loadVersions: () async -> ModVersionMap
    @Published public var versions: ModVersionMap?
    @Published public var icon: Image?
    
    nonisolated public static func == (lhs: ModSummary, rhs: ModSummary) -> Bool {
        lhs.id == rhs.id
    }
    
    nonisolated public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(description)
    }
    
    init(title: String, description: String, infoUrl: URL, iconUrl: URL?, loadVersions: @escaping () async -> ModVersionMap) {
        self.title = title
        self.description = description
        self.infoUrl = infoUrl
        self.loadVersions = loadVersions
        
        if let iconUrl = iconUrl {
            Task {
                do {
                    let (data, _) = try await URLSession.shared.data(from: iconUrl)
                    if let nsImage = NSImage(data: data) {
                        self.icon = Image(nsImage: nsImage)
                    }
                } catch {
                    self.icon = Image("ModIconPlaceholder")
                }
            }
        } else {
            self.icon = Image("ModIconPlaceholder")
        }
    }
    
    public func getVersions() -> ModVersionMap? {
        if versions == nil {
            Task {
                self.versions = await self.loadVersions()
            }
        }
        
        return versions
    }
}

public protocol ModSearching {
    func search(query: String?, version: MinecraftVersion?) async -> [ModSummary]
}

public class ModrinthModSearcher: ModSearching {
    public static let `default` = ModrinthModSearcher()
    
    public func search(query: String? = nil, version: MinecraftVersion? = nil) async -> [ModSummary] {
        var facets = [
            ["project_type:mod"],
        ]
        
        if let version = version {
            facets.append(["version:\(version.displayName)"])
        }
        
        let facetsData = try! JSONSerialization.data(withJSONObject: facets)
        let facetsString = String(data: facetsData, encoding: .utf8)!
        
        if let data = try? await AF.request(
            "https://api.modrinth.com/v2/search",
            method: .get,
            parameters: [
                "query": query ?? "",
                "facets": facetsString,
                "limit": 40
            ],
            encoding: URLEncoding.default
        ).serializingResponse(using: .data).value,
           let json = try? JSON(data: data) {
            let mods = json["hits"].arrayValue
            var result: [ModSummary] = []
            for mod in mods {
                await result.append(
                    ModSummary(
                        title: mod["title"].stringValue,
                        description: mod["description"].stringValue,
                        infoUrl: URL(string: "https://modrinth.com/mod/\(mod["slug"].stringValue)")!,
                        iconUrl: URL(string: mod["icon_url"].stringValue),
                        loadVersions: { await self.getVersions(mod["slug"].stringValue) }
                    )
                )
            }
            return result
        }
        return []
    }
    
    private func getVersions(_ slug: String) async -> ModVersionMap {
        if let data = try? await AF.request(
            "https://api.modrinth.com/v2/project/\(slug)/version"
        ).serializingResponse(using: .data).value,
           let json = try? JSON(data: data) {
            var versions: ModVersionMap = [:]
            
            for version in json.arrayValue {
                let key = ModPlatformKey(
                    loader: ClientBrand(rawValue: version["loaders"].arrayValue.first!.stringValue) ?? .vanilla,
                    minecraftVersion: MinecraftVersion(displayName: version["game_versions"].arrayValue.first!.stringValue)
                )
                
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                
                let modVersion = ModVersion(
                    name: version["name"].stringValue,
                    version: version["version_number"].stringValue,
                    releaseDate: formatter.date(from: version["date_published"].stringValue)!,
                    type: version["version_type"].stringValue,
                    downloadUrl: version["files"].arrayValue.first!["url"].url!,
                    filename: version["files"].arrayValue.first!["filename"].stringValue.removingPercentEncoding!
                )
                if versions[key] == nil {
                    versions[key] = []
                }
                versions[key]!.append(modVersion)
            }
            
            return versions
        }
        return [:]
    }
}
