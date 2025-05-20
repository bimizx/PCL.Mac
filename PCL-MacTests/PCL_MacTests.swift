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
        let version = "1.21"
        let versionFolderUrl = URL(fileURLWithPath: "/Users/yizhimcqiu/PCL-Mac-minecraft/versions/\(version)")
        let task = MinecraftDownloader.createTask(versionFolderUrl, version)
        while !task.isCompleted {}
    }
}
