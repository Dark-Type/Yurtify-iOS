//
//  UserContacts.swift
//  Yurtify
//
//  Created by dark type on 25.06.2025.
//


import SwiftUI

struct UserContacts: Identifiable {
    let id = UUID()
    let image: Image
    let firstName: String
    let lastName: String
    let patronymic: String?
    let email: String
    let phoneNumber: String
    
    var fullName: String {
        if let patronymic = patronymic {
            return "\(firstName) \(patronymic) \(lastName)"
        } else {
            return "\(firstName) \(lastName)"
        }
    }
}
