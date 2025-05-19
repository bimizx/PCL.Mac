//
//  PopupOverlay.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/19.
//

import SwiftUI

struct PopupOverlay: View, Identifiable, Equatable {
    private let Width: CGFloat = 560
    private let Height: CGFloat = 280
    
    public let title: String
    public let content: String
    public let buttons: [PopupButton]
    
    public let id: UUID = UUID()
    
    public init(_ title: String, _ content: String, _ buttons: [PopupButton]) {
        self.title = title
        self.content = content
        self.buttons = buttons
    }
    
    public static func == (_ var1: PopupOverlay, _ var2: PopupOverlay) -> Bool {
        return var1.id == var2.id
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(.white)
                .frame(width: Width + 20, height: Height + 20)
            HStack {
                VStack {
                    Text(title)
                        .font(.system(size: 30, design: .rounded))
                        .foregroundStyle(Color(hex: 0x0B5BCB))
                        .frame(maxWidth: Width - 40, alignment: .leading)
                    Rectangle()
                        .foregroundStyle(Color(hex: 0x0B5BCB))
                        .frame(width: Width - 20, height: 2)
                        .padding(.top, -10)
                    Text(content)
                        .foregroundStyle(Color(hex: 0x272727))
                        .frame(maxWidth: Width - 40, alignment: .leading)
                    Spacer()
                    HStack {
                        Spacer()
                        ForEach(buttons) { button in
                            button
                                .padding()
                                .foregroundStyle(.black)
                        }
                    }
                }
            }
            .frame(width: Width, height: Height)
        }
    }
}

#Preview {
//    PopupOverlay("Minecraft 出现错误", "错就发报告\n错不起就别问", [])
//        .padding()
//        .background(Color(hex: 0xC4D9F2))
    ContentView()
}
