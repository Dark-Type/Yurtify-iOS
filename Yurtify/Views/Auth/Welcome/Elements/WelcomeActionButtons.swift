//
//  WelcomeActionButtons.swift
//  Yurtify
//
//  Created by dark type on 15.06.2025.
//

import SwiftUI

struct WelcomeActionButtons: View {
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
            appRouter.navigateToRegister()
        }
    }
    
    private var loginButton: some View {
        WelcomeSecondaryButton(
            title: L10n.Welcome.login,
            geometry: geometry
        ) {
            appRouter.navigateToLogin()
        }
    }
    
    private var guestButton: some View {
        Button(action: {
            authManager.continueAsGuest()
            appRouter.navigateToMain()
        }) {
            Text(L10n.Welcome.guest)
                .font(.app.callout(.medium))
                .foregroundColor(.app.textSecondary)
                .underline()
        }
    }
}
