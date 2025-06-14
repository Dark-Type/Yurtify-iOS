//
//  WelcomeViewModel.swift
//  Yurtify
//
//  Created by dark type on 15.06.2025.
//

import SwiftUI

@MainActor
class WelcomeViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var isLoading = false
    
    // MARK: - Actions
    
    func navigateToRegister(appRouter: AppRouter) {
        appRouter.navigateToRegister()
    }
    
    func navigateToLogin(appRouter: AppRouter) {
        appRouter.navigateToLogin()
    }
    
    func continueAsGuest(authManager: AuthManager, appRouter: AppRouter) {
        isLoading = true
        
        Task {
            authManager.continueAsGuest()
            
            try? await Task.sleep(nanoseconds: 300_000_000)
            
            await MainActor.run {
                isLoading = false
                appRouter.navigateToMain()
            }
        }
    }
}
