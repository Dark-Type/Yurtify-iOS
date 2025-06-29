//
//  PropertyDetailViewModel.swift
//  Yurtify
//
//  Created by dark type on 26.06.2025.
//

import Combine
import CoreLocation
import SwiftUI

@MainActor
final class OfferDetailViewModel: ObservableObject {
    @Published var property: UnifiedPropertyModel?
    @Published var isLoading = false
    @Published var error: Error?
    @Published var isFavorite = false
    @Published var similarOffers: [UnifiedPropertyModel] = []
    @Published var owner: OwnerDto?
    @Published var selectedSectionIndex = 0
    @Published var isRentSuccessful = false
    @Published var galleryImages: [UIImage] = []
    @Published var isLoadingImages = false
    
    @Published var showingBookingSheet = false
    @Published var selectedStartDate = Date()
    @Published var selectedEndDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    @Published var isBooking = false
    @Published var bookingError: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    private func loadMockData() async {
        if owner == nil || owner?.fullName.isEmpty == true {
            owner = OwnerDto(
                fullName: "John Doe\nSmith",
                email: "john.doe@example.com",
                phone: "+996 555 123 456",
                imageUrl: "https://example.com/avatar.jpg"
            )
        }
        
        if var currentProperty = property, currentProperty.properties.isEmpty {
            currentProperty.properties = [
                Convenience.wifi.rawValue,
                Convenience.parking.rawValue,
                Convenience.airConditioning.rawValue,
                Convenience.kitchen.rawValue,
                Convenience.washingMachine.rawValue,
                Convenience.restaurants.rawValue
            ]
            property = currentProperty
        }
    }

    init(property: UnifiedPropertyModel? = nil) {
        if let property = property {
            self.property = property
            self.isFavorite = property.isFavorite
            self.owner = property.owner.fullName.isEmpty ? nil : property.owner
            Task {
                await loadPropertyDetails()
            }
        }
    }

    func loadPropertyDetails() async {
        isLoading = true
        
        do {
            try await Task.sleep(for: .milliseconds(500))
            
            await loadGalleryImages()
            await loadSimilarOffers()
            
            isLoading = false
        } catch {
            self.error = error
            isLoading = false
        }
    }
    
    private func loadGalleryImages() async {
        guard let property = property else { return }
        
        isLoadingImages = true
        
        let mockUrls = property.galleryUrls.isEmpty ? [
            "https://picsum.photos/400/300?random=1",
            "https://picsum.photos/400/300?random=2",
            "https://picsum.photos/400/300?random=3",
            "https://picsum.photos/400/300?random=4",
            "https://picsum.photos/400/300?random=5",
            "https://picsum.photos/400/300?random=6"
        ] : property.galleryUrls
        
        var loadedImages: [UIImage] = []
        
        for urlString in mockUrls {
            do {
                if let placeholderImage = createPlaceholderImage() {
                    loadedImages.append(placeholderImage)
                }
                
                try await Task.sleep(for: .milliseconds(200))
            } catch {
                print("Failed to load image: \(error)")
            }
        }
        
        await MainActor.run {
            self.galleryImages = loadedImages
            self.isLoadingImages = false
        }
    }
    
    private func createPlaceholderImage() -> UIImage? {
        let size = CGSize(width: 400, height: 300)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.systemGray5.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    private func loadSimilarOffers() async {
        similarOffers = [
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
    
    func toggleFavorite() {
        isFavorite.toggle()
        property?.isFavorite = isFavorite
    }
    
    func showBookingSheet() {
        bookingError = nil
        selectedStartDate = Date()
        selectedEndDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        showingBookingSheet = true
    }
    
    func validateBookingDates() -> String? {
        guard let property = property else { return "Property not available" }
        
        let calendar = Calendar.current
        if calendar.compare(selectedStartDate, to: Date(), toGranularity: .day) == .orderedAscending {
            return "Start date cannot be in the past"
        }
        
        if selectedEndDate <= selectedStartDate {
            return "End date must be after start date"
        }
        
        if let firstClosedDate = property.firstClosedDate,
           selectedEndDate > firstClosedDate
        {
            return "Selected dates are outside available range"
        }
        
        if selectedStartDate < property.firstFreeDate {
            return "Property is not available from selected start date"
        }
        
        let unavailableDates = Set(property.closedDates)
        let dateRange = generateDateRange(from: selectedStartDate, to: selectedEndDate)
        
        for date in dateRange {
            if unavailableDates.contains(date) {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                return "Selected range contains unavailable date: \(formatter.string(from: date))"
            }
        }
        
        return nil
    }
    
    private func generateDateRange(from startDate: Date, to endDate: Date) -> [Date] {
        var dates: [Date] = []
        var currentDate = startDate
        let calendar = Calendar.current
        
        while currentDate <= endDate {
            dates.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return dates
    }
    
    func bookProperty() async -> Bool {
        isBooking = true
        bookingError = nil
        
        if let validationError = validateBookingDates() {
            await MainActor.run {
                self.bookingError = validationError
                self.isBooking = false
            }
            return false
        }
        
        do {
            try await Task.sleep(for: .seconds(2))
            
            let success = true
            
            await MainActor.run {
                self.isBooking = false
                if success {
                    self.showingBookingSheet = false
                    self.isRentSuccessful = true
                    
                    Task {
                        try? await Task.sleep(for: .seconds(3))
                        await MainActor.run {
                            self.isRentSuccessful = false
                        }
                    }
                } else {
                    self.bookingError = "Booking failed. Please try again."
                }
            }
            
            return success
        } catch {
            await MainActor.run {
                self.bookingError = "Network error. Please try again."
                self.isBooking = false
            }
            return false
        }
    }
    
    func shareProperty() {
        guard let property = property else { return }
        
        let shareText = "Check out this property: \(property.title) at \(property.addressName) for \(L10n.Measures.formatPrice(property.cost, period: property.period))"
        
        print("Sharing: \(shareText)")
    }
}
