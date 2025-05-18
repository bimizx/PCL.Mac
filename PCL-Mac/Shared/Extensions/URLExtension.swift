//
//  URLExtension.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/18.
//

import Foundation

extension URL {
    public func parent() -> URL {
        return self.deletingLastPathComponent()
    }
}
