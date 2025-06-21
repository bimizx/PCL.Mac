//
//  LocalStorage.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/19.
//

import SwiftUI

public enum ColorSchemeOption: Codable {
    case light, dark, system
    func getLabel() -> String {
        switch self {
        case .light:
            "浅色模式"
        case .dark:
            "深色模式"
        case .system:
            "跟随系统"
        }
    }
}

public class AppSettings: ObservableObject {
    public static let shared = AppSettings()
    
    @AppStorage("user_added_jvm_paths") private var urlStringArray: String = "[]"
    public var userAddedJvmPaths: [URL] {
        get {
            (try? JSONDecoder().decode([String].self, from: Data(urlStringArray.utf8)))?.compactMap { URL(string: $0) } ?? []
        }
        set {
            if let data = try? JSONEncoder().encode(newValue.map { $0.absoluteString }) {
                urlStringArray = String(data: data, encoding: .utf8) ?? "[]"
            }
        }
    }
    
    /// 主题需要观察 DataManager 才能更新
    @AppStorage("theme") private var themeRawValue: String = Theme.pcl.rawValue
    public var theme: Theme {
        get { Theme(rawValue: themeRawValue) ?? .pcl }
        set {
            themeRawValue = newValue.rawValue
            objectWillChange.send()
        }
    }
    
    /// 启动时若为空自动设置为第一个版本
    @AppStorage("defaultInstance") public var defaultInstance: String?
    
    /// 访问令牌，登录正版或刷新时赋值
    @AppStorage("accessToken") public var accessToken: String?
    
    /// 刷新令牌，登录正版或刷新时赋值
    @AppStorage("refreshToken") public var refreshToken: String?
    
    /// 上次刷新时间，用于判断是否需要刷新访问令牌
    @AppStorage("lastRefreshToken") public var lastRefreshToken: Date = Date(timeIntervalSince1970: 0)
    
    /// 配色方案
    @CodableAppStorage(wrappedValue: ColorSchemeOption.light, "colorScheme") public var colorScheme: ColorSchemeOption
    
    /// 最后一次获取到的 VersionManifest，断网时使用
    @CodableAppStorage(wrappedValue: nil, "lastVersionManifest") public var lastVersionManifest: VersionManifest?
    
    public func updateColorScheme() {
        if colorScheme != .system {
            NSApp.appearance = colorScheme == .light ? NSAppearance(named: .aqua) : NSAppearance(named: .darkAqua)
        }
    }
    
    private init() {
        log("已加载持久化储存数据")
    }
}
