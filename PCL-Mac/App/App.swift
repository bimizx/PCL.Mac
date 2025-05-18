//
//  PCL_MacApp.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/17.
//

import SwiftUI

@main
struct PCL_MacApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .padding(.top, -28)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(WindowAccessor())
        }
        .windowStyle(.hiddenTitleBar)
    }
}

struct WindowAccessor: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let nsView = NSView()
        DispatchQueue.main.async {
            if let window = nsView.window {
                window.titleVisibility = .hidden
                window.titlebarAppearsTransparent = true
                window.standardWindowButton(.closeButton)?.isHidden = true
                window.standardWindowButton(.miniaturizeButton)?.isHidden = true
                window.standardWindowButton(.zoomButton)?.isHidden = true
                window.setContentSize(NSSize(width: 815, height: 465))
                window.isMovableByWindowBackground = false
                window.styleMask.remove(.resizable)
                window.isMovable = false
            }
        }
        return nsView
    }
    func updateNSView(_ nsView: NSView, context: Context) {}
}
