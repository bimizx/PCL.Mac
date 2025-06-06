//
//  ListComponent.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/18.
//

import SwiftUI

struct MyCardComponent<Content: View>: View {
    @ObservedObject private var dataManager: DataManager = DataManager.shared
    
    let title: String
    private let content: Content
    @State private var isHovered: Bool = false
    @State private var isUnfolded: Bool = false
    @State private var showContent: Bool = false
    @State private var contentHeight: CGFloat = .zero
    @State private var unfoldDuration: Double = 0.2

    init(title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
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
                        .animation(.easeInOut(duration: 0.2), value: isUnfolded)
                }
                .foregroundStyle(isHovered ? AnyShapeStyle(LocalStorage.shared.theme.getTextStyle()) : AnyShapeStyle(.black))
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        
                    }
                
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(.white)
            )
            .onHover { hover in
                isHovered = hover
            }
        }
    }
}

struct StaticMyCardComponent<Content: View>: View {
    @ObservedObject private var dataManager: DataManager = DataManager.shared
    
    let title: String
    let content: () -> Content
    @State private var isHovered: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .font(.custom("PCL English", size: 14))
                    .foregroundStyle(isHovered ? AnyShapeStyle(LocalStorage.shared.theme.getTextStyle()) : AnyShapeStyle(.black))
                Spacer()
            }
            content()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.white)
                .shadow(color: isHovered ? Color(hex: 0x0B5BCB) : .gray, radius: isHovered ? 2 : 2, x: 0.5, y: 0.5)
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
                .shadow(color: isHovered ? Color(hex: 0x0B5BCB) : .gray, radius: isHovered ? 2 : 2, x: 0.5, y: 0.5)
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
