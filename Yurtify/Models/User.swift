//
//  User.swift
//  Yurtify
//
//  Created by dark type on 14.06.2025.
//

import Foundation

struct User: Codable, Sendable, Equatable {
    let id: String
    let name: String
    let surname: String
    let patronymic: String?
    let phoneNumber: String
    let email: String?
    let accessToken: String
    let refreshToken: String
    let accessTokenExpiresAt: Date
    let refreshTokenExpiresAt: Date
    let password: String
    
    // MARK: - Convenience Initializers
    
    init(from loginResponse: LoginResponse, password: String) {
        self.id = loginResponse.id
        self.name = loginResponse.name
        self.surname = loginResponse.surname
        self.patronymic = loginResponse.patronymic
        self.phoneNumber = loginResponse.phoneNumber
        self.email = loginResponse.email
        self.accessToken = loginResponse.accessToken
        self.refreshToken = loginResponse.refreshToken
        self.accessTokenExpiresAt = Date().addingTimeInterval(TimeInterval(loginResponse.accessTokenExpiresIn))
        self.refreshTokenExpiresAt = Date().addingTimeInterval(TimeInterval(loginResponse.refreshTokenExpiresIn))
        self.password = password
    }
    
    init(from registerResponse: RegisterResponse, password: String) {
        self.id = registerResponse.id
        self.name = registerResponse.name
        self.surname = registerResponse.surname
        self.patronymic = registerResponse.patronymic
        self.phoneNumber = registerResponse.phoneNumber
        self.email = registerResponse.email
        self.accessToken = registerResponse.accessToken
        self.refreshToken = registerResponse.refreshToken
        self.accessTokenExpiresAt = Date().addingTimeInterval(TimeInterval(registerResponse.accessTokenExpiresIn))
        self.refreshTokenExpiresAt = Date().addingTimeInterval(TimeInterval(registerResponse.refreshTokenExpiresIn))
        self.password = password
    }
    
    // MARK: - Direct Initializer
    
    init(
        id: String,
        name: String,
        surname: String,
        patronymic: String?,
        phoneNumber: String,
        email: String?,
        accessToken: String,
        refreshToken: String,
        accessTokenExpiresAt: Date,
        refreshTokenExpiresAt: Date,
        password: String
    ) {
        self.id = id
        self.name = name
        self.surname = surname
        self.patronymic = patronymic
        self.phoneNumber = phoneNumber
        self.email = email
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.accessTokenExpiresAt = accessTokenExpiresAt
        self.refreshTokenExpiresAt = refreshTokenExpiresAt
        self.password = password
    }
}
