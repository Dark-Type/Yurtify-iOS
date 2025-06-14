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
    
    // MARK: - Computed Properties
    
    var isFormValid: Bool {
        !phoneNumber.isEmpty && !password.isEmpty && password.count >= 6
    }
    
    // MARK: - Actions
    
    func login(authManager: AuthManager) {
        guard isFormValid else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await authManager.login(
                    phoneNumber: phoneNumber,
                    password: password
                )
                
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func navigateToRegister(appRouter: AppRouter) {
        appRouter.navigateToRegister()
    }
    
    func navigateToWelcome(appRouter: AppRouter) {
        appRouter.navigateToWelcome()
    }
}
