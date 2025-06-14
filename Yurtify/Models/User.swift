//
//  User.swift
//  Yurtify
//
//  Created by dark type on 14.06.2025.
//

import Foundation

struct User: Codable, Sendable {
    let id: String
    let name: String
    let surname: String
    let patronymic: String?
    let phoneNumber: String
    let email: String?
    let token: String
    let refreshToken: String
    let tokenExpiresAt: Date
    let refreshTokenExpiresAt: Date
    
    let password: String
    
    var isTokenExpired: Bool {
        Date() >= tokenExpiresAt
    }
    
    var isTokenExpiringSoon: Bool {
        Date().addingTimeInterval(120) >= tokenExpiresAt
    }
    
    var isRefreshTokenExpired: Bool {
        Date() >= refreshTokenExpiresAt
    }
    
    var isRefreshTokenExpiringSoon: Bool {
        Date().addingTimeInterval(3600) >= refreshTokenExpiresAt
    }
}
