//
//  ModDownloadView.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/6/20.
//

import SwiftUI

// 别问为什么抽出来，问就是 The compiler is unable to type-check this expression in reasonable time; try breaking up the expression into distinct sub-expressions
fileprivate struct ModVersionListView: View {
    @ObservedObject private var dataManager: DataManager = .shared
    let versions: ModVersionMap
    
    var body: some View {
        LazyVStack {
            ForEach(Array(versions.keys).filter { $0.minecraftVersion.type == .release }.sorted(by: { $0 > $1 }), id: \.self) { key in
                MyCardComponent(title: "\(String(describing: key.loader).capitalized) \(key.minecraftVersion.displayName)") {
                    VStack {
                        ForEach(versions[key]!) { version in
                            MyListItemComponent {
                                HStack {
                                    Image(version.type.capitalized + "Icon")
                                        .resizable()
                                        .frame(width: 32, height: 32)
                                    VStack(alignment: .leading) {
                                        Text(version.name)
                                            .font(.custom("PCL English", size: 14))
                                        Text(version.getDescription())
                                            .font(.custom("PCL English", size: 14))
                                            .foregroundStyle(Color(hex: 0x8C8C8C))
                                    }
                                    
                                    Spacer()
                                }
                            }
                        }
                    }
                    .padding()
                }
                .padding()
            }
        }
    }
}

struct ModDownloadView: View {
    @ObservedObject private var dataManager: DataManager = .shared
    @ObservedObject var summary: ModSummary
    
    var body: some View {
        ScrollView {
            TitlelessMyCardComponent {
                VStack {
                    ModListItem(summary: summary)
                    HStack(spacing: 25) {
                        MyButtonComponent(text: "转到 Modrinth", foregroundStyle: AppSettings.shared.theme.getTextStyle()) {
                            NSWorkspace.shared.open(summary.infoUrl)
                        }
                        .frame(width: 160, height: 40)
                        
                        MyButtonComponent(text: "复制名称") {
                            NSPasteboard.general.setString(summary.title, forType: .string)
                        }
                        .frame(width: 160, height: 40)
                        Spacer()
                    }
                }
                .padding(10)
            }
            .padding()
            if let versions = summary.getVersions() {
                ModVersionListView(versions: versions)
            }
        }
        .scrollIndicators(.never)
        .onAppear {
            dataManager.leftTab(0) { EmptyView() }
        }
    }
}

