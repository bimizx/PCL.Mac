//
//  DataManager.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/19.
//

import SwiftUI

/// 需要在界面上同步 / 使用的都放在这里
class DataManager: ObservableObject {
    static let shared = DataManager()
    
    @Published var javaVirtualMachines: [JavaVirtualMachine] = []
    @Published var lastTimeUsed: Int = 0
    @Published var currentPopup: PopupOverlay?
    
    private init() {}
}
