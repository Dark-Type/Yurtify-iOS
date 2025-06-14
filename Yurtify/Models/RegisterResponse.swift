//
//  RegisterResponse.swift
//  Yurtify
//
//  Created by dark type on 15.06.2025.
//

struct RegisterResponse {
    let id: String
    let name: String
    let surname: String
    let patronymic: String?
    let phoneNumber: String
    let email: String?
    let accessToken: String
    let refreshToken: String
    let accessTokenExpiresIn: Int
    let refreshTokenExpiresIn: Int
}
