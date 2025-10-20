//
//  Metadata.swift
//  PCL.Mac
//
//  Created by 温迪 on 2025/10/20.
//

import Foundation

public struct Metadata {
    public static let name: String = "PCL.Mac"
    public static let version: String = getInfoValue(key: "APP_VERSION", default: "本地构建")
    public static let branch: String = getInfoValue(key: "BRANCH", default: "本地")
    public static let userAgent: String = "PCL-Mac/\(getInfoValue(key: "APP_VERSION", default: "local"))"
    public static let isDevelopment: Bool = getInfoValue(key: "IS_DEVELOPMENT", default: "true") == "true"
    
    private static func getInfoValue(key: String, default: String) -> String {
        let value: String = (Bundle.main.object(forInfoDictionaryKey: key) as? String) ?? ""
        return value.isEmpty ? `default` : value
    }
}
