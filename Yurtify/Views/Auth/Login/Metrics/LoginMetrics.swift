//
//  LoginMetrics.swift
//  Yurtify
//
//  Created by dark type on 15.06.2025.
//

import SwiftUI

enum LoginMetrics {
    // MARK: - Logo

    static func logoHeight(for geometry: GeometryProxy) -> CGFloat {
        geometry.size.height * 0.25
    }

    static func logoTopSpacing(for geometry: GeometryProxy) -> CGFloat {
        geometry.size.height * 0.1
    }

    // MARK: - Spacing

    static func contentSpacing(for geometry: GeometryProxy) -> CGFloat {
        geometry.size.height * 0.05
    }

    static func textFieldSpacing(for geometry: GeometryProxy) -> CGFloat {
        max(16, geometry.size.height * 0.02)
    }

    static func sectionSpacing(for geometry: GeometryProxy) -> CGFloat {
        max(20, geometry.size.height * 0.025)
    }

    // MARK: - Padding

    static func horizontalPadding(for geometry: GeometryProxy) -> CGFloat {
        max(24, geometry.size.width * 0.06)
    }

    static func buttonPadding(for geometry: GeometryProxy) -> CGFloat {
        max(16, geometry.size.height * 0.02)
    }

    // MARK: - Footer

    static func footerBottomPadding(for geometry: GeometryProxy) -> CGFloat {
        max(40, geometry.safeAreaInsets.bottom + 20)
    }
}
