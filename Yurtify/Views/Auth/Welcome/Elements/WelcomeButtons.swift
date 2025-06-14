//
//  WelcomePrimaryButton.swift
//  Yurtify
//
//  Created by dark type on 15.06.2025.
//


import SwiftUI

struct WelcomePrimaryButton: View {
    let title: String
    let foregroundColor: Color
    let backgroundColor: Color
    let geometry: GeometryProxy
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.app.headline(.semiBold))
                .foregroundColor(foregroundColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, WelcomeMetrics.buttonPadding(for: geometry))
                .background(backgroundColor)
                .cornerRadius(12)
        }
    }
}

struct WelcomeSecondaryButton: View {
    let title: String
    let geometry: GeometryProxy
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.app.headline(.semiBold))
                .foregroundColor(.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, WelcomeMetrics.buttonPadding(for: geometry))
                .background(.base)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.secondaryVariant, lineWidth: 2)
                )
        }
    }
}

struct WelcomeOrDivider: View {
    let geometry: GeometryProxy
    
    var body: some View {
        HStack {
            Rectangle()
                .fill(.textPrimary)
                .frame(height: 1)
            
            Text(L10n.Welcome.or)
                .font(.app.caption1(.medium))
                .foregroundColor(.textPrimary)
                .padding(.horizontal, WelcomeMetrics.orPadding(for: geometry))
            
            Rectangle()
                .fill(.textPrimary)
                .frame(height: 1)
        }
    }
}