//
//  RegistrationData.swift
//  Yurtify
//
//  Created by dark type on 14.06.2025.
//


struct RegistrationData : Sendable  {
    let surname: String
    let name: String
    let patronymic: String?
    let phoneNumber: String
    let email: String?
    let password: String
    
    var isValid: Bool {
        return !surname.isEmpty &&
               !name.isEmpty &&
               !phoneNumber.isEmpty &&
               !password.isEmpty &&
               password.count >= 6
    }
}
