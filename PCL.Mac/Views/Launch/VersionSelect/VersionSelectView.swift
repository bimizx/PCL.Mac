//
//  VersionSelectView.swift
//  PCL.Mac
//
//  Created by YiZhiMCQiu on 2025/7/12.
//

import SwiftUI
import UniformTypeIdentifiers

struct VersionSelectView: View, SubRouteContainer {
    @ObservedObject private var dataManager: DataManager = DataManager.shared
    
    var body: some View {
        Group {
            switch dataManager.router.getLast() {
            case .versionList(let directory):
                VersionListView(minecraftDirectory: directory)
            default:
                Spacer()
            }
        }
        .onAppear {
            dataManager.leftTab(300) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("文件夹列表")
                        .font(.custom("PCL English", size: 12))
                        .foregroundStyle(Color(hex: 0x8C8C8C))
                        .padding(.leading, 12)
                        .padding(.top, 20)
                        .padding(.bottom, 4)
                    MyListComponent(
                        default: .versionList(directory: AppSettings.shared.currentMinecraftDirectory ?? .default),
                        cases: AppSettings.shared.minecraftDirectories.map { .versionList(directory: $0) },
                        height: 42,
                        content: { type, isSelected in
                            createListItemView(type)
                                .foregroundStyle(isSelected ? AnyShapeStyle(AppSettings.shared.theme.getTextStyle()) : AnyShapeStyle(Color("TextColor")))
                        }
                    )
                    Text("添加或导入")
                        .font(.custom("PCL English", size: 12))
                        .foregroundStyle(Color(hex: 0x8C8C8C))
                        .padding(.leading, 12)
                        .padding(.top, 20)
                        .padding(.bottom, 4)
                    LeftTabItem(imageName: "PlusIcon", text: "添加已有文件夹")
                        .onTapGesture {
                            let panel = NSOpenPanel()
                            panel.allowsMultipleSelection = false
                            panel.canChooseFiles = false
                            panel.canChooseDirectories = true
                            panel.allowedContentTypes = [.folder]
                            
                            if panel.runModal() == .OK {
                                AppSettings.shared.minecraftDirectories.insert(.init(rootUrl: panel.url!, name: "自定义目录"))
                                AppSettings.shared.currentMinecraftDirectory = .init(rootUrl: panel.url!, name: "自定义目录")
                            }
                        }
                    Spacer()
                }
            }
        }
        .onDrop(of: [.folder], delegate: VersionDropDelegate())
    }
    
    private func createListItemView(_ type: AppRoute) -> some View {
        if case .versionList(let directory) = type {
            return AnyView(
                VStack(alignment: .leading) {
                    Text(directory.name)
                        .font(.custom("PCL English", size: 14))
                        .foregroundStyle(.primary)
                    Text(directory.rootUrl.path)
                        .font(.custom("PCL English", size: 12))
                        .foregroundStyle(Color(hex: 0x8C8C8C))
                }
            )
        }
        return AnyView(EmptyView())
    }
}

fileprivate struct LeftTabItem: View {
    let imageName: String
    let text: String
    
    var body: some View {
        MyListItemComponent {
            HStack {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24)
                    .foregroundStyle(Color("TextColor"))
                    .padding(.leading)
                    .padding(.top, 6)
                    .padding(.bottom, 6)
                Text(text)
                    .font(.custom("PCL English", size: 14))
                    .foregroundStyle(Color("TextColor"))
                Spacer()
            }
        }
        
    }
}

#Preview {
    VersionSelectView()
}
