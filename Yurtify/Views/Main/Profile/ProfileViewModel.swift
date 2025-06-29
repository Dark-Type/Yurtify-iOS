//
//  ProfileViewModel.swift
//  Yurtify
//
//  Created by dark type on 15.06.2025.
//

import PhotosUI
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
    
    @Published var showingImagePicker = false
    @Published var showingCamera = false
    @Published var selectedPhotoItem: PhotosPickerItem?
    @Published var userProfileImage: UIImage?
    @Published var isProcessingImage = false
    
    @Published var showingEditProfile = false
    @Published var showingChangePassword = false
    
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
    
    // MARK: - Image Picker Methods
    
    func showPhotosPicker() {
        showingImagePicker = true
    }
    
    func showCamera() {
        showingCamera = true
    }
    
    func processSelectedPhoto() {
        guard let selectedPhotoItem = selectedPhotoItem else { return }
        
        isProcessingImage = true
        
        Task {
            do {
                if let data = try await selectedPhotoItem.loadTransferable(type: Data.self),
                   let image = UIImage(data: data)
                {
                    await MainActor.run {
                        self.userProfileImage = image
                        self.isProcessingImage = false
                        self.selectedPhotoItem = nil
                    }
                    
                    await uploadProfileImage(image)
                }
            } catch {
                await MainActor.run {
                    self.isProcessingImage = false
                    self.selectedPhotoItem = nil
                }
                print("Failed to process image: \(error)")
            }
        }
    }
    
    func addCameraImage(_ image: UIImage) {
        userProfileImage = image
        showingCamera = false
        
        Task {
            await uploadProfileImage(image)
        }
    }
    
    private func uploadProfileImage(_ image: UIImage) async {
        do {
            try await Task.sleep(for: .seconds(1))
            print("Profile image uploaded successfully")
        } catch {
            print("Failed to upload profile image: \(error)")
        }
    }
    
    // MARK: - Existing Actions
    
    func editProfile() {
        showingEditProfile = true
    }
    
    func changePassword() {
        showingChangePassword = true
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
