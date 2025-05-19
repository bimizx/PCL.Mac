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
        MinecraftDownloader.getJson("1.21") { data in
            print(data)
        }
        try? await Task.sleep(nanoseconds: 2000000000)
    }
}
