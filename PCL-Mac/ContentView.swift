//
//  ContentView.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/17.
//

import SwiftUI

struct ContentView: View {
    @State private var currentPage: Page = .launcher
    @ObservedObject private var dataManager: DataManager = DataManager.shared
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                TitleBarComponent(currentPage: $currentPage)
                createViewFromPage()
                    .foregroundStyle(.black)
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
            if let currentPopup = DataManager.shared.currentPopup {
                Group {
                    Rectangle()
                        .fill(Color(hex: 0x000000, alpha: 0.7))
                        .opacity(dataManager.currentPopup != nil ? 1 : 0)
                    currentPopup
                        .padding()
                        .transition(.opacity)
                    VStack {
                        TitleBarComponent(currentPage: .constant(currentPage))
                        Spacer()
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: dataManager.currentPopup)
            }
        }
        .onAppear {
            ContentView.setPopup(
                PopupOverlay("Minecraft 出现错误", "错就发报告\n错不起就别问", [
                    PopupButton(text: "截图扔到Q群，然后坐和被骂", color: Color(hex: 0xC00606)) {
                        NSApplication.shared.terminate(nil)
                    },
                    .Close
                ])
            )
        }
    }
    
    private func createViewFromPage() -> some View {
        Group {
            switch (currentPage) {
            case .launcher: LauncherView()
            case .download: DownloadView()
            case .multiplayer: MultiplayerView()
            case .settings: SettingsView()
            case .others: OthersView()
            }
        }
    }
    
    static func setPopup(_ popup: PopupOverlay?) {
        DataManager.shared.currentPopup = popup
    }
}

#Preview {
    ContentView()
}

enum Page {
    case launcher, download, multiplayer, settings, others;
}
