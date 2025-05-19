//
//  FileManagerExtension.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/19.
//

import Foundation

extension FileManager {
    static let logURL = Bundle.main.bundleURL.appending(path: "Contents").appending(path: "Logs").appending(path: "app.log")
    
    func writeLog(_ content: String) async throws {
        try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .utility).async {
                do {
                    if !self.fileExists(atPath: Self.logURL.path) {
                        try self.createDirectory(
                            at: Self.logURL.parent(),
                                withIntermediateDirectories: true,
                                attributes: nil
                            )
                        self.createFile(atPath: Self.logURL.path, contents: nil)
                    }
                    
                    let handle = try FileHandle(forWritingTo: Self.logURL)
                    try handle.write(contentsOf: Data(content.utf8))
                    try handle.close()
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
