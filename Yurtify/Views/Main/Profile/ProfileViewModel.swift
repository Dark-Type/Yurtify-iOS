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
    
    @Published var favoriteOffers: [UnifiedPropertyModel] = []
    @Published var ownedOffers: [UnifiedPropertyModel] = []
    @Published var bookingHistory: [UnifiedPropertyModel] = []
    
    init() {
        loadOffers()
    }
    
    private func loadOffers() {
        favoriteOffers = [
            UnifiedPropertyModel(id: UUID().uuidString,
                                 title: "Квартира",
                                 addressName: "бишкек ",
                                 coordinates: Coordinates(),
                                 cost: 0,
                                 period: .perMonth,
                                 closedDates: [],
                                 firstFreeDate: Date(),
                                 firstClosedDate: nil),
            UnifiedPropertyModel(id: UUID().uuidString,
                                 title: "Квартира",
                                 addressName: "бишкек ",
                                 coordinates: Coordinates(latitude: 42.87462, longitude: 74.5698),
                                 cost: 0,
                                 period: .perMonth,
                                 closedDates: [],
                                 firstFreeDate: Date(),
                                 firstClosedDate: nil),
            UnifiedPropertyModel(id: UUID().uuidString,
                                 title: "Квартира",
                                 addressName: "бишкек ",
                                 coordinates: Coordinates(latitude: 42.87462, longitude: 74.5698),
                                 cost: 0,
                                 period: .perMonth,
                                 closedDates: [],
                                 firstFreeDate: Date(),
                                 firstClosedDate: nil)
        ]
        
        ownedOffers = [
            UnifiedPropertyModel(id: UUID().uuidString,
                                 title: "Квартира",
                                 addressName: "бишкек ",
                                 coordinates: Coordinates(),
                                 cost: 0,
                                 period: .perMonth,
                                 closedDates: [],
                                 firstFreeDate: Date(),
                                 firstClosedDate: nil),
            UnifiedPropertyModel(id: UUID().uuidString,
                                 title: "Квартира",
                                 addressName: "бишкек ",
                                 coordinates: Coordinates(latitude: 42.87462, longitude: 74.5698),
                                 cost: 0,
                                 period: .perMonth,
                                 closedDates: [],
                                 firstFreeDate: Date(),
                                 firstClosedDate: nil),
            UnifiedPropertyModel(id: UUID().uuidString,
                                 title: "Квартира",
                                 addressName: "бишкек ",
                                 coordinates: Coordinates(latitude: 42.87462, longitude: 74.5698),
                                 cost: 0,
                                 period: .perMonth,
                                 closedDates: [],
                                 firstFreeDate: Date(),
                                 firstClosedDate: nil)
        ]
        
        bookingHistory = [
            UnifiedPropertyModel(id: UUID().uuidString,
                                 title: "Квартира",
                                 addressName: "бишкек ",
                                 coordinates: Coordinates(),
                                 cost: 0,
                                 period: .perMonth,
                                 closedDates: [],
                                 firstFreeDate: Date(),
                                 firstClosedDate: nil),
            UnifiedPropertyModel(id: UUID().uuidString,
                                 title: "Квартира",
                                 addressName: "бишкек ",
                                 coordinates: Coordinates(latitude: 42.87462, longitude: 74.5698),
                                 cost: 0,
                                 period: .perMonth,
                                 closedDates: [],
                                 firstFreeDate: Date(),
                                 firstClosedDate: nil),
            UnifiedPropertyModel(id: UUID().uuidString,
                                 title: "Квартира",
                                 addressName: "бишкек ",
                                 coordinates: Coordinates(latitude: 42.87462, longitude: 74.5698),
                                 cost: 0,
                                 period: .perMonth,
                                 closedDates: [],
                                 firstFreeDate: Date(),
                                 firstClosedDate: nil)
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
