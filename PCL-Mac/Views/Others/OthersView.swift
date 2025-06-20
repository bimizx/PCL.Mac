//
//  OthersView.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/18.
//

import SwiftUI

fileprivate enum PageType: CaseIterable, Hashable {
    case about, debug
    
    static func getCases() -> [PageType] {
        var cases = self.allCases
        if !SharedConstants.shared.isDevelopment { cases.removeLast() }
        return cases
    }
}

struct OthersView: View {
    @ObservedObject private var dataManager: DataManager = .shared
    @State private var pageType: PageType? = .about
    
    var body: some View {
        Group {
            switch pageType {
            case .about:
                AboutView()
            case .debug:
                DebugView()
            default:
                EmptyView()
            }
        }
        .onAppear {
            dataManager.leftTab(140) {
                VStack(alignment: .leading, spacing: 0) {
                    MyListComponent(selection: $pageType) { type, isSelected in
                        createListItemView(type)
                            .foregroundStyle(isSelected ? AnyShapeStyle(LocalStorage.shared.theme.getTextStyle()) : AnyShapeStyle(Color(hex: 0x343D4A)))
                    }
                    .padding(.top, 10)
                    Spacer()
                }
            }
        }
    }
    
    private func createListItemView(_ pageType: PageType) -> some View {
        switch pageType {
        case .about:
            return AnyView(
                HStack {
                    Image("AboutItem")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    Text("关于与鸣谢")
                        .font(.custom("PCL English", size: 14))
                }
            )
        case .debug:
            return AnyView(
                HStack {
                    Image("InstallWaiting")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    Text("调试")
                        .font(.custom("PCL English", size: 14))
                }
            )
        }
    }
}
