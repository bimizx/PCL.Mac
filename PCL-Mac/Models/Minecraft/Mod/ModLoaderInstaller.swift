//
//  ModLoaderInstaller.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/6/17.
//

/**
 *                             _ooOoo_
 *                            o8888888o
 *                            88" . "88
 *                            (| -_- |)
 *                            O\  =  /O
 *                         ____/`---'\____
 *                       .'  \\|     |//  `.
 *                      /  \\|||  :  |||//  \
 *                     /  _||||| -:- |||||-  \
 *                     |   | \\\  -  /// |   |
 *                     | \_|  ''\---/''  |   |
 *                     \  .-\__  `-`  ___/-. /
 *                   ___`. .'  /--.--\  `. . __
 *                ."" '<  `.___\_<|>_/___.'  >'"".
 *               | | :  `- \`.;`\ _ /`;.`/ - ` : | |
 *               \  \ `-.   \_ __\ /__ _/   .-` /  /
 *          ======`-.____`-.___\_____/___.-`____.-'======
 *                             `=---='
 *          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
*/

import Foundation

public class ModLoaderInstaller {
    public static func installFabric(_ instance: MinecraftInstance, _ loaderVersion: String) async {
        if let data = await Requests.get(
            url: URL(string: "https://meta.fabricmc.net/v2/versions/loader/\(instance.version.displayName)")!
        ),
           let manifests = try? FabricManifest.parse(data) {
            guard let manifest = manifests.find({ $0.loaderVersion == loaderVersion }) else {
                err("找不到对应的 Fabric Loader 版本: \(loaderVersion)")
                return
            }
            await withCheckedContinuation { continuation in
                let downloader = ProgressiveDownloader(
                    urls: manifest.libraryUrls,
                    destinations: manifest.libraries.map { instance.minecraftDirectory.librariesUrl.appending(path: $0)},
                    skipIfExists: true,
                    completion: continuation.resume
                )
                downloader.start()
            }
            
            for library in manifest.libraryCoords {
                instance.config.additionalLibraries.insert(library)
            }
            instance.config.mainClass = manifest.mainClass
            instance.saveConfig()
        }
    }
}
