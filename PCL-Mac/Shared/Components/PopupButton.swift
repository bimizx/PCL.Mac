//
//  PopupButton.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/19.
//

import SwiftUI
import AppKit

struct PopupButton: View, Identifiable {
    @State private var isHovered = false
    
    let id = UUID()
    let text: String
    let color: Color?
    let onClick: () -> Void
    
    init(text: String, color: Color? = nil, onClick: @escaping () -> Void) {
        self.text = text
        self.color = color
        self.onClick = onClick
    }
    
    var body: some View {
        ZStack {
            Text(text)
                .foregroundStyle(color ?? .black)
                .overlay(
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(color ?? .black)
                        .background(
                            Color(hex: 0x000000, alpha: self.isHovered ? 0.1 : 0.0)
                                .onHover { hovering in
                                    self.isHovered = hovering
                                }
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        self.onClick()
                                    }
                                }
                        )
                        .frame(height: 30)
                        .padding(.leading, -10)
                        .padding(.trailing, -10)
                        .frame(minWidth: 0, maxWidth: .infinity)
                )
        }
    }
    
    static let Close = PopupButton(text: "关闭") {
        DataManager.shared.currentPopup = nil
    }
    
    static let Ok = PopupButton(text: "好的") {
        DataManager.shared.currentPopup = nil
    }
}
