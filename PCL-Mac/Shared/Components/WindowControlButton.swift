//
//  WindowControlButton.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/17.
//

import SwiftUI

struct WindowControlCloseButton: View {
    @State private var isHovered = false
    
    var body: some View {
        VStack {
            Image(systemName: "xmark")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 13)
                .bold()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(isHovered ? Color(hex: 0x3F89D1) : Color.clear)
                        .animation(.easeInOut(duration: 0.2), value: isHovered)
                        .frame(width: 30, height: 30)
                )
        }
        .frame(width: 30, height: 30)
        .onHover { hover in
            isHovered = hover
        }
        .onTapGesture {
            NSApplication.shared.terminate(self)
        }
    }
}

struct WindowControlMinusButton: View {
    @State private var isHovered = false
    
    var body: some View {
        VStack {
            Image(systemName: "minus")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 13)
                .bold()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(isHovered ? Color(hex: 0x3F89D1) : Color.clear)
                        .animation(.easeInOut(duration: 0.2), value: isHovered)
                        .frame(width: 30, height: 30)
                )
        }
        .frame(width: 30, height: 30)
        .onHover { hover in
            isHovered = hover
        }
        .onTapGesture {
            NSApplication.shared.windows.first?.miniaturize(self)
        }
    }
}
