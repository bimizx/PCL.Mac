//
//  Secrets.swift
//  PCL.Mac
//
//  Created by YiZhiMCQiu on 2025/7/13.
//

import Foundation

public let artifactPAT: String = "{{ARTIFACT_PAT}}"
public let clientID: String = "{{CLIENT_ID}}"

public class Secrets {
    public static func getClientID() -> String {
        if !clientID.starts(with: "{{") {
            return clientID
        }
        
        return ProcessInfo.processInfo.environment["CLIENT_ID"] ?? "" // 本地调试使用
    }
}
