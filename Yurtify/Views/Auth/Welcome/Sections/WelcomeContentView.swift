//
//  WelcomeContentView.swift
//  Yurtify
//
//  Created by dark type on 15.06.2025.
//

import SwiftUI

struct WelcomeContentView: View {
    let geometry: GeometryProxy

    var body: some View {
        VStack(spacing: WelcomeMetrics.contentSpacing(for: geometry)) {
            titleSection
            logoSection
            WelcomeQuoteSection(geometry: geometry)
        }
    }

    // MARK: - Subviews

    private var titleSection: some View {
        Text(L10n.Welcome.title)
            .font(.app.interExtraBold(size: WelcomeMetrics.titleSize(for: geometry)))
            .foregroundColor(.textPrimary)
            .multilineTextAlignment(.leading)
    }

    private var logoSection: some View {
        Image.appIcon(.logo)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: WelcomeMetrics.logoHeight(for: geometry))
    }
}
