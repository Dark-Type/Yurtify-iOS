//
//  ChangePasswordSheet.swift
//  Yurtify
//
//  Created by dark type on 30.06.2025.
//

import SwiftUI

struct ChangePasswordSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    
    @State private var isLoading = false
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    @State private var showCurrentPassword = false
    @State private var showNewPassword = false
    @State private var showConfirmPassword = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    
                    passwordFieldsSection
                    
                    passwordRequirementsSection
                    
                    Spacer(minLength: 50)
                }
                .padding()
            }
            .background(Color.app.base)
            .navigationTitle("Change Password")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    changePassword()
                }
                .disabled(isLoading || !isFormValid)
            )
            .alert("Change Password", isPresented: $showingAlert) {
                Button("OK") {
                    if alertMessage.contains("successfully") {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "lock.shield")
                .font(.system(size: 50))
                .foregroundColor(.app.primaryVariant)
            
            Text("Update Your Password")
                .font(.app.title3(.semiBold))
                .foregroundColor(.app.textPrimary)
            
            Text("Choose a strong password to keep your account secure")
                .font(.app.body())
                .foregroundColor(.app.textSecondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var passwordFieldsSection: some View {
        VStack(spacing: 20) {
            SecureTextField(
                title: "Current Password",
                text: $currentPassword,
                placeholder: "Enter your current password",
                showPassword: $showCurrentPassword
            )
            
            SecureTextField(
                title: "New Password",
                text: $newPassword,
                placeholder: "Enter your new password",
                showPassword: $showNewPassword
            )
            
            SecureTextField(
                title: "Confirm New Password",
                text: $confirmPassword,
                placeholder: "Confirm your new password",
                showPassword: $showConfirmPassword
            )
        }
    }
    
    private var passwordRequirementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Password Requirements")
                .font(.app.subheadline(.semiBold))
                .foregroundColor(.app.textPrimary)
            
            VStack(alignment: .leading, spacing: 8) {
                PasswordRequirementRow(
                    text: "At least 8 characters",
                    isValid: newPassword.count >= 8
                )
                
                PasswordRequirementRow(
                    text: "Contains uppercase letter",
                    isValid: newPassword.rangeOfCharacter(from: .uppercaseLetters) != nil
                )
                
                PasswordRequirementRow(
                    text: "Contains lowercase letter",
                    isValid: newPassword.rangeOfCharacter(from: .lowercaseLetters) != nil
                )
                
                PasswordRequirementRow(
                    text: "Contains number",
                    isValid: newPassword.rangeOfCharacter(from: .decimalDigits) != nil
                )
                
                PasswordRequirementRow(
                    text: "Passwords match",
                    isValid: !newPassword.isEmpty && newPassword == confirmPassword
                )
            }
        }
        .padding()
        .background(Color.app.accentLight)
        .cornerRadius(12)
    }
    
    private var isFormValid: Bool {
        return !currentPassword.isEmpty &&
            newPassword.count >= 8 &&
            newPassword == confirmPassword &&
            newPassword.rangeOfCharacter(from: .uppercaseLetters) != nil &&
            newPassword.rangeOfCharacter(from: .lowercaseLetters) != nil &&
            newPassword.rangeOfCharacter(from: .decimalDigits) != nil
    }
    
    private func changePassword() {
        guard validatePasswords() else { return }
        
        isLoading = true
        
        Task {
            do {
                try await Task.sleep(for: .seconds(2))
                
                await MainActor.run {
                    alertMessage = "Password changed successfully!"
                    showingAlert = true
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    alertMessage = "Failed to change password. Please try again."
                    showingAlert = true
                    isLoading = false
                }
            }
        }
    }
    
    private func validatePasswords() -> Bool {
        if currentPassword.isEmpty {
            alertMessage = "Please enter your current password"
            showingAlert = true
            return false
        }
        
        if newPassword.count < 8 {
            alertMessage = "New password must be at least 8 characters"
            showingAlert = true
            return false
        }
        
        if newPassword != confirmPassword {
            alertMessage = "Passwords do not match"
            showingAlert = true
            return false
        }
        
        if currentPassword == newPassword {
            alertMessage = "New password must be different from current password"
            showingAlert = true
            return false
        }
        
        return true
    }
}

struct SecureTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    @Binding var showPassword: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.app.subheadline(.semiBold))
                .foregroundColor(.app.textPrimary)
            
            HStack {
                ZStack(alignment: .leading) {
                    if text.isEmpty {
                        Text(placeholder)
                            .font(.app.inter(size: 16, weight: .semiBold))
                            .foregroundColor(.textPrimaryOpacity)
                            .padding(.horizontal, 16)
                            .allowsHitTesting(false)
                    }

                    if showPassword {
                        TextField("", text: $text)
                            .font(.app.inter(size: 16, weight: .semiBold))
                            .foregroundColor(.textPrimaryOpacity)
                            .padding(.horizontal, 16)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    } else {
                        SecureField("", text: $text)
                            .font(.app.inter(size: 16, weight: .semiBold))
                            .foregroundColor(.textPrimaryOpacity)
                            .padding(.horizontal, 16)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                }
                
                Button(action: {
                    showPassword.toggle()
                }) {
                    Image(systemName: showPassword ? "eye.slash" : "eye")
                        .foregroundColor(.app.textSecondary)
                }
                .padding(.trailing, 16)
            }
            .padding(.vertical, 12)
            .background(.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.gray.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

struct PasswordRequirementRow: View {
    let text: String
    let isValid: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isValid ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isValid ? .green : .app.textFade)
                .font(.system(size: 16))
            
            Text(text)
                .font(.app.caption1())
                .foregroundColor(isValid ? .green : .app.textSecondary)
            
            Spacer()
        }
    }
}
