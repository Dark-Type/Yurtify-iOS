//
//  RegistrationView.swift
//  Yurtify
//
//  Created by dark type on 14.06.2025.
//

import SwiftUI

struct RegistrationView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var appRouter: AppRouter
    
    @State private var name = ""
    @State private var surname = ""
    @State private var patronymic = ""
    @State private var phoneNumber = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    registrationContent
                    
                    switchToLogin
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
            }
            .background(.base)
            .navigationTitle("Sign Up")
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
    
    private var registrationContent: some View {
        VStack(spacing: 20) {
            VStack(spacing: 16) {
                TextField("Name", text: $name)
                    .textFieldStyle(.roundedBorder)
                
                TextField("Surname", text: $surname)
                    .textFieldStyle(.roundedBorder)
                
                TextField("Patronymic (Optional)", text: $patronymic)
                    .textFieldStyle(.roundedBorder)
                
                TextField("Phone Number", text: $phoneNumber)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.phonePad)
                
                TextField("Email (Optional)", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.emailAddress)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
            }
            
            Button(action: handleRegistration) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Create Account")
                }
            }
            .font(.app.headline(.semiBold))
            .foregroundColor(.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(.secondaryVariant)
            .cornerRadius(12)
            .disabled(isLoading || !isFormValid)
        }
    }
    
    private var switchToLogin: some View {
        HStack {
            Text("Already have an account?")
                .foregroundColor(.app.textSecondary)
            
            Button("Sign In") {
                appRouter.navigateToLogin()
            }
            .foregroundColor(.textPrimary)
        }
        .font(.app.callout(.medium))
    }
    
    private var isFormValid: Bool {
        !name.isEmpty && !surname.isEmpty && !phoneNumber.isEmpty && !password.isEmpty && password.count >= 6
    }
    
    private func handleRegistration() {
        isLoading = true
        
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            
            await MainActor.run {
                isLoading = false
                appRouter.handleSuccessfulRegistration()
            }
        }
    }
}
