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
        HStack {
            VStack {
                Text("Java \(jvm.version) (\(jvm.displayVersion)) \(jvm.arch) 运行方式: \(jvm.callMethod.getDisplayName() + (jvm.isAddedByUser ? "(自定义)" : ""))\n\(jvm.executableUrl.path())")
            }
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(Color(hex: 0xCFCFCF, alpha: 0.5))
        )
    }
}


#Preview {
    SettingsView()
}
