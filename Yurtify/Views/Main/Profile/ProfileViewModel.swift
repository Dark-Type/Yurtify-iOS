//
//  ProfileViewModel.swift
//  Yurtify
//
//  Created by dark type on 15.06.2025.
//

import SwiftUI

@MainActor
class ProfileViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var isLoading = false
    @Published var showingLogoutConfirmation = false
    
    // MARK: - Actions
    
    func editProfile() {
        // TODO: Navigate to edit profile
        print("Navigate to edit profile")
    }
    
    func changePassword() {
        // TODO: Navigate to change password
        print("Navigate to change password")
    }
    
    func showFavorites() {
        // TODO: Navigate to favorites
        print("Navigate to favorites")
    }
    
    func showNotificationSettings() {
        // TODO: Navigate to notification settings
        print("Navigate to notification settings")
    }
    
    func showHelp() {
        // TODO: Navigate to help
        print("Navigate to help")
    }
    
    func showAbout() {
        // TODO: Navigate to about
        print("Navigate to about")
    }
    
    func confirmLogout() {
        showingLogoutConfirmation = true
    }
    
    func logout(authManager: AuthManager, appRouter: AppRouter) {
        isLoading = true
        
        Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            
            await MainActor.run {
                authManager.logout()
                appRouter.handleLogout()
                isLoading = false
                showingLogoutConfirmation = false
            }
        }
    }
    
    func cancelLogout() {
        showingLogoutConfirmation = false
    }
    
    // MARK: - Helper Methods
    
    func getUserInitials(user: User) -> String {
        let firstInitial = user.name.first?.uppercased() ?? ""
        let lastInitial = user.surname.first?.uppercased() ?? ""
        return "\(firstInitial)\(lastInitial)"
    }
    
    func getFullName(user: User) -> String {
        return "\(user.name) \(user.surname)"
    }
}
