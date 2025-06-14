//
//  UserState.swift
//  Yurtify
//
//  Created by dark type on 14.06.2025.
//

import SwiftUI

@MainActor
class AuthManager: ObservableObject {
    @Published var userState: UserState = .firstLaunch
    @Published var currentUser: User?
    @Published var isRefreshingToken = false
    @Published var isReAuthenticating = false
    
    private let userDefaultsService = UserDefaultsService()
    private let keychainService = KeychainService()
    private let tokenService: TokenService
    private let tokenMonitor = TokenMonitorService()
    
    var isFirstLaunch: Bool {
        userState == .firstLaunch
    }
    
    var isLoggedIn: Bool {
        userState == .loggedIn
    }
    
    var isGuest: Bool {
        userState == .guest
    }
    
    init() {
        self.tokenService = TokenService(keychainService: keychainService)
        
        checkAuthenticationStatus()
        startTokenMonitoring()
    }
    
    private func startTokenMonitoring() {
        tokenMonitor.startMonitoring { [weak self] in
            await self?.handleTokenStatus()
        }
    }
    
    func checkAuthenticationStatus() {
        if userDefaultsService.isFirstLaunch {
            userState = .firstLaunch
        } else if userDefaultsService.isUserLoggedIn {
            if let userData = keychainService.getUserData() {
                currentUser = userData
                userState = .loggedIn
                
                Task {
                    await handleTokenStatus()
                }
            } else {
                userDefaultsService.setUserLoggedIn(false)
                userState = .loggedOut
            }
        } else if userDefaultsService.isGuestMode {
            userState = .guest
        } else {
            userState = .loggedOut
        }
    }
    
    // MARK: - Token Management
    
    func handleTokenStatus() async {
        guard let user = currentUser,
              userState == .loggedIn,
              !isRefreshingToken && !isReAuthenticating
        else {
            return
        }
        
        do {
            if user.isRefreshTokenExpired || user.isRefreshTokenExpiringSoon {
                isReAuthenticating = true
                let newUser = try await tokenService.reAuthenticate(
                    phoneNumber: user.phoneNumber,
                    password: user.password
                )
                currentUser = newUser
                isReAuthenticating = false
                print("✅ Re-authentication successful")
                
            } else if user.isTokenExpired || user.isTokenExpiringSoon {
                isRefreshingToken = true
                let refreshedUser = try await tokenService.refreshAccessToken(for: user)
                currentUser = refreshedUser
                isRefreshingToken = false
                print("✅ Access token refreshed successfully")
            }
        } catch {
            isRefreshingToken = false
            isReAuthenticating = false
            print("❌ Token management failed: \(error)")
            logout()
        }
    }
    
    // MARK: - Auth Actions
    
    func continueAsGuest() {
        userDefaultsService.setGuestMode(true)
        userDefaultsService.setFirstLaunch(false)
        userState = .guest
    }
    
    func logout() {
        tokenMonitor.stopMonitoring()
        
        keychainService.clearUserData()
        
        userDefaultsService.setUserLoggedIn(false)
        userDefaultsService.setGuestMode(false)
        
        currentUser = nil
        userState = .loggedOut
        
        startTokenMonitoring()
    }
    
    func upgradeFromGuest() {
        userDefaultsService.setGuestMode(false)
    }
    
    // MARK: - Manual Operations (for testing)
    
    func manualTokenRefresh() async {
        guard let user = currentUser else { return }
        
        do {
            isRefreshingToken = true
            let refreshedUser = try await tokenService.refreshAccessToken(for: user)
            currentUser = refreshedUser
            isRefreshingToken = false
        } catch {
            isRefreshingToken = false
            print("Manual token refresh failed: \(error)")
        }
    }
    
    func manualReLogin() async {
        guard let user = currentUser else { return }
        
        do {
            isReAuthenticating = true
            let newUser = try await tokenService.reAuthenticate(
                phoneNumber: user.phoneNumber,
                password: user.password
            )
            currentUser = newUser
            isReAuthenticating = false
        } catch {
            isReAuthenticating = false
            print("Manual re-login failed: \(error)")
        }
    }
    
    func forceTokenExpiry() {
        guard let user = currentUser else { return }
        
        let expiredUser = User(
            id: user.id,
            name: user.name,
            surname: user.surname,
            patronymic: user.patronymic,
            phoneNumber: user.phoneNumber,
            email: user.email,
            token: user.token,
            refreshToken: user.refreshToken,
            tokenExpiresAt: Date().addingTimeInterval(-60),
            refreshTokenExpiresAt: user.refreshTokenExpiresAt,
            password: user.password
        )
        
        try? keychainService.updateUser(expiredUser)
        currentUser = expiredUser
    }
}
