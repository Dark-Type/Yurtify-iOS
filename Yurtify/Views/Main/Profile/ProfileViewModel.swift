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
    @Published var selectedSectionIndex = 0
    
    @Published var favoriteOffers: [Offer] = []
    @Published var ownedOffers: [Offer] = []
    @Published var bookingHistory: [Offer] = []
    
    init() {
        loadOffers()
    }
    
    private func loadOffers() {
        favoriteOffers = [
            Offer(
                title: "Cozy Studio Apartment",
                address: "123 Main St, Bishkek",
                price: 75000,
                startDate: Date(),
                endDate: Date().addingTimeInterval(86400 * 30),
                bedsCount: 1,
                area: 35.0,
                maxOccupancy: 2,
                isFavorited: true
            ),
            Offer(
                title: "Luxury Penthouse",
                address: "456 Park Ave, Bishkek",
                price: 150000,
                startDate: Date(),
                endDate: Date().addingTimeInterval(86400 * 30),
                bedsCount: 2,
                area: 85.0,
                maxOccupancy: 4,
                isFavorited: true
            )
        ]
        
        ownedOffers = [
            Offer(
                title: "My Mountain Cabin",
                address: "789 Pine St, Karakol",
                price: 95000,
                startDate: Date(),
                endDate: Date().addingTimeInterval(86400 * 30),
                bedsCount: 3,
                area: 110.0,
                maxOccupancy: 6,
                isOwner: true
            ),
            Offer(
                title: "City Center Apartment",
                address: "101 Oak Ave, Bishkek",
                price: 80000,
                startDate: Date(),
                endDate: Date().addingTimeInterval(86400 * 30),
                bedsCount: 2,
                area: 65.0,
                maxOccupancy: 3,
                isOwner: true
            )
        ]
        
        bookingHistory = [
            Offer(
                title: "Lake View Cottage",
                address: "222 Shore Rd, Issyk-Kul",
                price: 120000,
                startDate: Date().addingTimeInterval(-86400 * 60),
                endDate: Date().addingTimeInterval(-86400 * 30),
                bedsCount: 2,
                area: 70.0,
                maxOccupancy: 4,
                isOccupied: true
            ),
            Offer(
                title: "Downtown Loft",
                address: "333 Main St, Bishkek",
                price: 85000,
                startDate: Date().addingTimeInterval(-86400 * 120),
                endDate: Date().addingTimeInterval(-86400 * 90),
                bedsCount: 1,
                area: 50.0,
                maxOccupancy: 2,
                isOccupied: true
            )
        ]
    }
    
    // MARK: - Existing Actions
    
    func editProfile() {
        // TODO: Navigate to edit profile
        print("Navigate to edit profile")
    }
    
    func changePassword() {
        // TODO: Navigate to change password
        print("Navigate to change password")
    }
    
    func showFavorites() {
        selectedSectionIndex = 1
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
            try? await Task.sleep(nanoseconds: 300000000)
            
            await MainActor.run {
                authManager.logout()
                appRouter.navigateToWelcome()
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
