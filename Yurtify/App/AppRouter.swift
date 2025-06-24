//
//  AppRoute.swift
//  Yurtify
//
//  Created by dark type on 14.06.2025.
//

import Combine
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
    
    private let userDefaultsService = UserDefaultsService()
    private let keychainService = KeychainService()
    private var cancellables = Set<AnyCancellable>()
    
    func setAuthManager(_ authManager: AuthManager) {
        if authManager.isAuthenticated {
            currentRoute = .main
        } else if userDefaultsService.shouldBeAuthenticated {
            currentRoute = .login
        } else if let _ = keychainService.getUserData() {
            currentRoute = .login
        } else {
            currentRoute = .welcome
        }
        
        authManager.$isAuthenticated
            .dropFirst()
            .sink { [weak self] isAuthenticated in
                self?.handleAuthStateChange(newAuthState: isAuthenticated)
            }
            .store(in: &cancellables)
    }
    
    func handleAuthStateChange(newAuthState: Bool) {
        if newAuthState {
            currentRoute = .main
        } else {
            currentRoute = .login
        }
    }
    
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
}
