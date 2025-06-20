//
//  ModDownloadView.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/6/20.
//

import SwiftUI

fileprivate struct ModListItem: View {
    @ObservedObject var summary: ModSummary
    
    var body: some View {
        HStack {
            if let icon = summary.icon {
                icon
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(summary.title)
                    .font(.custom("PCL English", size: 16))
                    .foregroundStyle(Color(hex: 0x343D4A))
                Text(summary.description)
                    .font(.custom("PCL English", size: 14))
                    .foregroundStyle(Color(hex: 0x8C8C8C))
                    .lineLimit(1)
                    .truncationMode(.tail)
                Spacer()
            }
            Spacer()
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(.clear)
        )
    }
}

struct ModDownloadView: View {
    @State private var query: String = ""
    @State private var summaries: [ModSummary]? = nil
    
    var body: some View {
        ScrollView {
            StaticMyCardComponent(title: "搜索 Mod") {
                VStack(spacing: 30) {
                    HStack(spacing: 30) {
                        Text("名称")
                            .font(.custom("PCL English", size: 14))
                        MyTextFieldComponent(text: $query)
                            .frame(height: 8)
                    }
                    
                    HStack(spacing: 30) {
                        Text("版本")
                            .font(.custom("PCL English", size: 14))
                        MyTextFieldComponent(text: .constant("全部 (也可自行输入)"))
                            .frame(height: 8)
                    }
                    
                    HStack(spacing: 25) {
                        MyButtonComponent(text: "搜索", foregroundStyle: LocalStorage.shared.theme.getTextStyle()) {
                            searchMod()
                        }
                        .frame(width: 160, height: 40)
                        
                        MyButtonComponent(text: "重制条件") {
                            query = ""
                        }
                        .frame(width: 160, height: 40)
                        Spacer()
                    }
                }
                .foregroundStyle(Color(hex: 0x343D4A))
                .padding()
            }
            .padding()
            
            TitlelessMyCardComponent {
                VStack(spacing: 0) {
                    if let summaries = summaries {
                        ForEach(summaries) { summary in
                            ModListItem(summary: summary)
                        }
                    }
                }
            }
            .padding()
        }
        .onAppear {
            searchMod()
        }
    }
    
    private func searchMod() {
        Task {
            let result = await ModrinthModSearcher.default.search(query: self.query)
            DispatchQueue.main.async {
                self.summaries = result
            }
        }
    }
}
