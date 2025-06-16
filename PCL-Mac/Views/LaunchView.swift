//
//  MainView.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/18.
//

import SwiftUI

fileprivate struct LeftTab: View {
    @ObservedObject private var dataManager: DataManager = DataManager.shared
    
    @State private var instance: MinecraftInstance?
    
    var body: some View {
        VStack {
            Spacer()
            Text("PCL_Mac")
                .font(.custom("PCL English", size: 16))
            Spacer()
            if let defaultInstance = LocalStorage.shared.defaultInstance,
               let instance = MinecraftInstance.create(runningDirectory: URL(fileURLWithUserPath: "~/PCL-Mac-minecraft/versions/\(defaultInstance)")) {
                MyButtonComponent(text: "启动游戏", descriptionText: defaultInstance, foregroundStyle: LocalStorage.shared.theme.getTextStyle()) {
                    if self.instance == nil {
                        self.instance = instance
                    }
                    
                    if self.instance!.process == nil {
                        Task {
                            await self.instance!.launch()
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

struct LaunchView: View {
    @ObservedObject private var dataManager: DataManager = DataManager.shared
    
    var body: some View {
        ScrollView {
            if SharedConstants.shared.isDevelopment {
                StaticMyCardComponent(title: "警告") {
                    VStack(spacing: 4) {
                        Text("你正在使用开发版本的 PCL-Mac！")
                            .font(.custom("PCL English", size: 14))
                        HStack(spacing: 4) {
                            Text("如果遇到问题请")
                                .font(.custom("PCL English", size: 14))
                            Text("点击此处反馈")
                                .font(.custom("PCL English", size: 14))
                                .onTapGesture {
                                    NSWorkspace.shared.open(URL(string: "https://github.com/PCL-Community/PCL-Mac/issues/new?template=bug-反馈.md")!)
                                }
                                .foregroundStyle(LocalStorage.shared.theme.getTextStyle())
                        }
                    }
                    .foregroundStyle(Color(hex: 0x343D4A))
                }
                .padding()
                
                StaticMyCardComponent(title: "日志") {
                    VStack {
                        ScrollView(.horizontal) {
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(LogStore.shared.logLines) { logLine in
                                    logLineView(logLine.string)
                                }
                            }
                        }
                        .scrollIndicators(.never)
                        .padding(.top, 5)
                        
                        MyButtonComponent(text: "打开日志") {
                            NSWorkspace.shared.activateFileViewerSelecting([SharedConstants.shared.applicationLogUrl])
                        }
                        .frame(height: 40)
                    }
                }
                .padding()
            }
            Spacer()
        }
        .scrollIndicators(.automatic)
        .onAppear {
            dataManager.leftTab(310) {
                LeftTab()
            }
        }
    }
    
    @ViewBuilder
    func logLineView(_ line: String) -> some View {
        let regex = #"\[(INFO|WARN|ERROR|DEBUG)\]"#
        let nsLine = line as NSString
        if let match = try? NSRegularExpression(pattern: regex)
            .firstMatch(in: line, range: NSRange(location: 0, length: nsLine.length)),
           let levelRange = Range(match.range(at: 1), in: line),
           let tagRange = Range(match.range(at: 0), in: line)
        {
            let level = String(line[levelRange])
            let tag = String(line[tagRange])
            let rest = String(line[tagRange.upperBound...])
            let color: Color = {
                switch level {
                    case "INFO": return .green
                    case "WARN": return .yellow
                    case "ERROR": return .red
                    case "DEBUG": return .blue
                    default: return .primary
                }
            }()

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(tag)
                    .font(.custom("PCL English", size: 14))
                    .foregroundColor(color)
                Text(rest)
                    .font(.custom("PCL English", size: 14))
            }
        } else {
            HStack {
                Text(line)
                    .font(.custom("PCL English", size: 14))
            }
        }
    }
}
