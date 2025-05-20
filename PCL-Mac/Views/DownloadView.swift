//
//  DownloadView.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/18.
//

import SwiftUI

struct DownloadView: View {
    @ObservedObject private var currentTask: DownloadTask = MinecraftDownloader.createTask(URL(fileURLWithUserPath: "~/PCL-Mac-minecraft/versions/1.15"), "1.15")
    
    var body: some View {
        VStack {
            Text(String(format: "进度: %.2f%%", (1 - Double(currentTask.remainingFiles) / Double(currentTask.totalFiles)) * 100))
            Text("剩余: \(currentTask.remainingFiles) / \(currentTask.totalFiles)")
            Text("当前阶段: \(currentTask.stage.getDisplayName())")
            MyButtonComponent(text: "启动任务") {
                if currentTask.stage == .before {
                    currentTask.start()
                }
            }
            .frame(height: 40)
            .padding()
        }
    }
}
