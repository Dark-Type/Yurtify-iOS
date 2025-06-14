//
//  WelcomeActionButtons.swift
//  Yurtify
//
//  Created by dark type on 15.06.2025.
//

import SwiftUI

struct WelcomeActionButtons: View {
    @ObservedObject var viewModel: WelcomeViewModel
    let authManager: AuthManager
    let appRouter: AppRouter
    let geometry: GeometryProxy
    
    var body: some View {
        VStack(spacing: WelcomeMetrics.buttonSpacing(for: geometry)) {
            registerButton
            loginButton
            WelcomeOrDivider(geometry: geometry)
            guestButton
        }
    }
    
    // MARK: - Button Components
    
    private var registerButton: some View {
        WelcomePrimaryButton(
            title: L10n.Welcome.register,
            foregroundColor: .base,
            backgroundColor: .secondaryVariant,
            geometry: geometry
        ) {
            viewModel.navigateToRegister(appRouter: appRouter)
        }
    }
    
    private var loginButton: some View {
        WelcomeSecondaryButton(
            title: L10n.Welcome.login,
            geometry: geometry
        ) {
            viewModel.navigateToLogin(appRouter: appRouter)
        }
    }
    
    private var guestButton: some View {
        Button(action: {
            viewModel.continueAsGuest(authManager: authManager, appRouter: appRouter)
        }) {
            HStack(spacing: 8) {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .app.textSecondary))
                        .scaleEffect(0.8)
                } else {
                    Text(L10n.Welcome.guest)
                        .font(.app.callout(.medium))
                        .foregroundColor(.app.textSecondary)
                        .underline()
                }
            }
        }
        .disabled(viewModel.isLoading)
    }
}
