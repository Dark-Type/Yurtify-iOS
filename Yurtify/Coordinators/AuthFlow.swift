//
//  AuthFlow.swift
//  Yurtify
//
//  Created by dark type on 14.06.2025.
//

import SwiftUI

enum AuthFlow {
    case login
    case registration
}

@MainActor
class AuthPresentationManager: ObservableObject {
    @Published var isPresented = false
    @Published var currentFlow: AuthFlow = .login

    func showLogin() {
        currentFlow = .login
        isPresented = true
    }

    func showRegistration() {
        currentFlow = .registration
        isPresented = true
    }

    func dismiss() {
        isPresented = false
    }
}
