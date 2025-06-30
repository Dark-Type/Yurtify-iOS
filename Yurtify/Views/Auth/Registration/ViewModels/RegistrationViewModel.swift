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
            password.rangeOfCharacter(from: .decimalDigits) != nil &&
        hasSpecialCharacter(password)
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
   
    private func hasSpecialCharacter(_ password: String) -> Bool {
        let specialCharacters = CharacterSet(charactersIn: "!@#$%^&*()_+-=[]{}|;':\",./<>?")
        return password.rangeOfCharacter(from: specialCharacters) != nil
    }

    func validateForm() -> String? {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedSurname = surname.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPhoneNumber = phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        
        print("🔍 Registration Validation Debug:")
        print("   Name: '\(name)' -> '\(trimmedName)' (length: \(trimmedName.count))")
        print("   Surname: '\(surname)' -> '\(trimmedSurname)' (length: \(trimmedSurname.count))")
        print("   Phone: '\(phoneNumber)' -> '\(trimmedPhoneNumber)' (length: \(trimmedPhoneNumber.count))")
        print("   Email: '\(email)' (length: \(email.count))")
        print("   Password: '\(password)' (length: \(password.count))")
        print("   Confirmation: '\(confirmation)' (length: \(confirmation.count))")
        print("   isEmailValid: \(isEmailValid)")
        print("   isPasswordValid: \(isPasswordValid)")
        print("   doPasswordsMatch: \(doPasswordsMatch)")
        print("   isFormValid: \(isFormValid)")
        
        if trimmedName.isEmpty {
            print("❌ Name validation failed")
            return "First name is required"
        }
        if !hasSpecialCharacter(password) {
            print("❌ Password special character validation failed")
            return "Password must contain at least one special character (!@#$%^&*()_+-=[]{}|;':\",./<>?)"
        }
        if password.rangeOfCharacter(from: .decimalDigits) == nil {
            print("❌ Password digit validation failed")
            return "Password must contain at least one number"
        }
        
        if trimmedSurname.isEmpty {
            print("❌ Surname validation failed")
            return "Last name is required"
        }
        
        if trimmedPhoneNumber.isEmpty {
            print("❌ Phone number validation failed")
            return "Phone number is required"
        }
        
        if email.isEmpty {
            print("❌ Email empty validation failed")
            return "Email is required"
        }
        
        if !isEmailValid {
            print("❌ Email format validation failed")
            return "Please enter a valid email address"
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
        
        if confirmation.isEmpty {
            print("❌ Confirmation empty validation failed")
            return "Please confirm your password"
        }
        
        if password != confirmation {
            print("❌ Password match validation failed")
            print("   Password: '\(password)'")
            print("   Confirmation: '\(confirmation)'")
            return "Passwords do not match"
        }
        
        print("✅ Registration validation passed")
        return nil
    }
    
    // MARK: - Actions
    
    func register(authManager: AuthManager) {
        guard !isLoading else { return }
        
        print("🚀 Registration attempt started")
        print("   Name: '\(name)'")
        print("   Surname: '\(surname)'")
        print("   Phone: '\(phoneNumber)'")
        print("   Email: '\(email)'")
        print("   Password length: \(password.count)")
        
        if let validationError = validateForm() {
            print("❌ Registration validation failed: \(validationError)")
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
                
                print("📡 Calling authManager.register...")
                print("   Registration data: \(registrationData)")
                
                try await authManager.register(data: registrationData)
                
                print("✅ Registration successful")
                await MainActor.run {
                    isLoading = false
                }
                
            } catch {
                print("❌ Registration failed: \(error)")
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
