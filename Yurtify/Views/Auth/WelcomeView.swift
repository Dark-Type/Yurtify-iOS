//
//  WelcomeView.swift
//  Yurtify
//
//  Created by dark type on 14.06.2025.
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var appRouter: AppRouter
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            welcomeContent
            
            Spacer()
            
            actionButtons
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
        .background(.base)
    }
    
    private var welcomeContent: some View {
        VStack(spacing: 20) {
            Image.appIcon(.logoWithText)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 120)
            
            Text(L10n.Welcome.title)
                .font(.app.largeTitle(.bold))
                .foregroundColor(.textPrimary)
            
            Text(L10n.Welcome.quote)
                .font(.app.body(.regular))
                .foregroundColor(.app.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 16) {
            Button(action: {
                appRouter.navigateToRegister()
            }) {
                Text(L10n.Welcome.register)
                    .font(.app.headline(.semiBold))
                    .foregroundColor(.base)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(.secondaryVariant)
                    .cornerRadius(12)
            }
            
            Button(action: {
                appRouter.navigateToLogin()
            }) {
                Text(L10n.Welcome.login)
                    .font(.app.headline(.semiBold))
                    .foregroundColor(.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(.base)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.secondaryVariant, lineWidth: 2)
                    )
            }
            
            HStack {
                Rectangle()
                    .fill(.textPrimary)
                    .frame(height: 1)
                
                Text(L10n.Welcome.or)
                    .font(.app.caption1(.medium))
                    .foregroundColor(.textPrimary)
                    .padding(.horizontal, 12)
                
                Rectangle()
                    .fill(.textPrimary)
                    .frame(height: 1)
            }
            
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
}
