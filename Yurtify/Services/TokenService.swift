//
//  TokenService.swift
//  Yurtify
//
//  Created by dark type on 14.06.2025.
//

import Foundation

final class TokenService: Sendable {
    private let keychainService: KeychainService
    
    init(keychainService: KeychainService) {
        self.keychainService = keychainService
    }
    
    // MARK: - Token Refresh

    func refreshAccessToken(for user: User) async throws -> User {
        let refreshedUser = try await performTokenRefresh(for: user)
        try keychainService.updateUser(refreshedUser)
        return refreshedUser
    }
    
    // MARK: - Re-Authentication

    func reAuthenticate(phoneNumber: String, password: String) async throws -> User {
        let newUser = try await performReAuthentication(
            phoneNumber: phoneNumber,
            password: password
        )
        try keychainService.updateUser(newUser)
        return newUser
    }
    
    // MARK: - Mock API Calls

    private func performTokenRefresh(for user: User) async throws -> User {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        if Int.random(in: 1...20) == 1 {
            throw AuthError.tokenRefreshFailed
        }
        
        let mockTokenResponse = MockTokenRefreshResponse(
            token: "refreshed_token_\(UUID().uuidString.prefix(8))",
            expiresIn: 900
        )
        
        return User(
            id: user.id,
            name: user.name,
            surname: user.surname,
            patronymic: user.patronymic,
            phoneNumber: user.phoneNumber,
            email: user.email,
            token: mockTokenResponse.token,
            refreshToken: user.refreshToken,
            tokenExpiresAt: Date().addingTimeInterval(TimeInterval(mockTokenResponse.expiresIn)),
            refreshTokenExpiresAt: user.refreshTokenExpiresAt,
            password: user.password
        )
    }
    
    private func performReAuthentication(phoneNumber: String, password: String) async throws -> User {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        if Int.random(in: 1...50) == 1 {
            throw AuthError.reLoginFailed
        }
        
        let mockLoginResponse = MockLoginResponse(
            user: MockUserData(
                id: UUID().uuidString,
                name: "Mock",
                surname: "User",
                patronymic: nil,
                phoneNumber: phoneNumber,
                email: nil
            ),
            token: "new_access_token_\(UUID().uuidString.prefix(8))",
            refreshToken: "new_refresh_token_\(UUID().uuidString.prefix(8))",
            accessTokenExpiresIn: 900,
            refreshTokenExpiresIn: 86400
        )
        
        return User(
            id: mockLoginResponse.user.id,
            name: mockLoginResponse.user.name,
            surname: mockLoginResponse.user.surname,
            patronymic: mockLoginResponse.user.patronymic,
            phoneNumber: mockLoginResponse.user.phoneNumber,
            email: mockLoginResponse.user.email,
            token: mockLoginResponse.token,
            refreshToken: mockLoginResponse.refreshToken,
            tokenExpiresAt: Date().addingTimeInterval(TimeInterval(mockLoginResponse.accessTokenExpiresIn)),
            refreshTokenExpiresAt: Date().addingTimeInterval(TimeInterval(mockLoginResponse.refreshTokenExpiresIn)),
            password: password
        )
    }
}
