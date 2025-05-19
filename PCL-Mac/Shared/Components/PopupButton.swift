//
//  PopupButton.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/19.
//

import SwiftUI

struct PopupButton: View, Identifiable {
    let id = UUID()
    let text: String
    
    var body: some View {
        ZStack {
            Text(text)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(.black)
                        .frame(height: 30)
                        .padding(.leading, -10)
                        .padding(.trailing, -10)
                        .frame(minWidth: 0, maxWidth: .infinity)
                )
        }
    }
}
