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
                Text("PCL")
                    .font(.system(size: 20, weight: .bold))
                Spacer()
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: 50)
        .background(Color.blue)
    }
}
