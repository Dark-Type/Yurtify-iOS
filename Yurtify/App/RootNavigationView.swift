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
            if authManager.isInitializing {
                VStack {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Loading...")
                        .font(.app.body(.medium))
                        .foregroundColor(.textPrimary)
                        .padding(.top)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.base)
            } else {
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
        }
        .environmentObject(appRouter)
        .environmentObject(authManager)
        .onChange(of: authManager.isInitializing) { isInitializing in
            if !isInitializing {
                appRouter.setAuthManager(authManager)
            }
        }
        .onAppear {
            if !authManager.isInitializing {
                appRouter.setAuthManager(authManager)
            }
        }
    }
}
