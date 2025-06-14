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
    
    // MARK: - Route Navigation
    
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
    
    func handleSuccessfulLogin() {
        currentRoute = .main
    }
    
    func handleSuccessfulRegistration() {
        currentRoute = .main
    }
    
    func handleLogout() {
        authManager?.logout()
        currentRoute = .welcome
    }
    
    func handleGuestUpgrade() {
        authManager?.upgradeFromGuest()
        currentRoute = .login
    }
    
    // MARK: - Initial Route Determination
    
    private func determineInitialRoute() {
        guard let authManager = authManager else { return }
        
        switch authManager.userState {
        case .firstLaunch:
            currentRoute = .welcome
        case .loggedIn, .guest:
            currentRoute = .main
        case .loggedOut:
            currentRoute = .welcome
        }
    }
    
    // MARK: - Auth State Observer
    
    func handleAuthStateChange() {
        guard let authManager = authManager else { return }
        
        switch authManager.userState {
        case .loggedOut:
            currentRoute = .welcome
        case .loggedIn, .guest:
            if currentRoute == .login || currentRoute == .register {
                currentRoute = .main
            }
        case .firstLaunch:
            currentRoute = .welcome
        }
    }
}
