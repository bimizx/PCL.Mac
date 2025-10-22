//
//  InstanceConfigView.swift
//  PCL.Mac
//
//  Created by YiZhiMCQiu on 2025/7/31.
//

import SwiftUI

struct InstanceConfigView: View {
    @State var instance: MinecraftInstance
    @State private var memoryText: String
    
    init(instance: MinecraftInstance) {
        self.instance = instance
        self.memoryText = String(instance.config.maxMemory)
    }
    
    var body: some View {
        ScrollView {
            StaticMyCard(title: "进程设置") {
                VStack(alignment: .leading) {
                    HStack {
                        Text("游戏内存")
                        MyTextField(text: $memoryText, numberOnly: true)
                            .onChange(of: memoryText) { _ in
                                if let intValue = Int(memoryText) {
                                    instance.config.maxMemory = Int32(intValue)
                                    instance.saveConfig()
                                }
                            }
                        Text("MB")
                    }
                    VStack(spacing: 2) {
                        HStack {
                            Text("进程优先级")
                            MyPicker(
                                selected: $instance.config.processPriority,
                                entries: ProcessPriority.allCases,
                                textProvider: getPriorityName(_:)
                            )
                            .onChange(of: instance.config.processPriority) { _ in
                                instance.saveConfig()
                            }
                        }
                    }
                }
                .padding()
            }
            .padding()
        }
        .font(.custom("PCL English", size: 14))
        .scrollIndicators(.never)
    }
    
    private func getPriorityName(_ priority: ProcessPriority) -> String {
        switch priority {
        case .veryHigh:
            "极高"
        case .high:
            "高"
        case .default:
            "默认"
        case .low:
            "低"
        case .veryLow:
            "极低"
        }
    }
}
