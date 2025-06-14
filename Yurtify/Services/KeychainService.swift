//
//  KeychainService.swift
//  Yurtify
//
//  Created by dark type on 14.06.2025.
//

import Foundation
import Security

final class KeychainService: Sendable {
    private let service = "com.yurtify.app"
    private let userDataKey = "userData"
    
    // MARK: - Store User Data

    func storeUser(_ user: User) throws {
        let userData = try JSONEncoder().encode(user)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: userDataKey,
            kSecValueData as String: userData
        ]
        
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw KeychainError.storeFailed(status)
        }
    }
    
    // MARK: - Retrieve User Data

    func getUserData() -> User? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: userDataKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data
        else {
            return nil
        }
        
        do {
            return try JSONDecoder().decode(User.self, from: data)
        } catch {
            print("Failed to decode user data: \(error)")
            return nil
        }
    }
    
    // MARK: - Update User Data (for token refresh)

    func updateUser(_ user: User) throws {
        try storeUser(user)
    }
    
    // MARK: - Clear User Data

    func clearUserData() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: userDataKey
        ]
        
        SecItemDelete(query as CFDictionary)
    }
    
    // MARK: - Check if User Data Exists

    func hasUserData() -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: userDataKey,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        return status == errSecSuccess
    }
}

// MARK: - Keychain Errors

enum KeychainError: Error, LocalizedError {
    case storeFailed(OSStatus)
    case retrieveFailed(OSStatus)
    case deleteFailed(OSStatus)
    
    var errorDescription: String? {
        switch self {
        case .storeFailed(let status):
            return "Failed to store data in keychain. Status: \(status)"
        case .retrieveFailed(let status):
            return "Failed to retrieve data from keychain. Status: \(status)"
        case .deleteFailed(let status):
            return "Failed to delete data from keychain. Status: \(status)"
        }
    }
}
