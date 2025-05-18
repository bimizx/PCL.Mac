//
//  ContentView.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/17.
//

import SwiftUI

struct ContentView: View {
    @State private var currentPage: Page = .main
    
    var body: some View {
        VStack(spacing: 0) {
            TitleBar(currentPage: $currentPage)
            createViewFromPage()
                .frame(minWidth: 815, minHeight: 418)
        }
        .ignoresSafeArea(.container, edges: .top)
        .background(
            RadialGradient(
                gradient: Gradient(colors: [Color(hex: 0xC8DCF4), Color(hex: 0xB7CBE3)]),
                center: .center,
                startRadius: 0,
                endRadius: 410
            )
        )
    }
    
    private func createViewFromPage() -> some View {
        Group {
            switch (currentPage) {
            case .main: MainView()
            case .download: DownloadView()
            default: MainView()
            }
        }
    }
}

#Preview {
    ContentView()
}

enum Page {
    case main, download, multiplayer, settings, others;
}
