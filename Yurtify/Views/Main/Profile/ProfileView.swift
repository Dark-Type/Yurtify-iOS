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
    
    var body: some View {
        NavigationStack {
            Group {
                if authManager.isLoggedIn {
                    userProfileContent
                } else {
                    SuggestAccountView()
                }
            }
            .navigationTitle(L10n.TabBar.profile)
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
                        .fill(.textPrimary)
                        .frame(width: 100, height: 100)
                        .overlay(
                            Text("\(user.name.first?.uppercased() ?? "")\(user.surname.first?.uppercased() ?? "")")
                                .font(.body)
                                .foregroundColor(.textPrimary)
                        )
                    
                    VStack(spacing: 4) {
                        Text("\(user.name) \(user.surname)")
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
            profileActionRow(
                icon: "person.circle",
                title: "Edit Profile",
                action: {
                    // TODO: Navigate to edit profile
                }
            )
            
            Divider()
                .padding(.leading, 44)
            
            profileActionRow(
                icon: "key",
                title: "Change Password",
                action: {
                    // TODO: Navigate to change password
                }
            )
            
            Divider()
                .padding(.leading, 44)
            
            profileActionRow(
                icon: "heart",
                title: "My Favorites",
                action: {
                    // TODO: Navigate to favorites
                }
            )
        }
        .background(.base)
        .cornerRadius(12)
    }
    
    private var appSettingsSection: some View {
        VStack(spacing: 0) {
            profileActionRow(
                icon: "bell",
                title: "Notifications",
                action: {
                    // TODO: Navigate to notification settings
                }
            )
            
            Divider()
                .padding(.leading, 44)
            
            profileActionRow(
                icon: "questionmark.circle",
                title: "Help & Support",
                action: {
                    // TODO: Navigate to help
                }
            )
            
            Divider()
                .padding(.leading, 44)
            
            profileActionRow(
                icon: "info.circle",
                title: "About",
                action: {
                    // TODO: Navigate to about
                }
            )
            
            Divider()
                .padding(.leading, 44)
            
            profileActionRow(
                icon: "rectangle.portrait.and.arrow.right",
                title: "Sign Out",
                titleColor: .red,
                action: {
                    appRouter.handleLogout()
                }
            )
        }
        .background(.base)
        .cornerRadius(12)
    }
    
    private func profileActionRow(
        icon: String,
        title: String,
        titleColor: Color = .app.textPrimary,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(titleColor == .red ? .red : .primaryVariant)
                    .frame(width: 28)
                
                Text(title)
                    .font(.app.body(.medium))
                    .foregroundColor(titleColor)
                
                Spacer()
                
                if titleColor != .red {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.textPrimary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthManager())
        .environmentObject(AppRouter())
}
