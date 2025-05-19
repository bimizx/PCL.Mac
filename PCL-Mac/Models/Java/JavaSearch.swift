//
//  JavaSearch.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/18.
//

import Foundation

public class JavaSearch {
    public static var JavaVirtualMachines: [JavaVirtualMachine] = []
    public static var lastTimeUsed: Int = 0
    public static var highestVersion: Int!
    
    public static func searchAndSet() async throws {
        let before = Date().timeIntervalSince1970
        JavaVirtualMachines = try await search()
        lastTimeUsed = Int((Date().timeIntervalSince1970 - before) * 1000)
        highestVersion = JavaVirtualMachines.sorted { jvm1, jvm2 in
            return jvm1.version > jvm2.version
        }[0].version
        
        for i in 0..<JavaVirtualMachines.count {
            if JavaVirtualMachines[i].version == 0 {
                JavaVirtualMachines[i].version = highestVersion
                JavaVirtualMachines[i].displayVersion = String(highestVersion)
            }
        }
    }
    
    public static func search() async throws -> [JavaVirtualMachine] {
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
        return dirs.map { JavaVirtualMachine.of(URL(fileURLWithPath: $0.replacingOccurrences(of: "~", with: FileManager.default.homeDirectoryForCurrentUser.path)).appending(path: "java")) }
    }
    
    private static func isValidJvmDirectory(_ path: URL) -> Bool {
        var isDirectory: ObjCBool = false
        return FileManager.default.fileExists(atPath: toJvmDirectory(path).appending(path: "java").path(), isDirectory: &isDirectory) && !isDirectory.boolValue
    }
    
    private static func toJvmDirectory(_ path: URL) -> URL {
        return path.appending(path: "Contents").appending(path: "Home").appending(path: "bin")
    }
}
