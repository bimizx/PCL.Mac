//
//  MyListComponent.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/6/19.
//

import SwiftUI

struct MyListComponent<EnumType, Content: View>: View where EnumType: CaseIterable & Hashable {
    @Binding var selection: EnumType?
    let content: (EnumType, Bool) -> Content
    let cases: [EnumType]
    @State private var indicatorHeight: CGFloat = 24
    @State private var hovering: EnumType? = nil

    init(selection: Binding<EnumType?>, cases: [EnumType] = Array(EnumType.allCases), @ViewBuilder content: @escaping (EnumType, Bool) -> Content) {
        self._selection = selection
        self.cases = cases
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(cases, id: \.self) { item in
                HStack {
                    Group {
                        if selection == item {
                            RoundedRectangle(cornerRadius: 5)
                                .foregroundStyle(AnyShapeStyle(LocalStorage.shared.theme.getTextStyle()))
                        } else {
                            Color.clear
                        }
                    }
                    .frame(width: 4, height: indicatorHeight)
                    
                    content(item, selection == item)
                        .frame(height: 32)
                        .padding(.leading, 5)
                        .animation(.easeInOut(duration: 0.2), value: selection)
                    Spacer()
                }
                .background(hovering == item ? Color(hex: 0x1370F3, alpha: 0.1) : Color.clear)
                .animation(.spring(duration: 0.2), value: hovering)
                .contentShape(Rectangle())
                .onTapGesture {
                    if selection == item { return }
                    selection = item
                    indicatorHeight = 0
                    withAnimation(.spring(duration: 0.2)) {
                        indicatorHeight = 24
                    }
                }
                .onHover { hover in
                    hovering = hover ? item : nil
                }
            }
        }
    }
}
