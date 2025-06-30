//
//  AuthError.swift
//  Yurtify
//
//  Created by dark type on 15.06.2025.
//

import Foundation

enum AuthError: Error, LocalizedError {
    case invalidCredentials
    case invalidData
    case loginFailed
    case registrationFailed
    case tokenRefreshFailed
    case refreshTokenExpired
    case networkError
    case storageError
    case userAlreadyExists
    case loginInProgress

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid phone number or password"
        case .invalidData:
            return "Please fill in all required fields"
        case .loginFailed:
            return "Login failed. Please try again"
        case .registrationFailed:
            return "Registration failed. Please try again"
        case .tokenRefreshFailed:
            return "Session expired. Please login again"
        case .refreshTokenExpired:
            return "Session expired. Please login again"
        case .networkError:
            return "Network error. Please check your connection"
        case .storageError:
            return "Failed to save user data. Please try again"
        case .loginInProgress:
            return "Login already in progress"
        case .userAlreadyExists:
            return "User with this phone number already exists"
        }
    }
}
