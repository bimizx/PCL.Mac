//
//  MyListItem.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/6/20.
//

import SwiftUI

struct MyListItemComponent<Content: View>: View {
    let content: () -> Content
    
    @State private var isHovered: Bool = false
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        content()
            .contentShape(Rectangle())
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(isHovered ? Color(hex: 0x1370F3, alpha: 0.05) : .clear)
            )
            .animation(.easeInOut(duration: 0.2), value: self.isHovered)
            .onHover { hover in
                self.isHovered = hover
            }
    }
}

#Preview {
    MinecraftDownloadView()
}
