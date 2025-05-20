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
        let handle = try FileHandle(forReadingFrom: URL(fileURLWithUserPath: "~/PCL-Mac-minecraft/versions/1.21/1.21.json"))
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let data = try handle.readToEnd()!
        let manifest = try decoder.decode(MinecraftManifest.self, from: data)
        print(manifest)
    }
}
