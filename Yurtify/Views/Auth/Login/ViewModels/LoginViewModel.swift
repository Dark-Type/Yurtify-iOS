//
//  LoginViewModel.swift
//  Yurtify
//
//  Created by dark type on 15.06.2025.
//
import Combine
import Foundation

@MainActor
class LoginViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var phoneNumber = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Validation Properties
    
    var isPasswordValid: Bool {
        password.count >= 8 &&
            password.rangeOfCharacter(from: .uppercaseLetters) != nil &&
            password.rangeOfCharacter(from: .lowercaseLetters) != nil &&
            password.rangeOfCharacter(from: .decimalDigits) != nil &&
        hasSpecialCharacter(password)
    }

    private func hasSpecialCharacter(_ password: String) -> Bool {
        let specialCharacters = CharacterSet(charactersIn: "!@#$%^&*()_+-=[]{}|;':\",./<>?")
        return password.rangeOfCharacter(from: specialCharacters) != nil
    }

    var isPhoneNumberValid: Bool {
        !phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - Computed Properties
    
    var isFormValid: Bool {
        isPhoneNumberValid && isPasswordValid
    }
    
    // MARK: - Validation Methods
    
    func validateForm() -> String? {
        let trimmedPhoneNumber = phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
           
        print("🔍 Login Validation Debug:")
        print("   Phone Number: '\(phoneNumber)' (length: \(phoneNumber.count))")
        print("   Trimmed Phone: '\(trimmedPhoneNumber)' (length: \(trimmedPhoneNumber.count))")
        print("   Password: '\(password)' (length: \(password.count))")
        print("   isPhoneNumberValid: \(isPhoneNumberValid)")
        print("   isPasswordValid: \(isPasswordValid)")
        print("   isFormValid: \(isFormValid)")
           
        if trimmedPhoneNumber.isEmpty {
            print("❌ Phone number validation failed")
            return "Phone number is required"
        }
           
        if password.isEmpty {
            print("❌ Password empty validation failed")
            return "Password is required"
        }
           
        if password.count < 8 {
            print("❌ Password length validation failed: \(password.count)")
            return "Password must be at least 8 characters"
        }
           
        if password.rangeOfCharacter(from: .uppercaseLetters) == nil {
            print("❌ Password uppercase validation failed")
            return "Password must contain at least one uppercase letter"
        }
           
        if password.rangeOfCharacter(from: .lowercaseLetters) == nil {
            print("❌ Password lowercase validation failed")
            return "Password must contain at least one lowercase letter"
        }
           
        if password.rangeOfCharacter(from: .decimalDigits) == nil {
            print("❌ Password digit validation failed")
            return "Password must contain at least one number"
        }
           
        print("✅ Login validation passed")
        return nil
    }
    
    // MARK: - Actions
    
    func login(authManager: AuthManager) {
        guard !isLoading else { return }
        
        print("🚀 Login attempt started")
        print("   Phone: '\(phoneNumber)'")
        print("   Password length: \(password.count)")
        
        if let validationError = validateForm() {
            print("❌ Login validation failed: \(validationError)")
            errorMessage = validationError
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                print("📡 Calling authManager.login...")
                try await authManager.login(
                    phoneNumber: phoneNumber,
                    password: password
                )
                
                print("✅ Login successful")
                await MainActor.run {
                    isLoading = false
                }
                
            } catch {
                print("❌ Login failed: \(error)")
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    func resetState() {
        phoneNumber = ""
        password = ""
        isLoading = false
        errorMessage = nil
    }
    
    func navigateToRegister(appRouter: AppRouter) {
        appRouter.navigateToRegister()
    }
    
    func navigateToWelcome(appRouter: AppRouter) {
        appRouter.navigateToWelcome()
    }
}
