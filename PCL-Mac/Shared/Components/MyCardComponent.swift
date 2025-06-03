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
    @State private var unfoldDuration: Double = 0.3

    let unfoldSpeed: CGFloat = 3000 // 每秒展开300pt
    let headerHeight: CGFloat = 36 // 头部高度，可以根据实际调整
    let paddingValue: CGFloat = 16 // 上下padding合计

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
                .foregroundStyle(isHovered ? AnyShapeStyle(LocalStorage.shared.theme.getBackgroundStyle()) : AnyShapeStyle(.black))
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        let before = !showContent
                        if before {
                            showContent.toggle()
                        }
                        // 箭头动画
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isUnfolded.toggle()
                        }
                        // 内容动画
                        let duration = max(Double(contentHeight / unfoldSpeed), 0.18)
                        unfoldDuration = duration
                        if !before {
                            DispatchQueue.main.asyncAfter(deadline: .now() + duration * 0.67) {
                                showContent.toggle()
                            }
                        }
                    }
            }
            .frame(height: headerHeight)

            ZStack(alignment: .top) {
                content
                    .background(
                        GeometryReader { proxy in
                            Color.clear
                                .preference(key: ContentHeightKey.self, value: proxy.size.height)
                        }
                    )
                    .opacity(showContent ? 1 : 0)
            }
            .frame(height: isUnfolded ? contentHeight : 0, alignment: .top)
            .clipped()
            .padding(.top, showContent ? 10 : 0)
        }
        .padding(.vertical, paddingValue / 2)
        .padding(.horizontal)
        .frame(
            height: headerHeight
                + (isUnfolded ? contentHeight : 0)
                + (showContent ? 10 : 0)
                + paddingValue // 额外padding
        )
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.white)
                .shadow(color: isHovered ? Color(hex: 0x0B5BCB) : .gray, radius: 2, x: 0.5, y: 0.5)
        )
        .animation(.easeInOut(duration: unfoldDuration), value: isUnfolded)
        .animation(.easeInOut(duration: unfoldDuration), value: contentHeight)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onHover { hover in
            isHovered = hover
        }
        .onPreferenceChange(ContentHeightKey.self) { h in
            if h > 0 {
                contentHeight = h
                unfoldDuration = max(Double(h / unfoldSpeed), 0.18)
            }
        }
    }
}

fileprivate struct ContentHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
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
                    .foregroundStyle(isHovered ? AnyShapeStyle(LocalStorage.shared.theme.getBackgroundStyle()) : AnyShapeStyle(.black))
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
