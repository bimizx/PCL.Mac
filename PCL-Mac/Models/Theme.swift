//
//  Theme.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/30.
//

import SwiftUI

public enum Theme: String, CaseIterable {
    case pcl, colorful, venti
    
    public func getGradient() -> some ShapeStyle { // 获取主渐变色（如标题栏）
        switch self {
        case .venti:
            return AnyShapeStyle(Color(hex: 0x23D49F))
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
    
    public func getBackgroundGradient() -> some ShapeStyle { // 获取副渐变色（如背景）
        switch self {
        case .venti:
            return AnyShapeStyle(Color(hex: 0x23D49F, alpha: 0.5))
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
                        Color(hex: 0xCC8A28), // 橙色
                        Color(hex: 0xDD1547), // 红色
                        Color(hex: 0xB07ADD), // 紫色
                        Color(hex: 0x68ADC8), // 蓝色
                    ]),
                    startPoint: .topLeading,
                    endPoint: .topTrailing
                )
            )
        }
    }
    
    public func getGradientView() -> some View { // 带图片主题的标题栏视图
        switch self {
        default:
            return AnyView(EmptyView().background(getGradient()))
        }
    }
    
    public func getBackgroundView() -> some View { // 带图片主题的背景视图
        switch self {
        case .venti:
            return AnyView(
                HStack {
                    Spacer()
                    Image("TVentiImage1")
                        .resizable()
                        .scaledToFit()
                        .opacity(0.3)
                }
                    .background(getBackgroundGradient())
            )
        default:
            return AnyView(EmptyView().background(getBackgroundGradient()))
        }
    }
    
    public func gradientOr(_ color: Color) -> some ShapeStyle {
        if self == .colorful || self == .venti {
            return AnyShapeStyle(getGradient())
        }
        return AnyShapeStyle(color)
    }
}
