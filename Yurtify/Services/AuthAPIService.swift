//
//  AuthAPIService.swift
//  Yurtify
//
//  Created by dark type on 15.06.2025.
//

import Foundation

final class AuthAPIService: Sendable {
    // MARK: - Login
    
    func login(phoneNumber: String, password: String) async throws -> LoginResponse {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        if phoneNumber.isEmpty || password.isEmpty {
            throw AuthError.invalidCredentials
        }
        
        if Int.random(in: 1...20) == 1 {
            throw AuthError.loginFailed
        }
        
        return LoginResponse(
            id: UUID().uuidString,
            name: "John",
            surname: "Doe",
            patronymic: nil,
            phoneNumber: phoneNumber,
            email: "john.doe@example.com",
            accessToken: "access_token_\(UUID().uuidString.prefix(8))",
            refreshToken: "refresh_token_\(UUID().uuidString.prefix(8))",
            accessTokenExpiresIn: 15 * 60,
            refreshTokenExpiresIn: 24 * 60 * 60
        )
    }
    
    // MARK: - Register
    
    func register(data: RegistrationData) async throws -> RegisterResponse {
        try await Task.sleep(nanoseconds: 1_500_000_000)
        
        if data.name.isEmpty || data.surname.isEmpty || data.phoneNumber.isEmpty {
            throw AuthError.invalidData
        }
        
        if Int.random(in: 1...33) == 1 {
            throw AuthError.registrationFailed
        }
        
        return RegisterResponse(
            id: UUID().uuidString,
            name: data.name,
            surname: data.surname,
            patronymic: data.patronymic,
            phoneNumber: data.phoneNumber,
            email: data.email,
            accessToken: "access_token_\(UUID().uuidString.prefix(8))",
            refreshToken: "refresh_token_\(UUID().uuidString.prefix(8))",
            accessTokenExpiresIn: 15 * 60,
            refreshTokenExpiresIn: 24 * 60 * 60
        )
    }
    
    // MARK: - Refresh Token
    
    func refreshToken(refreshToken: String) async throws -> RefreshTokenResponse {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        if Int.random(in: 1...50) == 1 {
            throw AuthError.tokenRefreshFailed
        }
        
        return RefreshTokenResponse(
            accessToken: "new_access_token_\(UUID().uuidString.prefix(8))",
            expiresIn: 15 * 60
        )
    }
}
