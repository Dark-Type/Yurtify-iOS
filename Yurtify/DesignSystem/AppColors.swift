//
//  AppColors.swift
//  Yurtify
//
//  Created by dark type on 14.06.2025.
//

import SwiftUI

enum AppColors {
    // MARK: - Base Colors

    static let primaryVariant = Color("PrimaryVariant")
    static let secondaryVariant = Color("SecondaryVariant")
    static let alternativeVariant = Color("AlternativeVariant")

    // MARK: - Accent Colors

    static let accentLight = Color("AccentLight")
    static let accentDark = Color("AccentDark")

    // MARK: - Background Colors

    static let base = Color("Base")
    static let fade = Color("Fade")
    static let tabbar = Color("Tabbar")

    // MARK: - Text Colors

    static let textPrimary = Color("TextPrimary")
    static let textSecondary = Color("TextPrimaryOpacity")
    static let textFade = Color("TextFade")

    // MARK: - Utility Colors

    static let white = Color(.white)
}

extension Color {
    static let app = AppColors.self
}
