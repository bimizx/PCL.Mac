//
//  ButtonComponent.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/19.
//

import SwiftUI

struct MyButtonComponent: View {
    let text: String
    let action: () -> Void
    @State private var isHovered: Bool = false
    @State private var isPressed: Bool = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .stroke(isHovered ? Color(hex: 0x1370F3) : Color(hex: 0x343D4A), lineWidth: 1.3)
            RoundedRectangle(cornerRadius: 6)
                .foregroundStyle(Color(hex: 0xFFFFFF, alpha: isHovered ? 0.5 : 0.3))
            Text(text)
                .foregroundStyle(isHovered ? Color(hex: 0x1370F3) : Color(hex: 0x343D4A))
        }
        .onHover {
            isHovered = $0
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed {
                        action()
                    }
                    isPressed = true
                }
                .onEnded { _ in isPressed = false }
        )
        .scaleEffect(isPressed ? 0.85 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .animation(.easeInOut(duration: 0.2), value: isPressed)
    }
}


#Preview {
    MyButtonComponent(text: "测试") { }
        .padding()
        .background(Color(hex: 0xC4CEE6))
}
