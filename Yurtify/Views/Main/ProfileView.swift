//
//  ProfileView.swift
//  Yurtify
//
//  Created by dark type on 14.06.2025.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var authCoordinator: AuthPresentationManager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if authManager.isGuest {
                        guestPrompt
                    } else if authManager.isLoggedIn {
                        userProfile
                    }
                }
                .padding()
            }
            .navigationTitle(L10n.TabBar.profile)
        }
    }
    
    private var guestPrompt: some View {
        VStack(spacing: 16) {
            Image("person.circle")
                .font(.headline)
                .foregroundColor(Color(.textPrimary))
            
            Text("Sign in to access all features")
                .font(.app.headline(.semiBold))
                .foregroundColor(.app.textPrimary)
            
            Text("Create an account or sign in to save favorites, make bookings, and more.")
                .font(.app.body(.regular))
                .foregroundColor(.app.textSecondary)
                .multilineTextAlignment(.center)
            
            Button("Sign In") {
                authCoordinator.showLogin()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(.base)
        .cornerRadius(12)
    }
    
    private var userProfile: some View {
        VStack(spacing: 16) {}
    }
}
