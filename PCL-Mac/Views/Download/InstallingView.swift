//
//  InstallingView.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/29.
//

import SwiftUI

struct InstallingView: View {
    private struct LeftTabView: View {
        @ObservedObject private var dataManager: DataManager = DataManager.shared
        @ObservedObject private(set) var task: InstallTask
        var body: some View {
            VStack {
                Spacer()
                PanelView(
                    title: "总进度",
                    value: task.totalFiles == -1 ? "未知" : String(format: "%.1f %%", task.getProgress() * 100)
                )
                PanelView(
                    title: "下载速度",
                    value: "\(formatSpeed(dataManager.downloadSpeed))"
                )
                PanelView(
                    title: "剩余文件",
                    value: task.totalFiles == -1 ? "未知" : String(describing: task.remainingFiles)
                )
                Spacer()
            }
            .padding()
            .padding(.top, 10)
        }
        
        func formatSpeed(_ speed: Double) -> String {
            let units = ["B/s", "KB/s", "MB/s", "GB/s", "TB/s"]
            var value = speed
            var unitIndex = 0

            while value >= 1024 && unitIndex < units.count - 1 {
                value /= 1024
                unitIndex += 1
            }

            let formatted = String(format: value < 10 && unitIndex > 0 ? "%.1f" : "%.0f", value)
            return "\(formatted) \(units[unitIndex])"
        }
    }
    
    @ObservedObject private var dataManager: DataManager = DataManager.shared
    @ObservedObject var task: InstallTask
    
    var body: some View {
        HStack {
            VStack {
                StaticMyCardComponent(title: "\(task.minecraftVersion.displayName) 安装") {
                    getEntries()
                }
                .padding()
                Spacer()
            }
        }
        .onAppear {
            dataManager.leftTab(220) {
                LeftTabView(task: task)
            }
        }
    }
    
    private func getEntries() -> some View {
        return VStack {
            ForEach(Array(task.getInstallStates()).sorted(by: { $0.key.rawValue < $1.key.rawValue }), id: \.key) { stage, state in
                HStack {
                    if state == .inprogress {
                        Text(String(format: "%.0f%%", dataManager.currentStagePercentage * 100))
                            .font(.custom("PCL English", size: 14))
                            .foregroundStyle(Color(hex: 0x1370F3))
                            .padding(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 10))
                    } else {
                        Image(state.getImageName())
                            .foregroundStyle(Color(hex: 0x1370F3))
                            .padding(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 10))
                    }
                    Text(stage.getDisplayName())
                        .font(.custom("PCL English", size: 14))
                        .foregroundStyle(Color("TextColor"))
                    Spacer()
                }
                .frame(height: 20)
            }
        }
    }
}

private struct PanelView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.custom("PCL English", size: 16))
                .foregroundStyle(Color(hex: 0x1370F3))
            Rectangle()
                .fill(Color(hex: 0x1370F3))
                .frame(width: 180, height: 2)
            Text(value)
                .font(.custom("PCL English", size: 20))
                .foregroundStyle(Color("TextColor"))
        }
        .padding(.top, 20)
        .padding(.bottom, 20)
    }
}

#Preview {
    InstallingView(task: MinecraftInstaller.createTask(MinecraftVersion(displayName: "1.21.5"), "测试", MinecraftDirectory(rootUrl: URL(fileURLWithUserPath: "~/PCL-Mac-minecraft"))))
}
