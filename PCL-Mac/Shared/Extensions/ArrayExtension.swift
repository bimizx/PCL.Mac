//
//  ArrayExtension.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/19.
//

import Foundation

extension Array: @retroactive RawRepresentable where Element == URL {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let urls = try? JSONDecoder().decode([String].self, from: data)
        else { return nil }
        self = urls.compactMap { URL(string: $0) }
    }
    
    public var rawValue: String {
        (try? JSONEncoder().encode(self.map { $0.absoluteString }))
            .flatMap { String(data: $0, encoding: .utf8) } ?? "[]"
    }
}
