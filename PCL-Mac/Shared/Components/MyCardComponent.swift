//
//  ListComponent.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/18.
//

import SwiftUI

struct MyCardComponent<Content: View>: View {
    let title: String
    private let content: Content
    @State private var isHovered: Bool = false
    @State private var isUnfolded: Bool = false
    
    init(title: String, content: @escaping () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack {
            ZStack {
                HStack {
                    Text(title)
                        .font(.custom("PCL English", size: 14))
                    Spacer()
                    Image("FoldController")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .offset(x: -8, y: 4)
                        .rotationEffect(.degrees(isUnfolded ? 180 : 0), anchor: .center)
                }
                .foregroundStyle(isHovered ? Color(hex: 0x0B5BCB) : .black)
                
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isUnfolded.toggle()
                        }
                    }
            }
            .frame(maxHeight: 9)
            if isUnfolded {
                content
                    .frame(maxHeight: isUnfolded ? .greatestFiniteMagnitude : 0)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.white)
                .shadow(color: isHovered ? Color(hex: 0x0B5BcB) : .gray, radius: isHovered ? 2 : 2, x: 0.5, y: 0.5)
        )
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onHover { hover in
            isHovered = hover
        }
    }
}

struct StaticMyCardComponent<Content: View>: View {
    let title: String
    let content: () -> Content
    @State private var isHovered: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .font(.custom("PCL English", size: 14))
                    .foregroundStyle(isHovered ? Color(hex: 0x0B5BCB) : .black)
                Spacer()
            }
            content()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.white)
                .shadow(color: isHovered ? Color(hex: 0x0B5BcB) : .gray, radius: isHovered ? 2 : 2, x: 0.5, y: 0.5)
        )
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onHover { hover in
            isHovered = hover
        }
    }
}

struct TitlelessMyCardComponent<Content: View>: View {
    let content: () -> Content
    @State private var isHovered: Bool = false
    
    var body: some View {
        VStack {
            content()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.white)
                .shadow(color: isHovered ? Color(hex: 0x0B5BcB) : .gray, radius: isHovered ? 2 : 2, x: 0.5, y: 0.5)
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
