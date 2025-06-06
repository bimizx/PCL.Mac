//
//  JavaSearch.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/18.
//

// 不改了，能跑就不要动
//          by YiZhiMCQiu at 2025/6/6 in fix & optimizations (1)
import Foundation

public class JavaSearch {
    public static var highestVersion: Int!
    
    public static func searchAndSet() throws {
        let before = Date().timeIntervalSince1970
        DataManager.shared.javaVirtualMachines = try search()
        DataManager.shared.lastTimeUsed = Int((Date().timeIntervalSince1970 - before) * 1000)
        log("搜索 Java 耗时 \(DataManager.shared.lastTimeUsed)ms")
        highestVersion = DataManager.shared.javaVirtualMachines.sorted { jvm1, jvm2 in
            return jvm1.version > jvm2.version
        }[0].version
        
        if var java = DataManager.shared.javaVirtualMachines.find ({ $0.executableUrl.path == "/usr/bin/java" }) {
            java.version = highestVersion
            java.displayVersion = String(highestVersion)
        }
        
        loadCustomJVMs()
    }
    
    private static func loadCustomJVMs() {
        LocalStorage.shared.userAddedJvmPaths.forEach{ DataManager.shared.javaVirtualMachines.append(JavaVirtualMachine.of($0, true)) }
        log("加载了 \(LocalStorage.shared.userAddedJvmPaths.count) 个由用户添加的 Java")
    }
    
    public static func search() throws -> [JavaVirtualMachine] {
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
