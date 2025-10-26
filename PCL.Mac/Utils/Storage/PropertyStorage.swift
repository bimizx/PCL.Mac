//
//  PropertyStorage.swift
//  PCL.Mac
//
//  Created by 温迪 on 2025/10/1.
//

import Foundation

public final class PropertyStorage {
    private static let ENCRYPTION_KEY: String = "0123456789abcdef"
    /// App 设置
    public static let appSettings: PropertyStorage = .init(fileURL: AppURLs.configURL.appending(path: "app.json"))
    /// 账号相关
    public static let account: PropertyStorage = .init(fileURL: AppURLs.configURL.appending(path: "account.json"), encrypt: true)
    /// Minecraft 相关
    public static let minecraft: PropertyStorage = .init(fileURL: AppURLs.configURL.appending(path: "minecraft.json"))
    
    public static func loadAll() {
        do {
            try appSettings.load()
            try account.load()
            try minecraft.load()
        } catch {
            err("无法加载 PropertyStorage: \(error.localizedDescription)")
        }
    }
    
    public static func saveAll() {
        do {
            try appSettings.save()
            try account.save()
            try minecraft.save()
        } catch {
            err("无法保存 PropertyStorage: \(error)")
        }
    }
    
    private let fileURL: URL
    private let encrypt: Bool
    private var entries: [String: String] = [:]
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init(fileURL: URL, encrypt: Bool = false) {
        self.fileURL = fileURL
        self.encrypt = encrypt
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
        
        self.encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        if !encrypt {
            self.encoder.outputFormatting.insert(.prettyPrinted)
        }
    }

    public func load() throws {
        let reachable = (try? fileURL.checkResourceIsReachable()) ?? false
        guard reachable else {
            entries = [:]
            return
        }

        var data: Data = try Data(contentsOf: fileURL)
        if encrypt {
            do {
                data = try AESUtil.decrypt(data: Data(contentsOf: fileURL), key: Self.ENCRYPTION_KEY)
            } catch {}
        }
        let decoded = try decoder.decode([String: String].self, from: data)
            .mapValues { string in
                if let data = Data(base64Encoded: string) {
                    return String(data: data, encoding: .utf8) ?? string
                }
                return string
            }
        entries = decoded
    }

    public func save() throws {
        let directoryURL = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)

        let data: Data
        if encrypt {
            data = try AESUtil.encrypt(data: encoder.encode(entries), key: Self.ENCRYPTION_KEY)
        } else {
            data = try encoder.encode(entries)
        }
        try data.write(to: fileURL, options: [.atomic])
    }

    public func get<T: Codable>(key: String, type: T.Type) -> T? {
        guard let string = entries[key],
              let data = string.data(using: .utf8) else { return nil }
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            return nil
        }
    }
    
    public func contains(key: String) -> Bool {
        return entries[key] != nil
    }

    public func set<T: Codable>(key: String, value: T) {
        do {
            entries[key] = String(data: try encoder.encode(value), encoding: .utf8)
        } catch {
            err("无法序列化 \(key) 的值: \(error.localizedDescription)")
        }
    }
}
