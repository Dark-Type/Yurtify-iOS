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
    @Published var reservedDates: [DateRange] = []
    
    @Published var showingBookingSheet = false
    @Published var selectedStartDate = Date()
    @Published var selectedEndDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    @Published var isBooking = false
    @Published var bookingError: String?
    @Published var showingAuthAlert = false
    
    private var apiService: APIService?
    private var authManager: AuthManager?
    private var cancellables = Set<AnyCancellable>()
    
    struct DateRange {
        let startDate: Date
        let endDate: Date
    }

    init(property: UnifiedPropertyModel? = nil) {
        if let property = property {
            self.property = property
            self.isFavorite = property.isFavorite
            self.owner = property.owner.fullName.isEmpty ? nil : property.owner
        }
    }
    
    func setDependencies(apiService: APIService, authManager: AuthManager) {
        self.apiService = apiService
        self.authManager = authManager
        
        Task {
            await loadPropertyDetails()
            await addVisitToProperty()
        }
    }

    func loadPropertyDetails() async {
        guard let property = property,
              let apiService = apiService else { return }
        
        isLoading = true
        
        do {
            async let ownerTask = loadOwnerDetails(ownerId: property.owner.id, apiService: apiService)
            async let galleryTask = loadGalleryImages(galleryIds: property.galleryUrls, apiService: apiService)
            async let similarTask = loadSimilarOffers(propertyType: property.propertyType, apiService: apiService)
            async let reservedDatesTask = loadReservedDates(housingId: property.id, apiService: apiService)
            async let favoritesTask = checkIfFavorite(housingId: property.id, apiService: apiService)
            
            
            let (ownerResult, galleryResult, similarResult, reservedResult, favoriteResult) = await (
                ownerTask, galleryTask, similarTask, reservedDatesTask, favoritesTask
            )
            
            
            if case .success(let ownerData) = ownerResult {
                owner = ownerData
            }
            
            if case .success(let images) = galleryResult {
                galleryImages = images
            }
            
            if case .success(let similar) = similarResult {
                similarOffers = similar
            }
            
            if case .success(let dates) = reservedResult {
                reservedDates = dates
            }
            
            if case .success(let isFav) = favoriteResult {
                isFavorite = isFav
            }
            
            isLoading = false
        }
    }
    
    // MARK: - API Calls
    
    private func addVisitToProperty() async {
        guard let property = property,
              let apiService = apiService,
              authManager?.isAuthenticated == true else { return }
        
        do {
            try await apiService.addVisit(housingId: property.id)
            print("✅ Visit recorded for property: \(property.id)")
        } catch {
            print("⚠️ Failed to record visit: \(error)")
           
        }
    }
    
    private func loadOwnerDetails(ownerId: String, apiService: APIService) async -> Result<OwnerDto, Error> {
        do {
            let userDTO = try await apiService.getUserPublicInfo(userId: ownerId)
            
            let owner = OwnerDto(
                fullName: "\(userDTO.fullName?.name ?? "") \(userDTO.fullName?.surname ?? "")\n\(userDTO.fullName?.patronymic ?? "")".trimmingCharacters(in: .whitespacesAndNewlines),
                email: userDTO.email ?? "",
                phone: userDTO.phone ?? "",
                imageUrl: userDTO.imageId ?? ""
            )
            
            print("✅ Owner loaded: \(owner.fullName)")
            return .success(owner)
            
        } catch {
            print("❌ Failed to load owner: \(error)")
            return .failure(error)
        }
    }
    
    private func loadGalleryImages(galleryIds: [String], apiService: APIService) async -> Result<[UIImage], Error> {
        guard !galleryIds.isEmpty else {
            return .success([])
        }
        
        await MainActor.run {
            self.isLoadingImages = true
        }
        
        var loadedImages: [UIImage] = []
        
        for imageId in galleryIds {
            do {
                let imageData = try await apiService.getImage(imageId: imageId)
                if let image = UIImage(data: imageData) {
                    loadedImages.append(image)
                    print("✅ Loaded gallery image: \(imageId)")
                } else {
                    print("⚠️ Failed to create UIImage from data for: \(imageId)")
                }
            } catch {
                print("❌ Failed to load gallery image \(imageId): \(error)")
                
            }
        }
        
        await MainActor.run {
            self.isLoadingImages = false
        }
        
        return .success(loadedImages)
    }
    
    private func loadSimilarOffers(propertyType: String, apiService: APIService) async -> Result<[UnifiedPropertyModel], Error> {
        do {
            let typeFilter: Operations.getAllHousings.Input.Query._typePayload? = {
                switch propertyType.uppercased() {
                case "COTTAGE": return .COTTAGE
                case "ROOM": return .ROOM
                case "HOTEL": return .HOTEL
                default: return nil
                }
            }()
            
            let response = try await apiService.getAllHousings(
                page: 0,
                size: 5, 
                title: nil,
                address: nil,
                type: typeFilter
            )
            
            let content = response.content ?? []
            let similarOffers = content.compactMap { UnifiedPropertyModel.from(housingDTO: $0) }
                .filter { $0.id != property?.id }
            
            print("✅ Loaded \(similarOffers.count) similar offers")
            return .success(Array(similarOffers.prefix(4)))
            
        } catch {
            print("❌ Failed to load similar offers: \(error)")
            return .failure(error)
        }
    }
    
    private func loadReservedDates(housingId: String, apiService: APIService) async -> Result<[DateRange], Error> {
        do {
            let dateRangeDTOs = try await apiService.getReservedDates(housingId: housingId)
            
            let dateFormatter = ISO8601DateFormatter()
            let reservedRanges = dateRangeDTOs.compactMap { dto -> DateRange? in
                guard let startDateString = dto.startDate,
                      let endDateString = dto.endDate,
                      let startDate = dateFormatter.date(from: startDateString),
                      let endDate = dateFormatter.date(from: endDateString)
                else {
                    return nil
                }
                
                return DateRange(startDate: startDate, endDate: endDate)
            }
            
            print("✅ Loaded \(reservedRanges.count) reserved date ranges")
            return .success(reservedRanges)
            
        } catch {
            print("❌ Failed to load reserved dates: \(error)")
            return .failure(error)
        }
    }
    
    private func checkIfFavorite(housingId: String, apiService: APIService) async -> Result<Bool, Error> {
        guard authManager?.isAuthenticated == true else {
            return .success(false)
        }
        
        do {
            let favoritesResponse = try await apiService.getUserFavorites(page: 0, size: 100)
            let favorites = favoritesResponse.content ?? []
            
            let isFavorite = favorites.contains { housingDTO in
                housingDTO.id == housingId
            }
            
            print("✅ Favorite status checked for \(housingId): \(isFavorite)")
            return .success(isFavorite)
            
        } catch {
            print("❌ Failed to check favorite status: \(error)")
            return .failure(error)
        }
    }
    
    // MARK: - User Actions
    
    func toggleFavorite() {
        guard let property = property,
              let apiService = apiService else { return }
        
        guard authManager?.isAuthenticated == true else {
            showingAuthAlert = true
            return
        }
        
        Task {
            do {
                if isFavorite {
                    try await apiService.removeFavorite(housingId: property.id)
                    print("✅ Removed from favorites: \(property.id)")
                } else {
                    try await apiService.addFavorite(housingId: property.id)
                    print("✅ Added to favorites: \(property.id)")
                }
                
                await MainActor.run {
                    self.isFavorite.toggle()
                    self.property?.isFavorite = self.isFavorite
                }
                
            } catch {
                print("❌ Failed to toggle favorite: \(error)")
                await MainActor.run {
                    self.error = error
                }
            }
        }
    }
    
    func showBookingSheet() {
        guard authManager?.isAuthenticated == true else {
            showingAuthAlert = true
            return
        }
        
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
        
        for reservedRange in reservedDates {
            let selectedRange = selectedStartDate...selectedEndDate
            let reservedDateRange = reservedRange.startDate...reservedRange.endDate
            
            if selectedRange.overlaps(reservedDateRange) {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                return "Selected dates conflict with reserved period: \(formatter.string(from: reservedRange.startDate)) - \(formatter.string(from: reservedRange.endDate))"
            }
        }
        
        return nil
    }
    
    func bookProperty() async -> Bool {
        guard authManager?.isAuthenticated == true else {
            await MainActor.run {
                self.showingAuthAlert = true
            }
            return false
        }
        
        isBooking = true
        bookingError = nil
        
        if let validationError = validateBookingDates() {
            await MainActor.run {
                self.bookingError = validationError
                self.isBooking = false
            }
            return false
        }
        
        guard let property = property, let apiService = apiService else {
            await MainActor.run {
                self.bookingError = "Property or API Service not available."
                self.isBooking = false
            }
            return false
        }
        
        let isoFormatter = ISO8601DateFormatter()
        let reservationRequest = Components.Schemas.ReservationCreateDTO(
            housingId: property.id,
            startDate: isoFormatter.string(from: selectedStartDate),
            endDate: isoFormatter.string(from: selectedEndDate)
        )
        
        do {
            let reservationResponse = try await apiService.createReservation(request: reservationRequest)
            print("✅ Reservation successful: \(reservationResponse)")
            await MainActor.run {
                self.isBooking = false
                self.showingBookingSheet = false
                self.isRentSuccessful = true
               
                Task {
                    try? await Task.sleep(for: .seconds(3))
                    await MainActor.run {
                        self.isRentSuccessful = false
                    }
                }
            }
            return true
        } catch {
            await MainActor.run {
                self.bookingError = "Booking failed: \(error.localizedDescription)"
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
