//
//  MinecraftLauncher.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/20.
//

import Foundation

public class MinecraftLauncher {
    public static func launch(_ instance: MinecraftInstance) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/java")
        process.environment = ProcessInfo.processInfo.environment
        process.arguments = []
        process.arguments!.append(contentsOf: buildJvmArguments(instance))
        process.arguments!.append(instance.manifest.mainClass)
        process.arguments!.append(contentsOf: buildGameArguments(instance))
        debug(process.arguments!.joined(separator: " "))
        process.currentDirectoryURL = instance.runningDirectory
        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            err(error.localizedDescription)
        }
    }
    
    private static func buildJvmArguments(_ instance: MinecraftInstance) -> [String] {
        let values: [String: String] = [
            "natives_directory": instance.runningDirectory.appending(path: "natives").path(),
            "launcher_name": "\"PCL Mac\"",
            "launcher_version": "1.0.0",
            "classpath": buildClasspath(instance)
        ]
        
        var args: [String] = [
            "-Dorg.lwjgl.util.Debug=true"
        ]
        args.append(contentsOf: replaceTemplateStrings(instance.manifest.arguments.getAllowedJVMArguments(), with: values))
        return args
    }
    
    private static func buildClasspath(_ instance: MinecraftInstance) -> String {
        var urls: [String] = []
        
        instance.manifest.getNeededLibraries().forEach { library in
            urls.append(instance.runningDirectory.parent().parent().appending(path: "libraries").appending(path: library.getArtifact().path).path())
        }
        
        instance.manifest.getNeededNatives().forEach { artifact in
            urls.append(instance.runningDirectory.parent().parent().appending(path: "libraries").appending(path: artifact.path).path())
        }
        
        urls.append(instance.runningDirectory.appending(path: instance.version.getDisplayName() + ".jar").path())
        
        return urls.joined(separator: ":")
    }
    
    private static func buildGameArguments(_ instance: MinecraftInstance) -> [String] {
        let values: [String: String] = [
            "auth_player_name": "PCL_Mac",
            "version_name": instance.version.getDisplayName(),
            "game_directory": instance.runningDirectory.path(),
            "assets_root": instance.runningDirectory.parent().parent().appending(path: "assets").path(),
            "assets_index_name": instance.manifest.assetIndex.id,
            "auth_uuid": "a256e7ba1da830119b633a974279e906",
            "auth_access_token": "9856e9a933b5421cb6cf38f21553bd54",
            "user_type": "msa",
            "version_type": "\"PCL Mac\""
        ]
        
//        return instance.manifest.arguments.getAllowedGameArguments().map { arg in
//            let startIndex = arg.index(arg.startIndex, offsetBy: 2)
//            let endIndex = arg.index(arg.endIndex, offsetBy: -1)
//            let range = startIndex..<endIndex
//            return values[String(arg[range])] ?? arg
//        }
        return replaceTemplateStrings(instance.manifest.arguments.getAllowedGameArguments(), with: values)
    }
    
    private static func replaceTemplateStrings(_ strings: [String], with dict: [String: String]) -> [String] {
        return strings.map { original in
            var result = original
            for (key, value) in dict {
                result = result.replacingOccurrences(
                    of: "${\(key)}",
                    with: value
                )
            }
            return result
        }
    }
}
