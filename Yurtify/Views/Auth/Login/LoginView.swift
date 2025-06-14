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
        GeometryReader { geometry in
            NavigationStack {
                VStack(spacing: 0) {
                    logoSection(geometry: geometry)
                    
                    Spacer()
                    
                    loginFormSection(geometry: geometry)
                    
                    Spacer()
                    
                    footerSection(geometry: geometry)
                }
                .padding(.horizontal, LoginMetrics.horizontalPadding(for: geometry))
                .background(.base)
                .navigationTitle(L10n.Login.title)
                .navigationBarTitleDisplayMode(.large)
                .navigationTitleColor(.textPrimary)
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
    }
    
    // MARK: - Logo Section
    
    private func logoSection(geometry: GeometryProxy) -> some View {
        VStack {
            Spacer()
                .frame(height: LoginMetrics.logoTopSpacing(for: geometry))
            
            Image.appIcon(.logo)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: LoginMetrics.logoHeight(for: geometry))
            
            Spacer()
        }
        .frame(height: geometry.size.height * 0.5)
    }
    
    // MARK: - Login Form Section
    
    private func loginFormSection(geometry: GeometryProxy) -> some View {
        VStack(spacing: LoginMetrics.sectionSpacing(for: geometry)) {
            loginFields(geometry: geometry)
            loginButton(geometry: geometry)
            errorSection
        }
    }
    
    private func loginFields(geometry: GeometryProxy) -> some View {
        VStack(spacing: LoginMetrics.textFieldSpacing(for: geometry)) {
            RegistrationTextField(
                placeholder: L10n.Login.phone,
                text: $viewModel.phoneNumber,
                keyboardType: .phonePad
            )
            
            RegistrationSecureField(
                placeholder: L10n.Login.password,
                text: $viewModel.password
            )
        }
    }
    
    private func loginButton(geometry: GeometryProxy) -> some View {
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
            .font(.app.headline(.semiBold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, LoginMetrics.buttonPadding(for: geometry))
            .background(viewModel.isFormValid ? .primaryVariant : .gray)
            .cornerRadius(12)
            .contentShape(Rectangle())
        }
        .disabled(!viewModel.isFormValid || viewModel.isLoading)
        .animation(.easeInOut(duration: 0.2), value: viewModel.isFormValid)
    }
    
    @ViewBuilder
    private var errorSection: some View {
        if let errorMessage = viewModel.errorMessage {
            Text(errorMessage)
                .font(.app.caption1(.medium))
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
    
    // MARK: - Footer Section
    
    private func footerSection(geometry: GeometryProxy) -> some View {
        HStack {
            Text(L10n.Login.noAccount)
                .foregroundColor(.app.textSecondary)
                
            Button(L10n.Registration.button) {
                viewModel.navigateToRegister(appRouter: appRouter)
            }
            .foregroundColor(.textPrimary)
        }
        .font(.app.callout(.medium))
        .padding(.bottom, LoginMetrics.footerBottomPadding(for: geometry))
    }
}
