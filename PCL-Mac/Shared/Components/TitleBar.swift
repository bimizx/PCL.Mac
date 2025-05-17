//
//  TitleBar.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/17.
//

import SwiftUI

struct TitleBar: View {
    var body: some View {
        VStack {
            HStack {
                Image("TitleLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 19)
                    .bold()
                Spacer()
                WindowControlButton.Miniaturize
                WindowControlButton.Close
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: 47)
        .background(
            RadialGradient(
                gradient: Gradient(colors: [Color(hex: 0x1177DC), Color(hex: 0x0F6AC4)]),
                center: .center,
                startRadius: 0,
                endRadius: 410
            )
        )
    }
}
