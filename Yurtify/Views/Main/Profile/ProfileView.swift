//
//  ProfileView.swift
//  Yurtify
//
//  Created by dark type on 14.06.2025.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var appRouter: AppRouter
    @StateObject private var viewModel = ProfileViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if authManager.isAuthenticated {
                    userProfileContent
                } else {
                    SuggestAccountView(
                    )
                }
            }
            .navigationTitle(L10n.TabBar.profile)
        }
        .confirmationDialog(
            "L10n.Profile.logoutConfirmationTitle",
            isPresented: $viewModel.showingLogoutConfirmation,
            titleVisibility: .visible
        ) {
            Button("L10n.Profile.logoutConfirm", role: .destructive) {
                viewModel.logout(authManager: authManager, appRouter: appRouter)
            }
            Button("L10n.Profile.cancel", role: .cancel) {
                viewModel.cancelLogout()
            }
        } message: {
            Text("L10n.Profile.logoutConfirmationMessage")
        }
    }
    
    private var userProfileContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                userInfoSection
                accountActionsSection
                appSettingsSection
            }
            .padding()
        }
    }
    
    private var userInfoSection: some View {
        VStack(spacing: 16) {
            if let user = authManager.currentUser {
                VStack(spacing: 12) {
                    Circle()
                        .fill(.primaryVariant)
                        .frame(width: 100, height: 100)
                        .overlay(
                            Text(viewModel.getUserInitials(user: user))
                                .font(.app.title2(.bold))
                                .foregroundColor(.white)
                        )
                    
                    VStack(spacing: 4) {
                        Text(viewModel.getFullName(user: user))
                            .font(.app.title2(.semiBold))
                            .foregroundColor(.app.textPrimary)
                        
                        if let patronymic = user.patronymic, !patronymic.isEmpty {
                            Text(patronymic)
                                .font(.app.body(.regular))
                                .foregroundColor(.app.textSecondary)
                        }
                        
                        Text(user.phoneNumber)
                            .font(.app.callout(.medium))
                            .foregroundColor(.app.textSecondary)
                        
                        if let email = user.email, !email.isEmpty {
                            Text(email)
                                .font(.app.callout(.medium))
                                .foregroundColor(.app.textSecondary)
                        }
                    }
                }
            }
        }
        .padding()
        .background(.base)
        .cornerRadius(12)
    }
    
    private var accountActionsSection: some View {
        VStack(spacing: 0) {
            ProfileActionRow(
                icon: "person.circle",
                title: "L10n.Profile.editProfile",
                action: viewModel.editProfile
            )
            
            ProfileDivider()
            
            ProfileActionRow(
                icon: "key",
                title: "L10n.Profile.changePassword",
                action: viewModel.changePassword
            )
            
            ProfileDivider()
            
            ProfileActionRow(
                icon: "heart",
                title: L10n.Profile.favorite,
                action: viewModel.showFavorites
            )
        }
        .background(.base)
        .cornerRadius(12)
    }
    
    private var appSettingsSection: some View {
        VStack(spacing: 0) {
            ProfileActionRow(
                icon: "bell",
                title: "L10n.Profile.notifications",
                action: viewModel.showNotificationSettings
            )
            
            ProfileDivider()
            
            ProfileActionRow(
                icon: "questionmark.circle",
                title: "L10n.Profile.help",
                action: viewModel.showHelp
            )
            
            ProfileDivider()
            
            ProfileActionRow(
                icon: "info.circle",
                title: "L10n.Profile.about",
                action: viewModel.showAbout
            )
            
            ProfileDivider()
            
            ProfileActionRow(
                icon: "rectangle.portrait.and.arrow.right",
                title: "L10n.Profile.signOut",
                titleColor: .red,
                isLoading: viewModel.isLoading,
                action: viewModel.confirmLogout
            )
        }
        .background(.base)
        .cornerRadius(12)
    }
}
