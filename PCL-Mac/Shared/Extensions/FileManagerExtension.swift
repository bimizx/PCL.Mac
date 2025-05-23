//
//  FileManagerExtension.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/19.
//

import Foundation

extension FileManager {
    static let logURL = Constants.ApplicationLogUrl
    
    static func writeLog(_ content: String) async throws {
        try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .utility).async {
                let fileManager = FileManager.default
                do {
                    if !fileManager.fileExists(atPath: logURL.path) {
                        try fileManager.createDirectory(
                            at: logURL.parent(),
                            withIntermediateDirectories: true,
                            attributes: nil
                        )
                        fileManager.createFile(atPath: logURL.path, contents: nil)
                    }
                    let handle = try FileHandle(forWritingTo: logURL)
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
