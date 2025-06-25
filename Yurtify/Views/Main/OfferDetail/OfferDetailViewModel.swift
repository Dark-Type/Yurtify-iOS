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
    @Published var property: Offer?
    @Published var isLoading = false
    @Published var error: Error?
    @Published var isFavorite = false
    @Published var similarOffers: [Offer] = []
    @Published var owner: UserContacts?
    @Published var selectedSectionIndex = 0
    @Published var isRentSuccessful = false
    @Published var galleryImages: [Image] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init(offer: Offer? = nil) {
        if let offer = offer {
            self.property = offer
            self.isFavorite = offer.isFavorited
            Task {
                await loadPropertyDetails()
            }
        }
    }
    
    func loadPropertyDetails() async {
        isLoading = true
        
        do {
            try await Task.sleep(for: .milliseconds(500))
            
            await loadMockData()
            isLoading = false
        } catch {
            self.error = error
            isLoading = false
        }
    }
    
    private func loadMockData() async {
        owner = UserContacts(
            image: Image(systemName: "person.circle.fill"),
            firstName: "John",
            lastName: "Doe",
            patronymic: "Smith",
            email: "john.doe@example.com",
            phoneNumber: "+996 555 123 456"
        )
        
        galleryImages = [
            Image(systemName: "photo.fill"),
            Image(systemName: "photo.fill"),
            Image(systemName: "photo.fill"),
            Image(systemName: "photo.fill"),
            Image(systemName: "photo.fill"),
            Image(systemName: "photo.fill"),
            Image(systemName: "photo.fill"),
            Image(systemName: "photo.fill"),
        ]
        
        similarOffers = [
            Offer(
                title: "Cozy Studio Apartment",
                address: "123 Main St, Bishkek",
                price: 75000,
                startDate: Date(),
                endDate: Date().addingTimeInterval(86400 * 30),
                bedsCount: 1,
                bathroomsCount: 1,
                area: 35.0,
                maxOccupancy: 2
            ),
            Offer(
                title: "Luxury Penthouse",
                address: "456 Park Ave, Bishkek",
                price: 150000,
                startDate: Date(),
                endDate: Date().addingTimeInterval(86400 * 30),
                bedsCount: 2,
                bathroomsCount: 2,
                area: 85.0,
                maxOccupancy: 4
            ),
            Offer(
                title: "Family Apartment",
                address: "789 Oak St, Bishkek",
                price: 120000,
                startDate: Date(),
                endDate: Date().addingTimeInterval(86400 * 30),
                bedsCount: 3,
                bathroomsCount: 2,
                area: 95.0,
                maxOccupancy: 6
            ),
        ]
    }
    
    func toggleFavorite() {
        isFavorite.toggle()
    }
    
    func rentProperty() {
        isRentSuccessful = true
        
        Task {
            try? await Task.sleep(for: .seconds(2))
            isRentSuccessful = false
        }
    }
    
    func shareProperty() {
        guard let property = property else { return }
        
        let shareText = "Check out this property: \(property.title) at \(property.address) for \(L10n.Measures.formatPrice(property.price, period: property.period))"
        
        print("Sharing: \(shareText)")
    }
}
