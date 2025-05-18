//
//  SettingsView.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/18.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack {
            MyCardComponent(title: "测试卡片") {
                VStack {
                    Text("文本1")
                    Button("按钮1") {
                        
                    }
                }
            }
            .frame(width: 400)
            .foregroundStyle(.black)
        }
    }
}
