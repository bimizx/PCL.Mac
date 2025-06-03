//
//  OthersView.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/18.
//

import SwiftUI

struct OthersView: View {
    @ObservedObject private var dataManager: DataManager = .shared
    
    var body: some View {
        VStack {
            MyButtonComponent(text: "测试弹出框") {
                ContentView.setPopup(PopupOverlay("测试", "这是一行文本\n这也是一行文本\n这是一行很\(String(repeating: "长", count: 50))的文本", [.Ok]))
            }
            .frame(height: 40)
            .padding()
            .padding(.bottom, -23)
            MyButtonComponent(text: "测试主题更换") {
                LocalStorage.shared.theme = LocalStorage.shared.theme == .colorful ? .pcl : .colorful
                DataManager.shared.objectWillChange.send()
            }
            .frame(height: 40)
            .padding()
            .padding(.bottom, -23)
            Spacer()
        }
        .onAppear {
            dataManager.leftTab(0) { EmptyView() }
        }
    }
}
