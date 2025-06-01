//
//  Requests.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/6/1.
//

import Foundation

public struct Requests {
    public static func post(url: URL, headers: [String : String]? = nil, params: [String : Any]? = nil, encodeMethod: EncodeMethod = .json) async -> Data? {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        if let params = params {
            switch encodeMethod {
            case .json:
                request.httpBody = try? JSONSerialization.data(withJSONObject: params)
            case .urlencoded:
                request.httpBody = params.map { "\($0.key)=\($0.value)" }.joined(separator: "&").data(using: .utf8)
            }
        }
        
        return await withCheckedContinuation { continuation in
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let response = response as? HTTPURLResponse {
                    debug("\(response.statusCode) \(url.path)")
                }
                continuation.resume(returning: data)
            }.resume()
        }
    }
    
    public enum EncodeMethod {
        case json, urlencoded
    }
}
