//
//  UserState.swift
//  Yurtify
//
//  Created by dark type on 14.06.2025.
//

import Combine
import SwiftUI

@MainActor
final class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    
    private let userDefaultsService = UserDefaultsService()
    private let keychainService = KeychainService()
    private let authAPIService = AuthAPIService()
    private let tokenManager = TokenManager(keychainService: KeychainService())
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        checkAuthenticationStatus()
        startTokenMonitoring()
    }
    
    // MARK: - Initial Setup
    
    func checkAuthenticationStatus() {
        if userDefaultsService.shouldBeAuthenticated {
            if let userData = keychainService.getUserData() {
                currentUser = userData
                isAuthenticated = true
                
                Task {
                    do {
                        let updatedUser = try await tokenManager.validateTokens(for: userData)
                        await MainActor.run {
                            if updatedUser != userData {
                                currentUser = updatedUser
                            }
                        }
                    } catch {
                        print("Token validation failed during startup: \(error)")
                        await MainActor.run {
                            logout()
                        }
                    }
                }
            } else {
                userDefaultsService.setShouldBeAuthenticated(false)
                isAuthenticated = false
            }
        } else {
            isAuthenticated = false
        }
    }
    
    private func startTokenMonitoring() {
        Timer.publish(every: 300, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task {
                    await self?.validateCurrentTokens()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Authentication Actions
    
    func login(phoneNumber: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let loginResponse = try await authAPIService.login(
                phoneNumber: phoneNumber,
                password: password
            )
            
            let user = User(from: loginResponse, password: password)
            
            do {
                try keychainService.storeUser(user)
                userDefaultsService.setShouldBeAuthenticated(true)
                
                currentUser = user
                isAuthenticated = true
            } catch {
                throw AuthError.storageError
            }
            
        } catch {
            throw error
        }
    }
    
    func register(data: RegistrationData) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let registerResponse = try await authAPIService.register(data: data)
            
            let user = User(from: registerResponse, password: data.password)
            
            do {
                try keychainService.storeUser(user)
                userDefaultsService.setShouldBeAuthenticated(true)
                
                currentUser = user
                isAuthenticated = true
            } catch {
                throw AuthError.storageError
            }
            
        } catch {
            throw error
        }
    }
    
    func logout() {
        keychainService.clearUserData()
        userDefaultsService.setShouldBeAuthenticated(false)
        
        currentUser = nil
        isAuthenticated = false
    }
    
    // MARK: - Token Management
    
    private func validateCurrentTokens() async {
        guard let user = currentUser else { return }
        
        do {
            let updatedUser = try await tokenManager.validateTokens(for: user)
            await MainActor.run {
                if updatedUser != user {
                    currentUser = updatedUser
                }
            }
        } catch {
            print("Token validation failed: \(error)")
            await MainActor.run {
                logout()
            }
        }
    }
}

extension AuthManager {
    // MARK: - Guest Mode
    
    func continueAsGuest() {
        keychainService.clearUserData()
        userDefaultsService.setShouldBeAuthenticated(false)
        
        currentUser = nil
        isAuthenticated = false
        
        print("✅ Continuing as guest - no authentication required")
    }
}
