//
//  JavaEntity.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/18.
//

import Foundation

public struct JavaVirtualMachine: Identifiable, Equatable {
    static let Error = JavaVirtualMachine(arch: .unknown, version: -1, displayVersion: "错误", executableUrl: URL(fileURLWithPath: "Error"), callMethod: .incompatible, _isError: true)
    
    public let arch: ExecArchitectury
    public var version: Int
    public var displayVersion: String
    public let executableUrl: URL
    public let callMethod: CallMethod
    public var isError: Bool {
        get {
            return _isError ?? false
        }
    }
    public var isAddedByUser: Bool {
        get {
            return _isAddedByUser ?? false
        }
    }
    private var _isError: Bool?
    private var _isAddedByUser: Bool?
    
    public let id = UUID()
    
    public static func of(_ executableUrl: URL, _ addedByUser: Bool? = nil) -> JavaVirtualMachine {
        guard FileManager.default.fileExists(atPath: executableUrl.path) else {
            err("\(executableUrl) not found!")
            return Error
        }
        guard executableUrl.isFileURL else {
            err("\(executableUrl.path()) 不是文件!")
            return Error
        }
        
        let arch = getArchOfFile(executableUrl)
        let callMethod: CallMethod?
        if arch == ExecArchitectury.SystemArch || arch == .fatFile {
            callMethod = .direct
        } else if ExecArchitectury.SystemArch == .arm64 {
            callMethod = .transition
        } else {
            callMethod = .incompatible
        }
        let releaseUrl = executableUrl.parent().parent().appending(path: "release")
        var version: Int = 0
        var displayVersion: String = "未知"
        if FileManager.default.fileExists(atPath: releaseUrl.path) {
            let release = PropertiesParser.parse(fileUrl: releaseUrl)
            if let javaVersion = release["JAVA_VERSION"] {
                displayVersion = javaVersion
                version = Int(displayVersion.split(separator: ".")[displayVersion.starts(with: "1.") ? 1 : 0])!
            } else {
                err("加载 \(executableUrl.path()) 时出现错误: 未找到键 JAVA_VERSION 对应的值")
            }
        } else {
            err("未找到 \(executableUrl.path()) 对应的版本文件")
        }
        return JavaVirtualMachine(arch: arch, version: version, displayVersion: displayVersion, executableUrl: executableUrl, callMethod: callMethod ?? .incompatible, _isAddedByUser: addedByUser)
    }
    
    private static func getArchOfFile(_ executableUrl: URL) -> ExecArchitectury {
        guard let fh = try? FileHandle(forReadingFrom: executableUrl) else { return .unknown }
        defer { try? fh.close() }

        guard let magicData = try? fh.read(upToCount: 4), magicData.count == 4 else { return .unknown }
        let magic = magicData.withUnsafeBytes { $0.load(as: UInt32.self) }
        
        if magic == 0xBEBAFECA || magic == 0xBFBAFECA {
            return .fatFile
        }

        var is64Bit = false
        switch magic {
            case 0xFEEDFACE, 0xCEFAEDFE:
                is64Bit = false
            case 0xFEEDFACF, 0xCFFAEDFE:
                is64Bit = true
            default:
                return .unknown
        }

        if is64Bit {
            _ = try? fh.seek(toOffset: 4)
        } else {
            _ = try? fh.seek(toOffset: 4)
        }
        guard let cputypeData = try? fh.read(upToCount: 4), cputypeData.count == 4 else { return .unknown }
        let cputype = cputypeData.withUnsafeBytes { $0.load(as: UInt32.self) }

        switch cputype {
        case 0x1000007: return .x64
        case 0x100000C: return .arm64
        default: return .unknown
        }
    }
    
    public static func == (jvm1: JavaVirtualMachine, jvm2: JavaVirtualMachine) -> Bool {
        return jvm1.executableUrl == jvm2.executableUrl
    }
}

public enum ExecArchitectury {
    public static var SystemArch: ExecArchitectury {
        get {
            if _systemArch == nil {
                var systemInfo = utsname()
                uname(&systemInfo)
                let machineMirror = Mirror(reflecting: systemInfo.machine)
                let identifier = machineMirror.children.reduce("") { identifier, element in
                    guard let value = element.value as? Int8, value != 0 else { return identifier }
                    return identifier + String(UnicodeScalar(UInt8(value)))
                }
                _systemArch = (identifier == "arm64" ? .arm64 : .x64)
            }
            return _systemArch!
        }
    }
    private static var _systemArch: ExecArchitectury? = nil
    case arm64, x64, fatFile, unknown
}

public enum CallMethod {
    case direct, transition, incompatible
    func getDisplayName() -> String {
        switch self {
        case .direct: "直接运行"
        case .transition: "转译"
        case .incompatible: "不兼容"
        }
    }
}
