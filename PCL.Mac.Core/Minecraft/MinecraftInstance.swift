//
//  MinecraftVersion.swift
//  PCL.Mac
//
//  Created by YiZhiMCQiu on 2025/5/20.
//

import Foundation
import SwiftyJSON
import ZIPFoundation
import Cocoa

public class MinecraftInstance: Identifiable, Equatable, Hashable {
    private static var cache: [URL : MinecraftInstance] = [:]
    
    private static let RequiredJava16: MinecraftVersion = MinecraftVersion(displayName: "21w19a", type: .snapshot)
    private static let RequiredJava17: MinecraftVersion = MinecraftVersion(displayName: "1.18-pre2", type: .snapshot)
    private static let RequiredJava21: MinecraftVersion = MinecraftVersion(displayName: "24w14a", type: .snapshot)
    
    public let runningDirectory: URL
    public let minecraftDirectory: MinecraftDirectory
    public let configPath: URL
    public private(set) var version: MinecraftVersion! = nil
    public var process: Process?
    public let manifest: ClientManifest
    public var config: MinecraftConfig
    
    public let id: UUID = UUID()
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: MinecraftInstance, rhs: MinecraftInstance) -> Bool {
        lhs.id == rhs.id
    }
    
    public static func create(runningDirectory: URL, config: MinecraftConfig? = nil, _ caller: String = #file, _ line: Int = #line) -> MinecraftInstance? {
        if let cached = cache[runningDirectory] {
            return cached
        }
        
        if let instance: MinecraftInstance = .init(runningDirectory: runningDirectory, config: config) {
            cache[runningDirectory] = instance
            return instance
        }
        
        return nil
    }
    
    private init?(runningDirectory: URL, config: MinecraftConfig? = nil) {
        self.runningDirectory = runningDirectory
        self.minecraftDirectory = MinecraftDirectory(rootUrl: runningDirectory.parent().parent(), name: "")
        self.configPath = runningDirectory.appending(path: ".PCL_Mac.json")
        
        if FileManager.default.fileExists(atPath: configPath.path) {
            do {
                let handle = try FileHandle(forReadingFrom: configPath)
                self.config = .init(try .init(data: handle.readToEnd()!))
            } catch {
                err("无法加载配置: \(error.localizedDescription)")
                debug(configPath.path)
                return nil
            }
        } else {
            self.config = config ?? MinecraftConfig(name: runningDirectory.lastPathComponent, mainClass: "")
        }
        
        do {
            let data = try FileHandle(forReadingFrom: runningDirectory.appending(path: runningDirectory.lastPathComponent + ".json")).readToEnd()!
            let json = try JSON(data: data)
            if !json["inheritsFrom"].exists() && !json["launcherMeta"].exists() {
                manifest = try ClientManifest.parse(data, instanceUrl: runningDirectory)
            } else {
                switch self.config.clientBrand {
                case .fabric:
                    manifest = ClientManifest.createFromFabricManifest(.init(json), runningDirectory)
                default:
                    warn("发现不受支持的加载器: \(self.config.name) \(self.config.clientBrand.rawValue)")
                    manifest = try ClientManifest.parse(data, instanceUrl: runningDirectory)
                }
            }
            ArtifactVersionMapper.map(manifest)
        } catch {
            err("无法加载客户端清单: \(error)")
            return nil
        }
        
        detectVersion()
        
        self.version = MinecraftVersion(displayName: self.config.version!)
        if self.config.javaPath == nil {
            self.config.javaPath = MinecraftInstance.findSuitableJava(self.version!)?.executableUrl.path
        }
        self.saveConfig()
    }
    
    public func saveConfig() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            try FileManager.default.createDirectory(
                at: runningDirectory,
                withIntermediateDirectories: true,
                attributes: nil
            )
            try encoder.encode(config).write(to: configPath, options: .atomic)
        } catch {
            err("无法保存配置: \(error.localizedDescription)")
        }
    }
    
    public static func getMinJavaVersion(_ version: MinecraftVersion) -> Int {
        if version >= RequiredJava21 {
            return 21
        } else if version >= RequiredJava17 {
            return 17
        } else if version >= RequiredJava16 {
            return 16
        } else {
            return 8
        }
    }
    
    public static func findSuitableJava(_ version: MinecraftVersion) -> JavaVirtualMachine? {
        let minJavaVersion = getMinJavaVersion(version)
        var suitableJava: JavaVirtualMachine?
        for jvm in DataManager.shared.javaVirtualMachines.sorted(by: { $0.version < $1.version }) {
            if jvm.version < minJavaVersion { continue }
            
            suitableJava = jvm
            
            if jvm.callMethod == .direct {
                break
            }
        }
        
        if suitableJava == nil {
            warn("未找到可用 Java")
            debug("版本: \(version.displayName)")
            debug("最低 Java 版本: \(minJavaVersion)")
        }
        
        return suitableJava
    }
    
    public func launch(_ launchOptions: LaunchOptions) async {
        if !config.skipResourcesCheck && !launchOptions.skipResourceCheck {
            log("正在进行资源完整性检查")
            await withCheckedContinuation { continuation in
                let task = MinecraftInstaller.createCompleteTask(self, continuation.resume)
                task.start()
            }
            log("资源完整性检查完成")
        }
        
        guard let account = AccountManager.shared.getAccount() else {
            err("无法启动 Minecraft: 未设置账号")
            await ContentView.setPopup(PopupOverlay("错误", "请先创建一个账号并选择再启动游戏！", [.Ok], .error))
            return
        }
        
        guard let javaPath = config.javaPath, let javaUrl = Optional(URL(fileURLWithPath: javaPath)) else {
            err("无法启动 Minecraft: 未找到 Java")
            await ContentView.setPopup(PopupOverlay("错误", "找不到可用的 Java，请确保你已经安装了符合要求的 Java 版本！", [.Ok], .error))
            return
        }
        
        launchOptions.account = account
        launchOptions.javaPath = javaUrl
        
        let launcher = MinecraftLauncher(self)!
        launcher.launch(launchOptions) { exitCode in
            if exitCode != 0 {
                log("检测到非 0 退出代码")
                hint("检测到 Minecraft 出现错误，错误分析已开始……")
                ContentView.setPopup(.init("Minecraft 出现错误", "很抱歉，PCL.Mac 暂时没有分析功能。\n如果要寻求帮助，请把错误报告文件发给对方，而不是发送这个窗口的照片或者截图。\n不要截图！不要截图！！不要截图！！！", [
                    .Ok,
                    .init(text: "导出错误报告", onClick: {
                        let savePanel = NSSavePanel()
                        savePanel.title = "选择导出位置"
                        savePanel.prompt = "导出"
                        savePanel.allowedContentTypes = [.zip]
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-M-d_HH.mm.ss"
                        savePanel.nameFieldStringValue = "错误报告-\(formatter.string(from: .init()))"
                        savePanel.beginSheetModal(for: NSApplication.shared.windows.first!) { [unowned self] result in
                            if result == .OK {
                                if let url = savePanel.url {
                                    MinecraftCrashHandler.exportErrorReport(self, launcher, to: url)
                                }
                            }
                        }
                        PopupButton.Close.onClick()
                    })
                ]))
            }
        }
    }
    
    public func detectVersion() {
        guard config.version == nil else {
            return
        }
        
        do {
            let archive = try Archive(url: runningDirectory.appending(path: "\(config.name).jar"), accessMode: .read)
            guard let entry = archive["version.json"] else {
                throw NSError(domain: "MinecraftInstance", code: 2, userInfo: [NSLocalizedDescriptionKey: "version.json 不存在"])
            }
            
            var data = Data()
            _ = try archive.extract(entry, consumer: { (chunk) in
                data.append(chunk)
            })
            
            self.config.version = try JSON(data: data)["id"].stringValue
        } catch {
            err("无法检测版本: \(error.localizedDescription)，正在使用清单版本")
            self.config.version = self.manifest.id
        }
    }
}

public struct MinecraftConfig: Codable {
    public let name: String
    public var version: String?
    public var mainClass: String
    public var additionalLibraries: Set<String> = []
    public var javaPath: String!
    public var clientBrand: ClientBrand
    public var skipResourcesCheck: Bool = false
    public var maxMemory: Int32 = 4096
    
    public init(_ json: JSON) {
        self.name = json["name"].stringValue
        self.version = json["version"].string
        self.mainClass = json["mainClass"].string ?? "net.minecraft.client.main.Main"
        self.additionalLibraries = .init(json["additionalLibraries"].array?.map { $0.stringValue } ?? [])
        self.javaPath = json["javaPath"].string
        if let clientBrand = json["clientBrand"].string {
            self.clientBrand = .init(rawValue: clientBrand)!
        } else {
            self.clientBrand = .vanilla
        }
        self.skipResourcesCheck = json["skipResourcesCheck"].boolValue
        self.maxMemory = json["maxMemory"].int32Value
    }
    
    public init(name: String, mainClass: String, javaPath: String? = nil) {
        self.name = name
        self.mainClass = mainClass
        self.javaPath = javaPath
        self.clientBrand = .vanilla
    }
}

public enum ClientBrand: String, Codable {
    case vanilla = "vanilla"
    case fabric = "fabric"
    case forge = "forge"
    case neoforge = "neoforge"
}
