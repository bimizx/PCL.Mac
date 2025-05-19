//
//  SettingsView.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/18.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var dataManager = DataManager.shared
    
    var body: some View {
        HStack {
            Rectangle()
                .fill(.white)
                .frame(width: 200)
            ScrollView(.vertical, showsIndicators: true) {
                VStack {
                    MyButtonComponent(text: "刷新Java列表") {
                        Task {
                            do {
                                try await JavaSearch.searchAndSet()
                            } catch {
                                print("无法刷新Java列表: \(error)")
                            }
                        }
                    }
                    .frame(height: 45)
                    .padding()
                    MyCardComponent(title: "Java 列表") {
                        VStack {
                            Text("搜索耗时: \(dataManager.lastTimeUsed)ms")
                                .font(.system(size: 14))
                            ForEach(dataManager.javaVirtualMachines) { javaEntity in
                                JavaEntityComponent(javaEntity: javaEntity)
                            }
                        }
                    }
                    .padding()
                    .foregroundStyle(.black)
                }
            }
        }
        .onAppear {
            if dataManager.javaVirtualMachines.isEmpty {
                Task {
                    do {
                        try await JavaSearch.searchAndSet()
                    } catch { }
                }
            }
        }
    }
}
