//
//  JavaEntityComponent.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/19.
//

import SwiftUI

struct JavaEntityComponent: View {
    let javaEntity: JavaVirtualMachine
    
    var body: some View {
        HStack {
            VStack {
                Text("Java \(javaEntity.version) (\(javaEntity.displayVersion)) \(javaEntity.arch) 运行方式: \(javaEntity.callMethod.getDisplayName())\n\(javaEntity.executableUrl!.path())")
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
