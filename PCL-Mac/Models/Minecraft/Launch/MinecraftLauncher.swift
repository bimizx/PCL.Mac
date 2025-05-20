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
        process.arguments!.append(contentsOf: buildGameArguments(instance))
        process.currentDirectoryURL = instance.runningDirectory
        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            err(error.localizedDescription)
        }
    }
    
    private static func buildJvmArguments(_ instance: MinecraftInstance) -> [String] {
        return [
            "-Dlog4j.configurationFile=\(instance.runningDirectory.appending(path: "log4j2.xml").path())",
            "-XstartOnFirstThread",
            "-cp", instance.manifest.getNeededLibrary().map { library in
                return instance.runningDirectory.parent().parent().appending(path: "libraries")
                    .appending(path: library.getArtifact().path).path()
            }.joined(separator: ":") + ":" +
            instance.runningDirectory.appending(path: instance.version.getDisplayName() + ".jar").path(),
            instance.manifest.mainClass
        ]
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
        
        return instance.manifest.arguments.getAllowedGameArguments().map { arg in
            let startIndex = arg.index(arg.startIndex, offsetBy: 2)
            let endIndex = arg.index(arg.endIndex, offsetBy: -1)
            let range = startIndex..<endIndex
            return values[String(arg[range])] ?? arg
        }
    }
}
