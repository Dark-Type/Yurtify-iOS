//
//  WelcomeQuoteSection.swift
//  Yurtify
//
//  Created by dark type on 15.06.2025.
//

import SwiftUI

struct WelcomeQuoteSection: View {
    let geometry: GeometryProxy
    
    var body: some View {
        VStack(spacing: WelcomeMetrics.quoteSpacing(for: geometry)) {
            topDivider
            quoteText
            bottomDivider
        }
    }
    
    // MARK: - Subviews
    
    private var topDivider: some View {
        Image.appIcon(.dividerTop)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: WelcomeMetrics.dividerHeight(for: geometry))
    }
    
    private var quoteText: some View {
        Text(L10n.Welcome.quote)
            .font(.app.body(.regular))
            .foregroundColor(.app.textSecondary)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
    }
    
    private var bottomDivider: some View {
        Image.appIcon(.dividerBottom)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: WelcomeMetrics.dividerHeight(for: geometry))
    }
}
