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
        let before = Date().timeIntervalSince1970
        let javaEntities = try await JavaSearch.search()
        print("共找到 \(javaEntities.count) 个 Java, 耗时\(Int64((Date().timeIntervalSince1970 - before) * 1000))ms")
        javaEntities.forEach { javaEntity in
            print("----------------")
            print("路径: \(javaEntity.executableUrl!)")
            print("版本: \(javaEntity.displayVersion ?? "不知道")")
            print("架构: \(javaEntity.arch)")
            print("运行方式: \(javaEntity.callMethod)")
        }
    }
}
