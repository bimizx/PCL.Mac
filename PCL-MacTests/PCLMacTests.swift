//
//  PCL_MacTests.swift
//  PCL-MacTests
//
//  Created by YiZhiMCQiu on 2025/5/18.
//

import Foundation
import Testing
import PCL_Mac
import SwiftUI
import Cocoa
import UserNotifications

struct PCL_MacTests {
    @Test func testRun() async throws {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        let versionUrl = URL(fileURLWithUserPath: "~/PCL-Mac-minecraft/versions/1.21 Test")
        let instance = MinecraftInstance.create(runningDirectory: versionUrl)
        await instance!.run()
    }
    
    @Test func testLoadClientManifest() async throws {
        let handle = try FileHandle(forReadingFrom: URL(fileURLWithUserPath: "~/PCL-Mac-minecraft/versions/1.21/1.21.json"))
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let manifest = try decoder.decode(ClientManifest.self, from: handle.readToEnd()!)
        print(manifest.getArguments().getAllowedGameArguments())
    }
    
    @Test func testDownload() async throws {
        await withCheckedContinuation { continuation in
            MinecraftInstaller.createTask(MinecraftVersion(displayName: "1.14"), "1.14", MinecraftDirectory(rootUrl: URL(fileURLWithUserPath: "~/PCL-Mac-minecraft"))) {
                continuation.resume()
            }.start()
        }
    }
    
    @Test func testFetchVersionsManifest() async throws {
        if let manifest = await VersionManifest.fetchLatestData() {
            print(manifest.versions.first!.parse().displayName)
        }
    }
    
    @Test func testMinecraftDirectory() async throws {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        DispatchQueue.main.schedule(after: DispatchQueue.SchedulerTimeType(DispatchTime(uptimeNanoseconds: 2000000000))) {
            print("22w16a 最合适的 Java 版本是: " + MinecraftInstance.findSuitableJava(MinecraftVersion(displayName: "22w16a"))!.executableUrl.path())
        }
    }
    
    @Test func testMsLogin() async throws {
        await MsLogin.login()
        print(LocalStorage.shared.accessToken!)
    }
    
    @Test func testNotifaction() async throws {
        UNUserNotificationCenter.current().setNotificationCategories([])
        
        let content = UNMutableNotificationContent()
        content.title = "登录"
        content.body = "请将剪切板中的内容粘贴到输入框中"
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil // 立即触发
        )
        try await UNUserNotificationCenter.current().add(request)
    }
    
    @Test func testNetwork() async throws {
        print(NetworkTest.shared.hasNetworkConnection())
    }
    
    @Test func testTheme() async {
        await ThemeDownloader.downloadTheme(.venti)
    }
    
    @Test func testSymbolicLink() throws {
        let start = DispatchTime.now()
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/libexec/java_home")
        try! process.run()
        process.waitUntilExit()
        print("耗时: \(Double(DispatchTime.now().uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000) 毫秒")
    }
    
    @Test func testWindow() throws {
        let options = CGWindowListOption(arrayLiteral: .excludeDesktopElements, .optionOnScreenOnly)
        guard let windowInfoList = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: Any]] else {
            throw NSError()
        }
        
        for info in windowInfoList {
            if let windowOwnerName = info["kCGWindowOwnerName"] as? String,
                windowOwnerName.lowercased().contains("java") {
                print(info)
            }
        }
    }
}
