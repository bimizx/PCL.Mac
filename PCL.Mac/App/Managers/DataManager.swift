//
//  DataManager.swift
//  PCL.Mac
//
//  Created by YiZhiMCQiu on 2025/5/19.
//

import SwiftUI
import Combine

/// 需要在界面上同步 / 使用的都放在这里
class DataManager: ObservableObject {
    static let shared = DataManager()
    
    @Published var javaVirtualMachines: [JavaVirtualMachine] = []
    @Published var networkMonitor: NetworkSpeedMonitor = NetworkSpeedMonitor()
    @Published var router: AppRouter = .init()
    @Published var leftTabWidth: CGFloat = 310
    @Published var leftTabContent: AnyView = AnyView(EmptyView())
    @Published var leftTabId: UUID = .init()
    @Published var inprogressInstallTasks: InstallTasks?
    @Published var launchState: LaunchState?
    
    var defaultInstance: MinecraftInstance? {
        let directory: MinecraftDirectory = MinecraftDirectoryManager.shared.current
        if let defaultInstance = directory.config.defaultInstance,
           let instance = MinecraftInstance.create(directory: directory, name: defaultInstance) {
            return instance
        }
        return nil
    }
    
    private var routerCancellable: AnyCancellable?
    
    private init() {
        routerCancellable = router.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
    }
    
    func leftTab(_ width: CGFloat, _ content: @escaping () -> some View) {
        DispatchQueue.main.async {
            self.leftTabWidth = width
            self.leftTabContent = AnyView(content())
            self.leftTabId = .init()
        }
    }
}
