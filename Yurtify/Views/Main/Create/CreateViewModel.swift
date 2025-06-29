//
//  CreatePropertyViewModel.swift
//  Yurtify
//
//  Created by dark type on 23.06.2025.
//

import AVFoundation
import PhotosUI
import SwiftUI

@MainActor
final class CreateViewModel: ObservableObject {
    @Published var property = UnifiedPropertyModel()
    @Published var selectedPropertyType: PropertyType?
    @Published var selectedConveniences = Set<Convenience>()
    @Published var priceText = ""
    @Published var areaText = ""
    
    @Published var startDate = Date()
    @Published var endDate = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    @Published var unavailableDates = Set<Date>()
    @Published var selectedUnavailableDate: Date?
    @Published var isSelectingUnavailableDates = false
    
    @Published var selectedImages: [PropertyImage] = []
    @Published var selectedPhotoItems: [PhotosPickerItem] = []
    @Published var showingImagePicker = false
    @Published var showingCamera = false
    @Published var isProcessingImages = false
    
    @Published var posterImage: PropertyImage?
    @Published var posterPhotoItems: [PhotosPickerItem] = []
    @Published var showingPosterPicker = false
    @Published var isProcessingPosterImage = false
    @Published var showingPosterSelectionSheet = false
    
    @Published var invalidFields = Set<ValidationField>()
    
    @Published var propertyAddress = Address()
    
    var area: Double {
        get { Double(property.placeAmount) }
        set {
            property.placeAmount = Int(newValue)
            areaText = String(Int(newValue))
        }
    }
    
    var beds: Double {
        get { Double(property.bedsCount) }
        set { property.bedsCount = Int(newValue) }
    }
    
   
    
    var capacity: Double {
        get { Double(property.maxPeople) }
        set { property.maxPeople = Int(newValue) }
    }
    
    var rooms: Double {
        get { Double(property.roomsCount) }
        set { property.roomsCount = Int(newValue) }
    }
    
    enum ValidationField: Hashable {
        case name
        case description
        case propertyType
        case measurements
        case price
        case location
        case dates
        case images
        case poster
    }
    
    init() {
        property.firstFreeDate = startDate
        property.firstClosedDate = endDate
        areaText = "0"
    }
    
    // MARK: - Form Validation

    func validateForm() -> Bool {
        invalidFields.removeAll()
        
        if property.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            invalidFields.insert(.name)
        }
        
        if property.addressName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            invalidFields.insert(.description)
        }
        
        if selectedPropertyType == nil {
            invalidFields.insert(.propertyType)
        }
        
        if let areaValue = Int(areaText), areaValue > 0 {
            property.placeAmount = areaValue
        } else {
            invalidFields.insert(.measurements)
        }
        
        if property.placeAmount <= 0 || property.bedsCount <= 0 ||  property.maxPeople <= 0 {
            invalidFields.insert(.measurements)
        }
        
        let cleanedPrice = priceText.replacingOccurrences(of: ",", with: ".")
        if let price = Double(cleanedPrice), price > 0 {
            property.cost = price
        } else {
            invalidFields.insert(.price)
        }
        
        property.coordinates = propertyAddress.coordinates
        property.addressName = propertyAddress.formattedAddress
        
        if propertyAddress.coordinates.latitude == 0 {
            invalidFields.insert(.location)
        }
        
        if startDate >= endDate {
            invalidFields.insert(.dates)
        }
        
        if selectedImages.isEmpty {
            invalidFields.insert(.images)
        }
        
        if posterImage == nil {
            invalidFields.insert(.poster)
        }
        
        if let type = selectedPropertyType {
            property.propertyType = type.rawValue
        }
        
        property.properties = selectedConveniences.map { $0.rawValue }
        property.firstFreeDate = startDate
        property.firstClosedDate = endDate
        property.closedDates = Array(unavailableDates)
        
        return invalidFields.isEmpty
    }
    
    // MARK: - Date Management
    
    func addUnavailableDate(_ date: Date) {
        unavailableDates.insert(date)
    }
    
    func removeUnavailableDate(_ date: Date) {
        unavailableDates.remove(date)
    }
    
    func isDateUnavailable(_ date: Date) -> Bool {
        unavailableDates.contains(date)
    }
    
    func toggleUnavailableDate(_ date: Date) {
        if unavailableDates.contains(date) {
            unavailableDates.remove(date)
        } else {
            unavailableDates.insert(date)
        }
    }
    
    // MARK: - Apple's Recommended Permission Handling
    
    func showPhotosPicker() {
        selectedPhotoItems.removeAll()
        showingImagePicker = true
    }
    
    func showCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            return
        }
        
        showingCamera = true
    }
    
    // MARK: - Poster Image Management
    
    func showPosterSelection() {
        showingPosterSelectionSheet = true
    }
    
    func showPosterPicker() {
        showingPosterPicker = true
    }
    
    func selectPosterFromGallery(_ image: PropertyImage) {
        posterImage = image
    }
    
    func processPosterPhoto() {
        guard !posterPhotoItems.isEmpty && !isProcessingPosterImage else {
            return
        }
        
        isProcessingPosterImage = true
        
        Task {
            if let posterPhotoItem = posterPhotoItems.first {
                do {
                    if let data = try await posterPhotoItem.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data)
                    {
                        let propertyImage = PropertyImage(image: uiImage)
                        
                        await MainActor.run {
                            self.posterImage = propertyImage
                            self.posterPhotoItems.removeAll()
                            self.isProcessingPosterImage = false
                        }
                    } else {
                        await MainActor.run {
                            self.posterPhotoItems.removeAll()
                            self.isProcessingPosterImage = false
                        }
                    }
                } catch {
                    await MainActor.run {
                        self.posterPhotoItems.removeAll()
                        self.isProcessingPosterImage = false
                    }
                }
            }
        }
    }
    
    func removePosterImage() {
        posterImage = nil
    }
    
    // MARK: - Image Management with PhotosUI
    
    func processSelectedPhotos() {
        guard !selectedPhotoItems.isEmpty && !isProcessingImages else {
            return
        }
        
        isProcessingImages = true
        
        Task {
            var loadedImages: [PropertyImage] = []
            
            for (index, item) in selectedPhotoItems.enumerated() {
                do {
                    
                    if let data = try await item.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        let propertyImage = PropertyImage(image: uiImage)
                        loadedImages.append(propertyImage)
                    } else {
                    }
                } catch {
                }
            }
            
            await MainActor.run {
                self.selectedImages.append(contentsOf: loadedImages)
                self.selectedPhotoItems.removeAll()
                self.isProcessingImages = false
                
                if self.posterImage == nil && !loadedImages.isEmpty {
                    self.posterImage = loadedImages.first
                }
            }
        }
    }
    
    func addCameraImage(_ image: UIImage) {
        print("📷 Adding camera image")
        let propertyImage = PropertyImage(image: image)
        selectedImages.append(propertyImage)
        
        if posterImage == nil {
            posterImage = propertyImage
        }
        
    }
    
    func removeImage(at index: Int) {
        guard index < selectedImages.count else {
            return
        }
        
        let imageToRemove = selectedImages[index]
        selectedImages.remove(at: index)
        
        if posterImage?.id == imageToRemove.id {
            posterImage = nil
        }
        
    }
    
    // MARK: - Mock Image Upload
    
    private func uploadImages() async -> [String] {
        var uploadedUrls: [String] = []
        
        for (index, propertyImage) in selectedImages.enumerated() {
            try? await Task.sleep(for: .milliseconds(500))
            
            let mockUrl = "https://mock-storage.com/properties/\(property.id)/image_\(index).jpg"
            uploadedUrls.append(mockUrl)
        }
        
        return uploadedUrls
    }
    
    private func uploadPosterImage() async -> String? {
        guard let posterImage = posterImage else {
            return nil
        }
        
        try? await Task.sleep(for: .milliseconds(300))
        
        let mockUrl = "https://mock-storage.com/properties/\(property.id)/poster.jpg"
        return mockUrl
    }
    
    // MARK: - Property Creation
    
    func createPropertyAsync() async -> (success: Bool, message: String) {
        property.createdAt = Date()
        property.updatedAt = Date()
        property.isOwn = true
        
        if let posterUrl = await uploadPosterImage() {
            property.posterUrl = posterUrl
        }
        
        let uploadedUrls = await uploadImages()
        property.galleryUrls = uploadedUrls
        
        property.owner = OwnerDto(
            fullName: "Current User",
            email: "user@example.com",
            phone: "+996 XXX XXX XXX",
            imageUrl: "https://mock-storage.com/users/current/avatar.jpg"
        )
        
        logPropertyData()
        
        try? await Task.sleep(for: .seconds(1.5))
        
        return (true, "Property created successfully!")
    }
    
    func createProperty(completion: @escaping (Bool, String) -> Void) {
        Task {
            let result = await createPropertyAsync()
            completion(result.success, result.message)
        }
    }
    
    // MARK: - Helper Methods
    
    private func logPropertyData() {
        print("🏠 Creating property: \(property.title)")
        print("🏠 Type: \(property.propertyType)")
        print("🏠 Price: \(property.cost) \(property.period.rawValue)")
        print("🏠 Address: \(property.addressName)")
        print("🏠 Coordinates: \(property.coordinates.latitude), \(property.coordinates.longitude)")
        print("🏠 Available from: \(property.firstFreeDate)")
        print("🏠 Available until: \(property.firstClosedDate?.description ?? "No end date")")
        print("🏠 Unavailable dates: \(property.closedDates)")
        print("🏠 Conveniences: \(property.properties)")
        print("🏠 Poster URL: \(property.posterUrl)")
        print("🏠 Gallery Images: \(property.galleryUrls.count) uploaded")
    }
}
