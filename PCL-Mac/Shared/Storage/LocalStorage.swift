//
//  LocalStorage.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/19.
//

import SwiftUI

public class LocalStorage {
    public static let shared = LocalStorage()
    
    @AppStorage("customJVMs") public var customJVMs: [URL] = []
    
    private init() {}
}
