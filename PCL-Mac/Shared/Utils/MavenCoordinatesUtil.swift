//
//  MavenCoordinatesURL.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/6/17.
//

import Foundation

public class MavenCoordinatesUtil {
    public static func parse(_ mavenCoordinate: String) -> (groupId: String, artifactId: String, version: String) {
        let parts = mavenCoordinate.split(separator: ":").map(String.init)
        return (parts[0], parts[1], parts[2])
    }
    
    public static func toPath(_ mavenCoordinate: String) -> String {
        let (groupId, artifactId, version) = parse(mavenCoordinate)
        return "\(groupId.replacingOccurrences(of: ".", with: "/"))/\(artifactId)/\(version)/\(artifactId)-\(version).jar"
    }
}
