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
        guard !isLoading else { return }
        
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
