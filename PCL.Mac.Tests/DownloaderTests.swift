//
//  DownloaderTests.swift
//  PCL.Mac
//
//  Created by YiZhiMCQiu on 2025/8/24.
//

import Foundation
import PCL_Mac
import Testing
import SwiftyJSON

struct DownloaderTests {
    @Test func testSingleFileDownload() async throws {
        AccountManager.shared.accounts.append(.offline(.init("MinecraftVenti", UUID(uuidString: "038d4a77-200d-48c7-8217-20de0a4d313a"))))
//        try await SingleFileDownloader.download(url: "https://bmclapi2.bangbang93.com/version/1.21/client".url, destination: URL(fileURLWithUserPath: "~/test.file"), replaceMethod: .replace) { progress in
//            print(progress)
//        }
    }
    
    @Test func testMultiFileDownload() async throws {
        let versions = ["1.21", "1.19", "1.14.2"]
        
        let downloader = MultiFileDownloader(
            items: versions.map {
                DownloadItem("https://bmclapi2.bangbang93.com/version/\($0)/client".url, URL(fileURLWithPath: "/tmp/\($0).jar"))
            },
            concurrentLimit: 4,
            replaceMethod: .replace
        ) { progress, finished in
            print(String(format: "%.2f%% %d", progress, finished))
        }
        
        try await downloader.start()
    }
    
    @Test func testReusableMultiFileDownload() async throws {
        let hash: String = "5d8c3181a7d68c2e8a27a57ffead439991a6ed2c"
        try await ReusableMultiFileDownloader(
            urls: [URL(string: "https://resources.download.minecraft.net/5d/\(hash)")!],
            destinations: [URL(fileURLWithUserPath: "/tmp/\(hash)")],
            sha1: [hash],
            maxConnections: 64
        ).start()
        let _ = try JSON(data: FileHandle(forReadingFrom: URL(filePath: "/tmp/\(hash)")).readToEnd().unwrap())
        try FileManager.default.removeItem(at: URL(filePath: "/tmp/\(hash)"))
    }
}
