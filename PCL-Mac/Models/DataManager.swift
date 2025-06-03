//
//  DataManager.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/19.
//

import SwiftUI
import Combine

/// 需要在界面上同步 / 使用的都放在这里
class DataManager: ObservableObject {
    static let shared = DataManager()
    
    @Published var javaVirtualMachines: [JavaVirtualMachine] = []
    @Published var lastTimeUsed: Int = 0
    @Published var showPopup: Bool = false
    @Published var currentPopup: PopupOverlay?
    @Published var networkMonitor: NetworkSpeedMonitor = NetworkSpeedMonitor()
    @Published var versionManifest: VersionManifest?
    @Published var router: AppRouter = AppRouter()
    @Published var leftTabWidth: CGFloat = 310
    @Published var leftTabContent: AnyView = AnyView(EmptyView())
    @Published var downloadSpeed: Double = 0
    @Published var currentStagePercentage: Double = 0
    @Published var inprogressInstallTask: InstallTask?
    
    private var routerCancellable: AnyCancellable?
    
    private init() {
        routerCancellable = router.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
    }
    
    func refreshVersionManifest() {
        let group = DispatchGroup()
        var _versionManifest: VersionManifest? = nil
        group.enter()
        VersionManifest.fetchLatestData { versionManifest in
            _versionManifest = versionManifest
            group.leave()
        }
        
        group.wait()
        versionManifest = _versionManifest
    }
    
    func leftTab(_ width: CGFloat, _ content: @escaping () -> some View) {
        DispatchQueue.main.async {
            self.leftTabWidth = width
            self.leftTabContent = AnyView(content())
        }
    }
}
