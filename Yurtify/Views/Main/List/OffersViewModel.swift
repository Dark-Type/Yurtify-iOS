//
//  OffersViewModel.swift
//  Yurtify
//
//  Created by dark type on 24.06.2025.
//

import Combine
import CoreLocation
import SwiftUI

@MainActor
class OffersViewModel: ObservableObject {
    @Published var offers: [Offer] = []
    @Published var filteredOffers: [Offer] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] searchTerm in
                Task { @MainActor [weak self] in
                    self?.filterOffers(with: searchTerm)
                }
            }
            .store(in: &cancellables)
        
        Task {
            await loadMockData()
        }
    }
    
    func loadMockData() async {
        await MainActor.run {
            isLoading = true
        }
        
        try? await Task.sleep(nanoseconds: 800000000)
        
        let mockOffers = createMockOffers()
        
        await MainActor.run {
            self.offers = mockOffers
            self.filteredOffers = mockOffers
            self.isLoading = false
        }
    }
    
    private func createMockOffers() -> [Offer] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return [
            Offer(
                title: "Современная квартира с видом на горы",
                address: "Бишкек, ул. Ленина, 10",
                price: 100000.0,
                startDate: dateFormatter.date(from: "2025-07-01") ?? Date(),
                endDate: dateFormatter.date(from: "2025-08-01") ?? Date(),
                bedsCount: 2,
                bathroomsCount: 1,
                area: 60.0,
                period: .perMonth,
                maxOccupancy: 3,
                coordinate: CLLocationCoordinate2D(latitude: 42.8746, longitude: 74.5698)
            ),
            Offer(
                title: "Уютный гостевой домик",
                address: "Кант, Комсомольский пр., 25",
                price: 3500.0,
                startDate: dateFormatter.date(from: "2025-07-15") ?? Date(),
                endDate: dateFormatter.date(from: "2025-07-25") ?? Date(),
                bedsCount: 1,
                bathroomsCount: 1,
                area: 45.0,
                period: .perDay,
                maxOccupancy: 2,
                isOwner: false,
                coordinate: CLLocationCoordinate2D(latitude: 42.8936, longitude: 74.8508)
            ),
            Offer(
                title: "Люкс в Иссык-Куль Резорт",
                address: "Чолпон-Ата, Набережная, 12",
                price: 6000.0,
                startDate: dateFormatter.date(from: "2025-08-01") ?? Date(),
                endDate: dateFormatter.date(from: "2025-08-10") ?? Date(),
                bedsCount: 2,
                bathroomsCount: 2,
                area: 75.0,
                period: .perDay,
                maxOccupancy: 4,
                isOwner: false,
                coordinate: CLLocationCoordinate2D(latitude: 42.6503, longitude: 77.0823)
            ),
            Offer(
                title: "Моя квартира для сдачи",
                address: "Бишкек, ул. Горького, 119",
                price: 75000,
                startDate: dateFormatter.date(from: "2025-07-01") ?? Date(),
                endDate: dateFormatter.date(from: "2025-07-30") ?? Date(),
                bedsCount: 3,
                bathroomsCount: 1,
                area: 65.0,
                maxOccupancy: 4,
                isOwner: true,
                coordinate: CLLocationCoordinate2D(latitude: 42.8648, longitude: 74.5814),
                isRented: true
            ),
            Offer(
                title: "Курортный домик на берегу озера",
                address: "Каракол, ул. Озерная, 5",
                price: 4500.0,
                startDate: dateFormatter.date(from: "2025-07-20") ?? Date(),
                endDate: dateFormatter.date(from: "2025-08-05") ?? Date(),
                bedsCount: 3,
                bathroomsCount: 2,
                area: 90.0,
                period: .perDay,
                maxOccupancy: 6,
                isOwner: false,
                coordinate: CLLocationCoordinate2D(latitude: 42.4907, longitude: 78.3936)
            )
        ]
    }
    
    @MainActor
    private func filterOffers(with searchTerm: String) {
        if searchTerm.isEmpty {
            filteredOffers = offers
            return
        }
        
        let lowercasedSearchTerm = searchTerm.lowercased()
        filteredOffers = offers.filter { offer in
            offer.title.lowercased().contains(lowercasedSearchTerm) ||
                offer.address.lowercased().contains(lowercasedSearchTerm)
        }
    }
    
    func refresh() {
        Task {
            await loadMockData()
        }
    }
    
    @MainActor
    func toggleFavorite(for offerId: String) {
        if let index = offers.firstIndex(where: { $0.id == offerId }) {
            offers[index].isFavorited.toggle()
        }
        
        if let filteredIndex = filteredOffers.firstIndex(where: { $0.id == offerId }) {
            filteredOffers[filteredIndex].isFavorited.toggle()
        }
    }
}
