//
//  ProfileViewModel.swift
//  Yurtify
//
//  Created by dark type on 15.06.2025.
//

import PhotosUI
import SwiftUI

@MainActor
class ProfileViewModel: ObservableObject, Sendable {
    // MARK: - Published Properties
    
    @Published var isLoading = false
    @Published var showingLogoutConfirmation = false
    @Published var selectedSectionIndex = 0
    
    @Published var favoriteOffers: [UnifiedPropertyModel] = []
    @Published var ownedOffers: [UnifiedPropertyModel] = []
    @Published var bookingHistory: [UnifiedPropertyModel] = []
    
    @Published var showingImagePicker = false
    @Published var isUploadingImage = false
    @Published var uploadedImageId: String?
    @Published var uploadError: String?
    
    // MARK: - API Service

    nonisolated let apiService = APIService()
    
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
                    
                     uploadProfileImage(image)
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
        
        uploadProfileImage(image)
    }
    
    func uploadProfileImage(_ image: UIImage) {
        testHTTPConnection()
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            uploadError = "Failed to convert image to data"
            return
        }
        
        isUploadingImage = true
        uploadError = nil
        
        Task {
            do {
                let response = try await apiService.uploadImage(
                    imageData: imageData,
                    filename: "profile_image.jpg"
                )
                
                await MainActor.run {
                    self.uploadedImageId = response.imageId
                    self.isUploadingImage = false
                    print("Image uploaded successfully with ID: \(response.imageId ?? "dunno")")
                }
                
            } catch {
                await MainActor.run {
                    self.uploadError = error.localizedDescription
                    self.isUploadingImage = false
                    print("Upload failed: \(error.localizedDescription)")
                }
            }
        }
    }
    func testHTTPConnection() {
        Task {
            do {
                let url = URL(string: "http://77.110.105.134:8080/")!
                let (_, response) = try await URLSession.shared.data(from: url)
                
                if let httpResponse = response as? HTTPURLResponse {
                    await MainActor.run {
                        print("HTTP Test successful! Status: \(httpResponse.statusCode)")
                    }
                }
            } catch {
                await MainActor.run {
                    print("HTTP Test failed: \(error.localizedDescription)")
                }
            }
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
