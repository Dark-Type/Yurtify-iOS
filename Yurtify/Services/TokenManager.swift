//
//  TokenMonitorService.swift
//  Yurtify
//
//  Created by dark type on 14.06.2025.
//

import Foundation

final class TokenManager: Sendable {
    private let keychainService: KeychainService
    private let authAPIService = AuthAPIService()
    
    init(keychainService: KeychainService) {
        self.keychainService = keychainService
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
            let refreshResponse = try await authAPIService.refreshToken(refreshToken: user.refreshToken)
            
            let updatedUser = User(
                id: user.id,
                name: user.name,
                surname: user.surname,
                patronymic: user.patronymic,
                phoneNumber: user.phoneNumber,
                email: user.email,
                accessToken: refreshResponse.accessToken,
                refreshToken: user.refreshToken,
                accessTokenExpiresAt: Date().addingTimeInterval(TimeInterval(refreshResponse.expiresIn)),
                refreshTokenExpiresAt: user.refreshTokenExpiresAt,
                password: user.password
            )
            
            do {
                try keychainService.storeUser(updatedUser)
                return updatedUser
            } catch {
                throw AuthError.storageError
            }
            
        } catch {
            throw error
        }
    }
    
    private func isTokenExpiringSoon(_ expirationDate: Date) -> Bool {
        Date().addingTimeInterval(120) >= expirationDate
    }
}
