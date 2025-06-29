//
//  LoginViewModel.swift
//  Yurtify
//
//  Created by dark type on 15.06.2025.
//
import Combine

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
        password.rangeOfCharacter(from: .decimalDigits) != nil
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
        if phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Phone number is required"
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
        
        return nil
    }
    
    // MARK: - Actions
    
    func login(authManager: AuthManager) {
           guard !isLoading else { return }
           
           if let validationError = validateForm() {
               errorMessage = validationError
               return
           }
           
           isLoading = true
           errorMessage = nil
           
           Task {
               do {
                   try await authManager.login(
                       phoneNumber: phoneNumber,
                       password: password
                   )
                   
                   await MainActor.run {
                       isLoading = false
                       Task {
                           try? await Task.sleep(nanoseconds: 100_000_000)
                       }
                   }
                   
               } catch {
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
