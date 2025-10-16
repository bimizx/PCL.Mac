//
//  AnnouncementExtension.swift
//  PCL.Mac
//
//  Created by 温迪 on 2025/10/16.
//

import SwiftUI

extension Announcement {
    @ViewBuilder
    func makeContentView() -> some View {
        ForEach(content) { (content: Announcement.Content) in
            switch content {
            case .text(let text):
                SwiftUI.Text(text.content)
                    .font(.custom("PCL English", size: text.size))
                    .foregroundStyle(Color("TextColor"))
                    .strikethrough(text.strike)
                    .padding(.leading, 10)
            case .link(let link):
                SwiftUI.Text(link.display)
                    .font(.custom("PCL English", size: 14))
                    .foregroundStyle(.blue)
                    .padding(.leading, 10)
                    .onTapGesture {
                        NSWorkspace.shared.open(link.url)
                    }
            case .tip(let tip):
                MyTip(text: tip.text, color: TipColor(rawValue: tip.color) ?? .blue)
                    .padding(.vertical, 10)
            case .title(let title):
                SwiftUI.Text(title.text)
                    .font(.custom("PCL English", size: title.size))
                    .foregroundStyle(Color("TextColor"))
                    .padding(.vertical, 10)
            }
        }
    }
}
