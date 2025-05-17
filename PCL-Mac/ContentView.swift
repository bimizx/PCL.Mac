//
//  ContentView.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/17.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            TitleBar()
            Spacer()
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            Spacer()
        }
        .background(
            RadialGradient(
                gradient: Gradient(colors: [Color(hex: 0xC8DCF4), Color(hex: 0xB7CBE3)]),
                center: .center,
                startRadius: 0,
                endRadius: 410
            )
        )
    }
}

#Preview {
    ContentView()
}
