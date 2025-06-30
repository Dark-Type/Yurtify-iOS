//
//  RefreshTokenResponse.swift
//  Yurtify
//
//  Created by dark type on 15.06.2025.
//

struct RefreshTokenResponse: Codable {
    let accessToken: String
    let expiresIn: Int
}
