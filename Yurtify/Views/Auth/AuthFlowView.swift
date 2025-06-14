//
//  AuthFlowView.swift
//  Yurtify
//
//  Created by dark type on 14.06.2025.
//
import SwiftUI

struct AuthFlowView: View {
    @EnvironmentObject var authCoordinator: AuthPresentationManager
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        NavigationStack {
            Group {
                switch authCoordinator.currentFlow {
                case .login:
                    LoginView()
                case .registration:
                    RegistrationView()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        authCoordinator.dismiss()
                    }
                }
            }
        }
    }
}
