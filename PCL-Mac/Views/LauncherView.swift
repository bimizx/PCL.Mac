//
//  MainView.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/18.
//

import SwiftUI

struct LauncherView: View {
    @ObservedObject private var dataManager: DataManager = DataManager.shared
    
    @State private var instance: MinecraftInstance?
    
    var body: some View {
        VStack {
            MyButtonComponent(text: "测试弹出框") {
                ContentView.setPopup(PopupOverlay("测试", "这是一行文本\n这也是一行文本\n这是一行很\(String(repeating: "长", count: 50))的文本", [.Ok]))
            }
            .frame(height: 40)
            .padding()
            Spacer()
        }
        .onAppear {
            dataManager.leftTab(310) {
                VStack {
                    Spacer()
                    Text("YiZhiMCQiu")
                        .font(.custom("PCL English", size: 16))
                    Spacer()
                    if let defaultInstance = LocalStorage.shared.defaultInstance,
                       let instance = MinecraftInstance(runningDirectory: URL(fileURLWithUserPath: "~/PCL-Mac-minecraft/versions/\(defaultInstance)")) {
                        MyButtonComponent(text: "启动游戏", descriptionText: defaultInstance, foregroundStyle: Color(hex: 0x0A54CA)) {
                            if self.instance == nil {
                                self.instance = instance
                            }
                            
                            if self.instance!.process == nil {
                                Task {
                                    await self.instance!.run()
                                }
                            }
                        }
                        .frame(width: 280, height: 55)
                        .padding()
                        .padding(.bottom, -27)
                    } else {
                        MyButtonComponent(text: "下载游戏", descriptionText: "未找到可用的游戏版本") {
                            dataManager.router.setRoot(.download)
                        }
                        .frame(width: 280, height: 55)
                        .padding()
                        .padding(.bottom, -27)
                    }
                    HStack {
                        MyButtonComponent(text: "版本选择") {
                            dataManager.router.append(.versionList)
                        }
                        .frame(width: LocalStorage.shared.defaultInstance == nil ? 280 : 135, height: 35)
                        .padding(.leading, LocalStorage.shared.defaultInstance == nil ? 0 : 10)
                        if LocalStorage.shared.defaultInstance != nil {
                            Spacer()
                            MyButtonComponent(text: "版本设置") {
                                
                            }
                            .frame(width: 135, height: 35)
                            .padding(.trailing, 10)
                        }
                    }
                    .frame(width: 300, height: 60)
                }
                .foregroundStyle(Color(hex: 0x343D4A))
            }
        }
    }
}
