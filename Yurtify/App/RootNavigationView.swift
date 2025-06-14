//
//  RootNavigationView.swift
//  Yurtify
//
//  Created by dark type on 14.06.2025.
//

import SwiftUI

struct RootNavigationView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var appRouter = AppRouter()

    var body: some View {
        Group {
            switch appRouter.currentRoute {
            case .welcome:
                WelcomeView()
            case .login:
                LoginView()
            case .register:
                RegistrationView()
            case .main:
                MainTabView()
            }
        }
        .environmentObject(appRouter)
        .environmentObject(authManager)
        .onReceive(authManager.$isAuthenticated) { _ in
            appRouter.handleAuthStateChange()
        }
        .onAppear {
            appRouter.setAuthManager(authManager)
        }
    }
}
