//
//  JavaSearch.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/18.
//

import Foundation

public class JavaSearch {
    public static func search() async throws -> [JavaEntity] {
        var dirs: [String] = []
        dirs.append("/usr/bin")
        let jvmDirsRanges = [
            "/Library/Java/JavaVirtualMachines",
            "~/Library/Java/JavaVirtualMachines",
            "/opt/homebrew/opt/java/libexec"
        ]
        jvmDirsRanges.forEach { jvmDirsPath in
            do {
                let jvmFolders = try FileManager.default.contentsOfDirectory(at: URL(fileURLWithPath: jvmDirsPath), includingPropertiesForKeys: [.isDirectoryKey])
                    .filter { path in
                        var isDirectory: ObjCBool = false
                        return FileManager.default.fileExists(atPath: path.path(), isDirectory: &isDirectory) && isDirectory.boolValue && isValidJvmDirectory(path)
                    }
                    .map{ toJvmDirectory($0).path() }
                dirs.append(contentsOf: jvmFolders)
            } catch { }
        }
        return dirs.map { JavaEntity.of(URL(fileURLWithPath: $0.replacingOccurrences(of: "~", with: FileManager.default.homeDirectoryForCurrentUser.path)).appending(path: "java")) }
    }
    
    private static func isValidJvmDirectory(_ path: URL) -> Bool {
        var isDirectory: ObjCBool = false
        return FileManager.default.fileExists(atPath: toJvmDirectory(path).appending(path: "java").path(), isDirectory: &isDirectory) && !isDirectory.boolValue
    }
    
    private static func toJvmDirectory(_ path: URL) -> URL {
        return path.appending(path: "Contents").appending(path: "Home").appending(path: "bin")
    }
}
