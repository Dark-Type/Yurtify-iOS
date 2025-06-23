//
//  AppRoute.swift
//  Yurtify
//
//  Created by dark type on 14.06.2025.
//

import SwiftUI

enum AppRoute {
    case welcome
    case login
    case register
    case main
}

@MainActor
class AppRouter: ObservableObject {
    @Published var currentRoute: AppRoute = .welcome
    
    private var authManager: AuthManager?
    private var isReady = false
    
    // MARK: - Setup
    
    func setAuthManager(_ authManager: AuthManager) {
        self.authManager = authManager
        
        Task {
            try? await Task.sleep(nanoseconds: 100_000_000)
            await MainActor.run {
                determineInitialRoute()
                isReady = true
            }
        }
    }
    
    // MARK: - Navigation
    
    func navigateToWelcome() {
        currentRoute = .welcome
    }
    
    func navigateToLogin() {
        currentRoute = .login
    }
    
    func navigateToRegister() {
        currentRoute = .register
    }
    
    func navigateToMain() {
        currentRoute = .main
    }
    
    // MARK: - Auth Flow Actions
    
    func handleLogout() {
        authManager?.logout()
        
        currentRoute = .welcome
        
        Task {
            try? await Task.sleep(nanoseconds: 200_000_000)
            await MainActor.run {
                print("✅ Logout navigation complete")
            }
        }
    }
    
    // MARK: - Route Determination
    
    private func determineInitialRoute() {
        guard let authManager = authManager else {
            return
        }
        
        currentRoute = authManager.isAuthenticated ? .main : .welcome
    }
    
    func handleAuthStateChange(newAuthState: Bool) {
        if !isReady {
            return
        }
        
        if newAuthState {
            currentRoute = .main
        } else {
            if currentRoute == .main {
                currentRoute = .welcome
            }
        }
    }
}
