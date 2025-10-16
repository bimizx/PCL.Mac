//
//  TouchBar.swift
//  PCL.Mac
//
//  Created by 温迪 on 2025/10/16.
//

import Cocoa

final class PageState: NSObject {
    @objc dynamic var currentPageIndex: Int = 0
    static let shared: PageState = PageState()
    static let pages: [AppRoute] = [.launch, .download, .settings, .others]
}

extension Window: NSTouchBarDelegate {
    override func makeTouchBar() -> NSTouchBar? {
        let touchBar: NSTouchBar = NSTouchBar()
        touchBar.delegate = self
        touchBar.defaultItemIdentifiers = [.init("pages")]
        touchBar.principalItemIdentifier = .init("pages")
        return touchBar
    }
    
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        guard identifier.rawValue == "pages" else { return nil }
        
        let item: NSCustomTouchBarItem = NSCustomTouchBarItem(identifier: identifier)
        
        let segments: NSSegmentedControl = NSSegmentedControl(labels: ["启动", "下载", "设置", "更多"], trackingMode: .selectOne, target: self, action: #selector(self.segmentChanged(_:)))
        segments.segmentStyle = .automatic
        segments.controlSize = .large
        segments.selectedSegment = 0
        segments.bind(
            .selectedIndex,
            to: PageState.shared,
            withKeyPath: #keyPath(PageState.currentPageIndex),
            options: nil
        )
        
        item.view = segments
        return item
    }
    
    @objc private func segmentChanged(_ sender: NSSegmentedControl) {
        let router: AppRouter = DataManager.shared.router
        let index: Int = sender.selectedSegment
        let root: AppRoute = PageState.pages[index]
        if router.getRoot() == root { return }
        PageState.shared.currentPageIndex = index
        router.path = [root]
    }
}
