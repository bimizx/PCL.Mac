//
//  JavaEntityComponent.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/19.
//

import SwiftUI

struct JavaComponent: View {
    let jvm: JavaVirtualMachine
    
    var body: some View {
        MyListItemComponent {
            HStack {
                VStack(alignment: .leading) {
                    Text("Java \(jvm.version) (\(jvm.displayVersion)) \(jvm.implementor) \(jvm.arch) 运行方式: \(jvm.callMethod.getDisplayName())")
                        .font(.custom("PCL English", size: 14))
                    Text(jvm.executableUrl.path)
                        .font(.custom("PCL English", size: 14))
                }
                Spacer()
                if jvm.isAddedByUser {
                    Image(systemName: "trash")
                        .onTapGesture {
                            LocalStorage.shared.userAddedJvmPaths.removeAll { $0 == jvm.executableUrl }
                            do {
                                try JavaSearch.searchAndSet()
                            } catch {
                                err("在删除手动添加的 Java 并刷新 Java 列表时发生错误: \(error)")
                            }
                        }
                }
            }
            .padding()
        }
    }
}


#Preview {
    SettingsView()
}
