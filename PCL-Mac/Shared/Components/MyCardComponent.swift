//
//  ListComponent.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/18.
//

import SwiftUI

struct MyCardComponent<Content: View>: View {
    let title: String
    let content: () -> Content
    @State private var isHovered: Bool = false
    @State private var isUnfolded: Bool = false
    
    var body: some View {
        VStack {
            ZStack {
                HStack {
                    Text(title)
                        .font(.system(size: 16))
                        .foregroundStyle(isHovered ? Color(hex: 0x0B5BCB) : .black)
                    Spacer()
                    Image("FoldController")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .offset(x: -8, y: 4)
                        .rotationEffect(.degrees(isUnfolded ? 180 : 0), anchor: .center)
                        .foregroundStyle(isHovered ? Color(hex: 0x0B5BCB) : .black)
                }
                Color.clear
                    .frame(height: 20)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.spring(response: 0.2, dampingFraction: 1, blendDuration: 0)) {
                            isUnfolded.toggle()
                        }
                    }
            }
            if isUnfolded {
                content()
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .identity
                    ))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.white)
                .shadow(color: isHovered ? Color(hex: 0x0B5BcB) : .gray, radius: isHovered ? 2 : 2, x: 0.5, y: 0.5)
        )
        .animation(
            .spring(response: 0.2, dampingFraction: 1),
            value: isUnfolded
        )
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onHover { hover in
            isHovered = hover
        }
    }
}

#Preview {
    SettingsView()
        .padding()
        .background(Color(hex: 0xC7D9F0))
}
