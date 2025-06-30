//
//  TokenMonitorService.swift
//  Yurtify
//
//  Created by dark type on 14.06.2025.
//

import Foundation

final class TokenManager: Sendable {
    private let keychainService: KeychainService
    private let apiService: APIService
    
    init(keychainService: KeychainService, apiService: APIService) {
        self.keychainService = keychainService
        self.apiService = apiService
    }
    
    func validateTokens(for user: User) async throws -> User {
        let now = Date()
        
        if now >= user.refreshTokenExpiresAt {
            throw AuthError.refreshTokenExpired
        }
        
        if now >= user.accessTokenExpiresAt || isTokenExpiringSoon(user.accessTokenExpiresAt) {
            return try await refreshAccessToken(for: user)
        }
        
        return user
    }
    
    private func refreshAccessToken(for user: User) async throws -> User {
        do {
            let newAccessToken = try await apiService.refreshTokens(refreshToken: user.refreshToken)
            
            let updatedUser = User(
                id: user.id,
                name: user.name,
                surname: user.surname,
                patronymic: user.patronymic,
                phoneNumber: user.phoneNumber,
                email: user.email,
                accessToken: newAccessToken,
                refreshToken: user.refreshToken,
                accessTokenExpiresAt: Date().addingTimeInterval(15 * 60),
                refreshTokenExpiresAt: user.refreshTokenExpiresAt,
                password: user.password
            )
            
            try keychainService.storeUser(updatedUser)
            return updatedUser
            
        } catch {
            throw error
        }
    }
    
    private func isTokenExpiringSoon(_ expirationDate: Date) -> Bool {
        Date().addingTimeInterval(120) >= expirationDate
    }
}
