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
            if SharedConstants.shared.isDevelopment {
                StaticMyCardComponent(title: "警告") {
                    VStack(spacing: 4) {
                        Text("你正在使用开发版本的 PCL-Mac！")
                            .font(.custom("PCL English", size: 14))
                        HStack {
                            Text("如果遇到问题请")
                                .font(.custom("PCL English", size: 14))
                            Text("点击此处反馈")
                                .font(.custom("PCL English", size: 14))
                                .onTapGesture {
                                    NSWorkspace.shared.open(URL(string: "https://github.com/PCL-Community/PCL-Mac/issues")!)
                                }
                                .foregroundStyle(LocalStorage.shared.theme.getTextStyle())
                        }
                    }
                    .foregroundStyle(Color(hex: 0x343D4A))
                    .padding()
                }
                .padding()
            }
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
                        MyButtonComponent(text: "启动游戏", descriptionText: defaultInstance, foregroundStyle: LocalStorage.shared.theme.getTextStyle()) {
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
