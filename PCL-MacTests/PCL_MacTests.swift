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
        let instance = MinecraftInstance(runningDirectory: URL(fileURLWithUserPath: "~/PCL-Mac-minecraft/versions/1.21"), version: ReleaseMinecraftVersion.fromString("1.21")!)
        instance.run()
    }
}

