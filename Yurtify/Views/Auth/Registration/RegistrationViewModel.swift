//
//  RegistrationView.swift
//  Yurtify
//
//  Created by dark type on 15.06.2025.
//

import Combine

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
    
    // MARK: - Computed Properties
    
    var isFormValid: Bool {
        !name.isEmpty &&
            !surname.isEmpty &&
            !phoneNumber.isEmpty &&
            !email.isEmpty &&
            !password.isEmpty &&
            password.count >= 6 &&
            password == confirmation
    }
    
    // MARK: - Actions (Dependencies injected via method parameters)
    
    func register(authManager: AuthManager) {
        guard isFormValid else { return }
        
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
