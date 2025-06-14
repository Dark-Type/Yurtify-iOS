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
    
    // MARK: - Setup
    
    func setAuthManager(_ authManager: AuthManager) {
        self.authManager = authManager
        determineInitialRoute()
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
    
    // MARK: - Auth Flow Actions (Simplified)
    
    func handleLogout() {
        authManager?.logout()
        currentRoute = .welcome
    }
    
    // MARK: - Route Determination
    
    private func determineInitialRoute() {
        guard let authManager = authManager else { return }
        
        if authManager.isAuthenticated {
            currentRoute = .main
        } else {
            currentRoute = .welcome
        }
    }
    
    func handleAuthStateChange() {
        guard let authManager = authManager else { return }
        
        if authManager.isAuthenticated {
            currentRoute = .main
        } else {
            if currentRoute != .main {
                currentRoute = .welcome
            }
        }
    }
}
