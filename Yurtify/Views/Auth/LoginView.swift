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
    
    @State private var phoneNumber = ""
    @State private var password = ""
    @State private var isLoading = false
    
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
            .navigationTitle("Sign In")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        appRouter.navigateToWelcome()
                    }
                }
            }
        }
    }
    
    private var loginContent: some View {
        VStack(spacing: 20) {
            VStack(spacing: 16) {
                TextField("Phone Number", text: $phoneNumber)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.phonePad)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
            }
            
            Button(action: handleLogin) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Sign In")
                }
            }
            .font(.app.headline(.semiBold))
            .foregroundColor(.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(.secondaryVariant)
            .cornerRadius(12)
            .disabled(isLoading || phoneNumber.isEmpty || password.isEmpty)
        }
    }
    
    private var switchToRegister: some View {
        HStack {
            Text("Don't have an account?")
                .foregroundColor(.app.textSecondary)
            
            Button("Sign Up") {
                appRouter.navigateToRegister()
            }
            .foregroundColor(.textPrimary)
        }
        .font(.app.callout(.medium))
    }
    
    private func handleLogin() {
        isLoading = true
        
        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            await MainActor.run {
                isLoading = false
                appRouter.handleSuccessfulLogin()
            }
        }
    }
}
