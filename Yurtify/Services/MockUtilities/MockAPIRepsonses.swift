//
//  MockTokenRefreshResponse.swift
//  Yurtify
//
//  Created by dark type on 14.06.2025.
//

// MARK: - Mock API Responses

struct MockTokenRefreshResponse: Sendable {
    let token: String
    let expiresIn: Int
}

struct MockLoginResponse: Sendable {
    let user: MockUserData
    let token: String
    let refreshToken: String
    let accessTokenExpiresIn: Int
    let refreshTokenExpiresIn: Int
}

struct MockUserData: Sendable {
    let id: String
    let name: String
    let surname: String
    let patronymic: String?
    let phoneNumber: String
    let email: String?
}
