//
//  SkinCacheStorage.swift
//  PCL.Mac
//
//  Created by YiZhiMCQiu on 2025/8/11.
//

import Foundation

class SkinCacheStorage {
    private static let skinURL: URL = AppURLs.cacheURL.appending(path: "skin")
    
    @discardableResult
    public static func loadSkin(account: AnyAccount) async throws -> Data {
        let skinData = try await account.getSkinData()
        put(skin: skinData, uuid: account.uuid)
        return skinData
    }
    
    public static func put(skin: Data, uuid: UUID) {
        FileManager.default.createFile(atPath: skinURL.appending(path: "\(uuid.uuidString).png").path, contents: skin)
    }
    
    public static func get(uuid: UUID) -> Data? {
        let url: URL = skinURL.appending(path: "\(uuid.uuidString).png")
        return try? FileHandle(forReadingFrom: url).readToEnd().unwrap()
    }
}
