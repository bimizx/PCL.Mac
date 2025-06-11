//
//  AppRoute.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/29.
//

import Foundation

public enum AppRoute: Hashable {
    // 根页面
    case launch
    case download
    case multiplayer
    case settings
    case others
    
    // 子页面
    case installing(task: InstallTask)
    case versionList
    
    var isRoot: Bool {
        switch self {
        case .launch, .download, .multiplayer, .settings, .others:
            return true
        default:
            return false
        }
    }
}

public class AppRouter: ObservableObject {
    @Published public private(set) var path: [AppRoute] = [.launch]
    
    public func append(_ route: AppRoute) {
        if route.isRoot && !self.path.isEmpty {
            warn("试图向路由中追加一个根页面(\(route)，但路由不为空")
            return
        }
        self.path.append(route)
    }
    
    public func removeLast() {
        self.path.removeLast()
        if self.path.isEmpty {
            self.path.append(.launch)
        }
    }
    
    public func setRoot(_ root: AppRoute) {
        path.removeAll()
        path.append(root)
    }
    
    public func getLast() -> AppRoute {
        return path.last!
    }
    
    public func getRoot() -> AppRoute {
        return path.first!
    }
}
