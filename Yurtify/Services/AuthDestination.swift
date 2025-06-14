//
//  AuthDestination.swift
//  Yurtify
//
//  Created by dark type on 14.06.2025.
//

import SwiftUI

enum AuthDestination: Hashable {
    case registration
}

@MainActor
class AppState: ObservableObject {
    @Published var shouldShowAuth = false
    @Published var authNavigationPath = NavigationPath()

    func showAuth() {
        shouldShowAuth = true
    }

    func dismissAuth() {
        shouldShowAuth = false
        authNavigationPath = NavigationPath()
    }

    func navigateToRegistration() {
        authNavigationPath.append(AuthDestination.registration)
    }
}
