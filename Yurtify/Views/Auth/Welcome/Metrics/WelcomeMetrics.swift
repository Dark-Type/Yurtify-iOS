//
//  WelcomeMetrics.swift
//  Yurtify
//
//  Created by dark type on 15.06.2025.
//

import SwiftUI

enum WelcomeMetrics {
    // MARK: - Device Detection
    
    static func isSmallDevice(_ geometry: GeometryProxy) -> Bool {
        geometry.size.height < 700
    }
    
    static func isMediumDevice(_ geometry: GeometryProxy) -> Bool {
        geometry.size.height >= 700 && geometry.size.height < 850
    }
    
    // MARK: - Spacing
    
    static func spacing(for geometry: GeometryProxy) -> CGFloat {
        isSmallDevice(geometry) ? 20 : 30
    }
    
    static func contentSpacing(for geometry: GeometryProxy) -> CGFloat {
        isSmallDevice(geometry) ? 15 : 20
    }
    
    static func quoteSpacing(for geometry: GeometryProxy) -> CGFloat {
        isSmallDevice(geometry) ? 15 : 20
    }
    
    static func buttonSpacing(for geometry: GeometryProxy) -> CGFloat {
        isSmallDevice(geometry) ? 12 : 16
    }
    
    // MARK: - Padding
    
    static func padding(for geometry: GeometryProxy) -> CGFloat {
        isSmallDevice(geometry) ? 20 : 24
    }
    
    static func buttonPadding(for geometry: GeometryProxy) -> CGFloat {
        isSmallDevice(geometry) ? 14 : 16
    }
    
    static func orPadding(for geometry: GeometryProxy) -> CGFloat {
        isSmallDevice(geometry) ? 10 : 12
    }
    
    // MARK: - Sizes
    
    static func titleSize(for geometry: GeometryProxy) -> CGFloat {
        if isSmallDevice(geometry) {
            return 28
        } else if isMediumDevice(geometry) {
            return 32
        } else {
            return 36
        }
    }
    
    static func logoHeight(for geometry: GeometryProxy) -> CGFloat {
        if isSmallDevice(geometry) {
            return geometry.size.height * 0.25
        } else if isMediumDevice(geometry) {
            return geometry.size.height * 0.30
        } else {
            return geometry.size.height * 0.35
        }
    }
    
    static func dividerHeight(for geometry: GeometryProxy) -> CGFloat {
        isSmallDevice(geometry) ? 15 : 20
    }
}
