//
//  AppURLs.swift
//  PCL.Mac
//
//  Created by 温迪 on 2025/10/20.
//

import Foundation

public struct AppURLs {
    public static let applicationContentsURL: URL = Bundle.main.bundleURL.appending(path: "Contents")
    public static let applicationResourcesURL: URL = applicationContentsURL.appending(path: "Resources")
    public static let applicationSupportURL: URL = .applicationSupportDirectory.appending(path: "PCL.Mac")
    public static let logsURL: URL = applicationSupportURL.appending(path: "Logs")
    public static let configURL: URL = applicationSupportURL.appending(path: "Config")
    public static let temperatureURL: URL = applicationSupportURL.appending(path: "Temp")
    public static let authlibInjectorURL: URL = applicationSupportURL.appending(path: "authlib-injector.jar")
}
