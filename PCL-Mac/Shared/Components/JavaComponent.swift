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
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(jvm.getTypeLabel()) \(jvm.displayVersion)")
                        .font(.custom("PCL English", size: 16))
                        .padding(.leading, 2)
                    HStack {
                        if let implementor = jvm.implementor {
                            MyTagComponent(label: implementor, backgroundColor: Color("TagColor"), fontSize: 12)
                        }
                        MyTagComponent(label: String(describing: jvm.arch), backgroundColor: Color("TagColor"), fontSize: 12)
                        MyTagComponent(label: jvm.callMethod.getDisplayName(), backgroundColor: Color("TagColor"), fontSize: 12)
                    }
                    .foregroundStyle(Color(hex: 0x8C8C8C))
                    Text(jvm.executableUrl.path)
                        .font(.custom("PCL English", size: 14))
                        .textSelection(.enabled)
                        .foregroundStyle(Color(hex: 0x8C8C8C))
                }
                Spacer()
                if jvm.isAddedByUser {
                    Image(systemName: "trash")
                        .onTapGesture {
                            AppSettings.shared.userAddedJvmPaths.removeAll { $0 == jvm.executableUrl }
                            do {
                                try JavaSearch.searchAndSet()
                            } catch {
                                err("在删除手动添加的 Java 并刷新 Java 列表时发生错误: \(error)")
                            }
                        }
                }
            }
            .padding(5)
        }
    }
}


#Preview {
    SettingsView()
}
