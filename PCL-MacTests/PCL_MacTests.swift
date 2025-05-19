//
//  PCL_MacTests.swift
//  PCL-MacTests
//
//  Created by YiZhiMCQiu on 2025/5/18.
//

import Testing
import Foundation
import PCL_Mac

struct PCL_MacTests {

    @Test func example() async throws {
        var isRunning = true
        let version = "1.21"
        let versionFolderUrl = URL(fileURLWithPath: "/Users/yizhimcqiu/PCL-Mac-minecraft/versions/\(version)")
        
        MinecraftDownloader.downloadJson(version, versionFolderUrl.appending(path: "\(version).json")) {
            MinecraftDownloader.downloadHashResourceFiles(versionFolderUrl) {
                isRunning = false
            }
        }
        while isRunning {}
    }
}
