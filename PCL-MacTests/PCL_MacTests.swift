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
        var isRunning: Bool = true
        VersionManifest.fetchLatestData() { manifest in
            manifest.versions.filter { $0.type == "release" }.forEach { version in
                print(version.id)
            }
            isRunning = false
        }
        while isRunning {}
    }
}
