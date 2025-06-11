//
//  AppDelegate.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/19.
//

import Cocoa
import Zip

class AppDelegate: NSObject, NSApplicationDelegate {
    private func registerCustomFonts() {
        guard let fontURL = Bundle.main.url(forResource: "PCL", withExtension: "ttf") else {
            err("Bundle 内未找到字体")
            return
        }

        var error: Unmanaged<CFError>?
        if CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, &error) == false {
            if let error = error?.takeUnretainedValue() {
                err("无法注册字体: \(error.localizedDescription)")
            } else {
                err("在注册字体时发生未知错误")
            }
        } else {
            log("成功注册字体")
        }
    }
    
    private func initJavaList() {
        do {
            try JavaSearch.searchAndSet()
        } catch {
            err("无法初始化 Java 列表: \(error.localizedDescription)")
        }
    }
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        LogStore.shared.clear()
        log("App 已启动")
        registerCustomFonts()
        Zip.addCustomFileExtension("jar")
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        let start = Date().timeIntervalSince1970
        log("正在初始化 Java 列表")
        
        initJavaList()
        
        DataManager.shared.refreshVersionManifest()
        
        let directory = MinecraftDirectory(rootUrl: URL(fileURLWithUserPath: "~/PCL-Mac-minecraft"))
        
        if let defaultInstance = LocalStorage.shared.defaultInstance,
           MinecraftInstance(runningDirectory: directory.versionsUrl.appending(path: defaultInstance)) == nil {
            warn("无效的 defaultInstance 配置")
            LocalStorage.shared.defaultInstance = nil
        }
        
        if LocalStorage.shared.defaultInstance == nil {
            LocalStorage.shared.defaultInstance = MinecraftDirectory(rootUrl: URL(fileURLWithUserPath: "~/PCL-Mac-minecraft")).getInnerInstances().first?.config.name
        }
        
        log("App 初始化完成, 耗时 \(Int((Date().timeIntervalSince1970 - start) * 1000))ms")
    }
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        LogStore.shared.save()
        return .terminateNow
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
