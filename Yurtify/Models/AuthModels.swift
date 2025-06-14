//
//  AuthError.swift
//  Yurtify
//
//  Created by dark type on 14.06.2025.
//
import Foundation

enum AuthError: Error, LocalizedError {
    case tokenRefreshFailed
    case reLoginFailed
    case invalidCredentials

    var errorDescription: String? {
        switch self {
        case .tokenRefreshFailed:
            return "Failed to refresh access token"
        case .reLoginFailed:
            return "Failed to re-authenticate user"
        case .invalidCredentials:
            return "Invalid credentials stored"
        }
    }
}
enum UserState {
    case firstLaunch
    case loggedIn
    case guest
    case loggedOut
}
