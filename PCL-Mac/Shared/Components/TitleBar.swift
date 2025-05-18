//
//  TitleBar.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/17.
//

import SwiftUI
import AppKit

struct DraggableArea<Content: View>: NSViewRepresentable {
    let content: () -> Content

    func makeNSView(context: Context) -> DraggableNSHostingView<Content> {
        let view = DraggableNSHostingView(rootView: content())
        return view
    }

    func updateNSView(_ nsView: DraggableNSHostingView<Content>, context: Context) {
        nsView.rootView = content()
    }
}

class DraggableNSHostingView<Content: View>: NSHostingView<Content> {
    private var mouseDownPointInWindow: NSPoint?
    
    override func mouseDown(with event: NSEvent) {
        mouseDownPointInWindow = event.locationInWindow
    }
    
    override func mouseDragged(with event: NSEvent) {
        guard let window = self.window,
              let mouseDownPointInWindow = mouseDownPointInWindow else { return }
        let mouseOnScreen = NSEvent.mouseLocation
        let newOrigin = NSPoint(x: mouseOnScreen.x - mouseDownPointInWindow.x,
                                y: mouseOnScreen.y - mouseDownPointInWindow.y)
        window.setFrameOrigin(newOrigin)
    }
    
    override func mouseUp(with event: NSEvent) {
        mouseDownPointInWindow = nil
    }
}

struct TitleBar: View {
    @State private var initialWindowOrigin: CGPoint?
    @Binding var currentPage: Page
    
    var body: some View {
        VStack {
            ZStack {
                DraggableArea {
                    RadialGradient(
                        gradient: Gradient(colors: [Color(hex: 0x1177DC), Color(hex: 0x0F6AC4)]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 410
                    )
                }
                HStack {
                    Image("TitleLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 19)
                        .bold()
                        .onTapGesture {
                            currentPage = .download
                        }
                    Spacer()
                    MenuItemButton(page: .main, parent: self)
                    MenuItemButton(page: .download, parent: self)
                    Spacer()
                    WindowControlButton.Miniaturize
                    WindowControlButton.Close
                }
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

struct MenuItemButton: View {
    let page: Page
    let parent: TitleBar
    @State private var isHovered = false
    
    var body: some View {
        RoundedRectangle(cornerRadius: 25)
            .frame(width: 75, height: 27)
            .foregroundStyle(parent.currentPage == page ? .white : (isHovered ? Color(hex: 0x3C8CDF) : .clear))
            .animation(.easeInOut(duration: 0.2), value: isHovered)
            .animation(.easeInOut(duration: 0.2), value: parent.currentPage == page)
            .onTapGesture {
                parent.currentPage = page
            }
            .onHover { hover in
                isHovered = hover
            }
    }
}
