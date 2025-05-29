//
//  PCL_MacTests.swift
//  PCL-MacTests
//
//  Created by YiZhiMCQiu on 2025/5/18.
//

import Foundation
import PCL_Mac
import XCTest

class PCL_MacTests: XCTestCase {
    func testRun() async throws {
        let version = "1.13"
        let versionUrl = URL(fileURLWithUserPath: "~/PCL-Mac-minecraft/versions/\(version)")
        let instance = MinecraftInstance(runningDirectory: versionUrl, version: ReleaseMinecraftVersion.fromString(version)!, MinecraftConfig(name: "Test", javaPath: "/Library/Java/JavaVirtualMachines/jdk-1.8.jdk/Contents/Home/bin/java"))
        await instance!.run()
    }
    
    func testLoadClientManifest() async throws {
        let handle = try FileHandle(forReadingFrom: URL(fileURLWithUserPath: "~/PCL-Mac-minecraft/versions/1.21/1.21.json"))
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let manifest = try decoder.decode(ClientManifest.self, from: handle.readToEnd()!)
        print(manifest.getArguments().getAllowedGameArguments())
    }
    
    func testDownload() async throws {
        var isRunning = true
        let version = "1.12"
        let versionUrl = URL(fileURLWithUserPath: "~/PCL-Mac-minecraft/versions/\(version)")
        MinecraftInstaller.createTask(versionUrl, version) {
            isRunning = false
        }.start()
        while isRunning {}
    }
    
    func testSnapshotVersion() async throws {
        print(SnapshotMinecraftVersion.fromString("11w45a")!.getDisplayName())
    }
    
    func testFetchVersionsManifest() async throws {
        let expectation = self.expectation(description: "Async operation")
        
        VersionManifest.fetchLatestData { manifest in
            print(manifest.versions.first!.parse()!.getDisplayName())
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 5)
    }
}
