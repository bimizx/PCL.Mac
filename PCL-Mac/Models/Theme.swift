//
//  Theme.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/30.
//

import SwiftUI

public enum Theme: String, CaseIterable {
    case pcl, colorful
    
    public func getGradientView() -> some ShapeStyle {
        switch self {
        case .colorful:
            return AnyShapeStyle(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: 0xFFAC4A),
                        Color(hex: 0xFF3769),
                        Color(hex: 0xD29CFF),
                        Color(hex: 0x8ACFEA)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .topTrailing
                )
            )
        case .pcl:
            return AnyShapeStyle(
                RadialGradient(
                    gradient: Gradient(colors: [Color(hex: 0x1177DC), Color(hex: 0x0F6AC4)]),
                    center: .center,
                    startRadius: 0,
                    endRadius: 410
                )
            )
        }
    }
    
    public func getBackgroundGradientView() -> some ShapeStyle {
        switch self {
        case .pcl:
            return AnyShapeStyle(
                RadialGradient(
                    gradient: Gradient(colors: [Color(hex: 0xC8DCF4), Color(hex: 0xB7CBE3)]),
                    center: .center,
                    startRadius: 0,
                    endRadius: 410
                )
            )
        case .colorful:
            return AnyShapeStyle(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: 0xFFAC4A), // 橙色
                        Color(hex: 0xFF3769), // 红色
                        Color(hex: 0xD29CFF), // 紫色
                        Color(hex: 0x8ACFEA), // 蓝色
                    ]),
                    startPoint: .topLeading,
                    endPoint: .topTrailing
                )
            )
        }
    }
    
    public func gradientOr(_ color: Color) -> some ShapeStyle {
        if self == .colorful {
            return AnyShapeStyle(getGradientView())
        }
        return AnyShapeStyle(color)
    }
}
