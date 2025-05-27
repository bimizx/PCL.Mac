//
//  MainView.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/18.
//

import SwiftUI

struct LauncherView: View {
    var body: some View {
        HStack {
            ZStack {
                VStack {
                    Spacer()
                    MyButtonComponent(text: "启动游戏", descriptionText: "1.14", foregroundStyle: Color(hex: 0x0A54CA)) {
                        Task {
                            let version = "1.14"
                            let versionUrl = URL(fileURLWithUserPath: "~/PCL-Mac-minecraft/versions/\(version)")
                            let instance = MinecraftInstance(runningDirectory: versionUrl, version: ReleaseMinecraftVersion.fromString(version)!, MinecraftConfig(name: "Test", javaPath: "/usr/bin/java"))
                            await instance!.run()
                        }
                    }
                    .frame(width: 280, height: 60)
                    .padding()
                }
                .background(
                    Rectangle()
                    .fill(.white)
                    .frame(width: 310)
                )
            }
            VStack {
                MyButtonComponent(text: "测试弹出框") {
                    ContentView.setPopup(PopupOverlay("测试", "这是一行文本\n这也是一行文本\n这是一行很\(String(repeating: "长", count: 50))的文本", [.Ok]))
                }
                .frame(height: 40)
                .padding()
                Spacer()
            }
        }
    }
}
