//
//  RegistrationMetrics.swift
//  Yurtify
//
//  Created by dark type on 15.06.2025.
//

import SwiftUI

enum RegistrationMetrics {
    // MARK: - Device Detection
    
    static func isSmallDevice(_ geometry: GeometryProxy) -> Bool {
        geometry.size.height < 700
    }
    
    // MARK: - Spacing
    
    static func contentSpacing(for geometry: GeometryProxy) -> CGFloat {
        isSmallDevice(geometry) ? 20 : 24
    }
    
    static func sectionSpacing(for geometry: GeometryProxy) -> CGFloat {
        isSmallDevice(geometry) ? 16 : 20
    }
    
    static func textFieldSpacing(for geometry: GeometryProxy) -> CGFloat {
        isSmallDevice(geometry) ? 12 : 16
    }
    
    // MARK: - Padding
    
    static func horizontalPadding(for geometry: GeometryProxy) -> CGFloat {
        isSmallDevice(geometry) ? 20 : 24
    }
    
    static func verticalPadding(for geometry: GeometryProxy) -> CGFloat {
        isSmallDevice(geometry) ? 16 : 20
    }
    
    static func buttonPadding(for geometry: GeometryProxy) -> CGFloat {
        isSmallDevice(geometry) ? 14 : 16
    }
    
    // MARK: - Sizes
    
    static func titleSize(for geometry: GeometryProxy) -> CGFloat {
        isSmallDevice(geometry) ? 32 : 40
    }
    
    static func logoHeight(for geometry: GeometryProxy) -> CGFloat {
        isSmallDevice(geometry) ? 80 : 100
    }
}
