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
        debug(process.arguments!.joined(separator: " "))
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
        return [
            "--username", "PCL_Mac",
            "--version", instance.version.getDisplayName(),
            "--gameDir", instance.runningDirectory.path(),
            "--assetsDir", instance.runningDirectory.parent().parent().appending(path: "assets").path(),
            "--assetIndex", instance.manifest.assetIndex.id,
            "--uuid", "a256e7ba1da830119b633a974279e906",
            "--accessToken", "9856e9a933b5421cb6cf38f21553bd54",
            "--clientId", "\"\\${clientid}\"",
            "--xuid", "\"\\${auth_xuid}\"",
            "--userType msa",
            "--versionType", "PCL-Mac",
            "--width", "854", "--height", "480"
        ]
    }
}
