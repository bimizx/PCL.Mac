//
//  InstallingView.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/29.
//

import SwiftUI

struct InstallingView: View {
    @ObservedObject private var dataManager: DataManager = DataManager.shared
    @ObservedObject var task: InstallTask
    
    var body: some View {
        HStack {
            VStack {
                StaticMyCardComponent(title: "\(task.minecraftVersion.getDisplayName()) 安装") {
                    getEntries()
                }
                .padding()
                Spacer()
            }
        }
        .onChange(of: task.stage) { stage in
            if stage == .end {
                DataManager.shared.router.removeLast()
                DataManager.shared.clearInstallingView()
            }
        }
        .onAppear {
            dataManager.leftTab(220) {
                VStack {
                    Spacer()
                    PanelView(title: "总进度", value: "0.0 %")
                    PanelView(title: "下载速度", value: "114514 GB/s")
                    PanelView(title: "剩余文件", value: "∞")
                    Spacer()
                }
                .padding()
                .padding(.top, 10)
            }
        }
    }
    
    private func getEntries() -> some View {
        return VStack {
            ForEach(Array(task.getInstallStates()).sorted(by: { $0.key.rawValue < $1.key.rawValue }), id: \.key) { stage, state in
                HStack {
                    if state == .inprogress {
                        Text("0%")
                            .font(.custom("PCL English", size: 14))
                            .foregroundStyle(Color(hex: 0x1370F3))
                            .padding(EdgeInsets(top: 6, leading: 18, bottom: 6, trailing: 0))
                    } else {
                        Image(state.getImageName())
                            .resizable()
                            .scaledToFit()
                            .frame(width: 15)
                            .foregroundStyle(Color(hex: 0x1370F3))
                            .padding(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 10))
                    }
                    Text(stage.getDisplayName())
                        .font(.custom("PCL English", size: 14))
                        .foregroundStyle(Color(hex: 0x343D4A))
                    Spacer()
                }
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
                .foregroundStyle(Color(hex: 0x343D4A))
        }
        .padding(.top, 20)
        .padding(.bottom, 20)
    }
}

#Preview {
    InstallingView(task: MinecraftInstaller.createTask(ReleaseMinecraftVersion.fromString("1.21.5")!))
}
