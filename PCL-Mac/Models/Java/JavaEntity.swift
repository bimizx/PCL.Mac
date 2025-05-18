//
//  JavaEntity.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/18.
//

import Foundation

public struct JavaEntity {
    static let Error = JavaEntity(arch: .unknown, version: nil, displayVersion: nil, executableUrl: nil, callMethod: .incompatible)
    
    let arch: ExecArchitectury
    let version: Int?
    let displayVersion: String?
    let executableUrl: URL?
    let callMethod: CallMethod
    
    public static func of(_ executableUrl: URL) -> JavaEntity {
        guard FileManager.default.fileExists(atPath: executableUrl.path) else {
            print("\(executableUrl) not found!")
            return Error
        }
        guard executableUrl.isFileURL else {
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
        var version: Int? = nil
        var displayVersion: String? = nil
        if FileManager.default.fileExists(atPath: releaseUrl.path) {
            let release = PropertiesParser.parse(fileUrl: releaseUrl)
            displayVersion = release["JAVA_VERSION"]
            version = Int(displayVersion!.split(separator: ".")[displayVersion!.starts(with: "1.") ? 1 : 0])
        }
        return JavaEntity(arch: arch, version: version, displayVersion: displayVersion, executableUrl: executableUrl, callMethod: callMethod ?? .incompatible)
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
}
