//
//  LogManager.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/19.
//

import Foundation
import SwiftUI

actor LogStore {
    let dateFormatter = DateFormatter()
    nonisolated static let shared = LogStore()
    private var logs: [String] = []
    private let maxCapacity = 10_000
    
    func append(_ message: String, _ level: String, _ caller: String) {
        if logs.count >= maxCapacity {
            logs.removeFirst(1000)
        }
        logs.append("\(dateFormatter.string(from: Date())) [\(level)] \(caller): \(message)")
        print(logs.last!)
    }
    func flushToDisk() {
        let content = logs.joined(separator: "\n")
        Task {
            do {
                try await FileManager.default.writeLog(content)
                log("日志保存成功")
            } catch {
                err("日志保存失败: \(error)")
            }
            log("已触发进程终止")
            await NSApp.reply(toApplicationShouldTerminate: true)
        }
    }
    
    init() {
        dateFormatter.dateFormat = "[yyyy-MM-dd] [HH:mm:ss]"
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Shanghai")
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Shanghai")
    }
}

@MainActor
class Logger {
    static func log(_ message: String, _ caller: String) {
        Task {
            await LogStore.shared.append(message, "LOG", caller)
        }
    }
    
    static func warn(_ message: String, _ caller: String) {
        Task {
            await LogStore.shared.append(message, "WRN", caller)
        }
    }
    
    static func error(_ message: String, _ caller: String) {
        Task {
            await LogStore.shared.append(message, "ERR", caller)
        }
    }
    
    static func debug(_ message: String, _ caller: String) {
#if DEBUG
        Task {
            await LogStore.shared.append(message, "DEBUG", caller)
        }
#endif
    }
}

func log(_ message: String, file: String = #file, line: Int = #line) {
    Task { @MainActor in
        Logger.log(message, file.split(separator: "/").last! + ":" + String(line))
    }
}

func warn(_ message: String, file: String = #file, line: Int = #line) {
    Task { @MainActor in
        Logger.warn(message, file.split(separator: "/").last! + ":" + String(line))
    }
}

func err(_ message: String, file: String = #file, line: Int = #line) {
    Task { @MainActor in
        Logger.error(message, file.split(separator: "/").last! + ":" + String(line))
    }
}

func debug(_ message: String, file: String = #file, line: Int = #line) {
    Task { @MainActor in
        Logger.debug(message, file.split(separator: "/").last! + ":" + String(line))
    }
}
