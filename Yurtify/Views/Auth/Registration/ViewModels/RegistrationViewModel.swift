//
//  RegistrationView.swift
//  Yurtify
//
//  Created by dark type on 15.06.2025.
//

import Combine
import Foundation

@MainActor
class RegistrationViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var name = ""
    @Published var surname = ""
    @Published var patronymic = ""
    @Published var phoneNumber = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmation = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Validation Properties
    
    var isEmailValid: Bool {
        if email.isEmpty { return false }
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    var isPasswordValid: Bool {
        password.count >= 8 &&
            password.rangeOfCharacter(from: .uppercaseLetters) != nil &&
            password.rangeOfCharacter(from: .lowercaseLetters) != nil &&
            password.rangeOfCharacter(from: .decimalDigits) != nil
    }
    
    var doPasswordsMatch: Bool {
        !password.isEmpty && password == confirmation
    }
    
    // MARK: - Computed Properties
    
    var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !surname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            isEmailValid &&
            isPasswordValid &&
            doPasswordsMatch
    }
    
    // MARK: - Validation Methods
    
    func validateForm() -> String? {
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "First name is required"
        }
        
        if surname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Last name is required"
        }
        
        if phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Phone number is required"
        }
        
        if email.isEmpty {
            return "Email is required"
        }
        
        if !isEmailValid {
            return "Please enter a valid email address"
        }
        
        if password.isEmpty {
            return "Password is required"
        }
        
        if password.count < 8 {
            return "Password must be at least 8 characters"
        }
        
        if password.rangeOfCharacter(from: .uppercaseLetters) == nil {
            return "Password must contain at least one uppercase letter"
        }
        
        if password.rangeOfCharacter(from: .lowercaseLetters) == nil {
            return "Password must contain at least one lowercase letter"
        }
        
        if password.rangeOfCharacter(from: .decimalDigits) == nil {
            return "Password must contain at least one number"
        }
        
        if confirmation.isEmpty {
            return "Please confirm your password"
        }
        
        if password != confirmation {
            return "Passwords do not match"
        }
        
        return nil
    }
    
    // MARK: - Actions
    
    func register(authManager: AuthManager) {
        guard !isLoading else { return }
        
        if let validationError = validateForm() {
            errorMessage = validationError
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let registrationData = RegistrationData(
                    name: name,
                    surname: surname,
                    patronymic: patronymic.isEmpty ? nil : patronymic,
                    phoneNumber: phoneNumber,
                    email: email,
                    password: password
                )
                
                try await authManager.register(data: registrationData)
                
                await MainActor.run {
                    isLoading = false
                }
                
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func navigateToLogin(appRouter: AppRouter) {
        appRouter.navigateToLogin()
    }
    
    func navigateToWelcome(appRouter: AppRouter) {
        appRouter.navigateToWelcome()
    }
}
