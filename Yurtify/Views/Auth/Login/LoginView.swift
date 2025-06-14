//
//  LoginView.swift
//  Yurtify
//
//  Created by dark type on 14.06.2025.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var appRouter: AppRouter
    @StateObject private var viewModel = LoginViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                
                loginContent
                
                Spacer()
                
                switchToRegister
            }
            .padding(.horizontal, 24)
            .background(.base)
            .navigationTitle(L10n.Login.title)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { viewModel.navigateToWelcome(appRouter: appRouter) }) {
                        Image.appIcon(.goBackButton)
                            .foregroundColor(.textPrimary)
                    }
                }
            }
        }
    }
    
    private var loginContent: some View {
        VStack(spacing: 20) {
            VStack(spacing: 16) {
                TextField(L10n.Login.phone, text: $viewModel.phoneNumber)
                    .font(.app.inter(size: 16, weight: .semiBold))
                    .foregroundColor(.textFade)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.gray.opacity(0.3), lineWidth: 1)
                    )
                    .keyboardType(.phonePad)
                
                SecureField(L10n.Login.password, text: $viewModel.password)
                    .font(.app.inter(size: 16, weight: .semiBold))
                    .foregroundColor(.textFade)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.gray.opacity(0.3), lineWidth: 1)
                    )
            }
            
            Button(action: { viewModel.login(authManager: authManager) }) {
                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Text(L10n.Login.button)
                    }
                }
            }
            .font(.app.headline(.semiBold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(viewModel.isFormValid ? .primaryVariant : .gray)
            .cornerRadius(12)
            .disabled(!viewModel.isFormValid || viewModel.isLoading)
            .animation(.easeInOut(duration: 0.2), value: viewModel.isFormValid)
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.app.caption1(.medium))
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
    }
    
    private var switchToRegister: some View {
        HStack {
            Text("Нет аккаунта?")
                .foregroundColor(.app.textSecondary)
            
            Button(L10n.Registration.button) {
                viewModel.navigateToRegister(appRouter: appRouter)
            }
            .foregroundColor(.textPrimary)
        }
        .font(.app.callout(.medium))
    }
}
