//
//  SettingsView.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/18.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        HStack {
            Rectangle()
                .fill(.white)
                .frame(width: 200)
            ScrollView(.vertical, showsIndicators: true) {
                VStack {
                    MyCardComponent(title: "Java 列表") {
                        VStack {
                            Text("搜索耗时: \(JavaSearch.lastTimeUsed)ms")
                                .font(.system(size: 14))
                            ForEach(JavaSearch.JavaVirtualMachines) { javaEntity in
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
            if JavaSearch.JavaVirtualMachines.isEmpty {
                Task {
                    do {
                        try await JavaSearch.searchAndSet()
                    } catch { }
                }
            }
        }
    }
}
