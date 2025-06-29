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
    @Published var offers: [UnifiedPropertyModel] = []
    @Published var filteredOffers: [UnifiedPropertyModel] = []
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
    
    private func createMockOffers() -> [UnifiedPropertyModel] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return [
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
                                 coordinates: Coordinates(latitude: 42.87462, longitude: 74.5288),
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
                                 coordinates: Coordinates(),
                                 cost: 0,
                                 period: .perMonth,
                                 closedDates: [],
                                 firstFreeDate: Date(),
                                 firstClosedDate: nil),
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
                                 coordinates: Coordinates(),
                                 cost: 0,
                                 period: .perMonth,
                                 closedDates: [],
                                 firstFreeDate: Date(),
                                 firstClosedDate: nil)
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
                offer.addressName.lowercased().contains(lowercasedSearchTerm)
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
            offers[index].isFavorite.toggle()
        }
        
        if let filteredIndex = filteredOffers.firstIndex(where: { $0.id == offerId }) {
            filteredOffers[filteredIndex].isFavorite.toggle()
        }
    }
}
