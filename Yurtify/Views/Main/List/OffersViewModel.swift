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
    @Published var selectedPropertyType: PropertyType? = nil

    @Published var currentPage = 0
    @Published var hasMorePages = true
    private let pageSize: Int32 = 50

    @Published var isSearching = false
    @Published var searchResultsCount = 0

    private var apiService: APIService?
    private var cancellables = Set<AnyCancellable>()

    enum PropertyType: String, CaseIterable {
        case cottage = "COTTAGE"
        case room = "ROOM"
        case hotel = "HOTEL"

        var displayName: String {
            switch self {
            case .cottage: return "Коттедж"
            case .room: return "Комната"
            case .hotel: return "Отель"
            }
        }
    }

    init() {
        setupSearchDebouncing()
    }

    func setAPIService(_ apiService: APIService) {
        self.apiService = apiService
        Task {
            await loadOffers(refresh: true)
        }
    }

    private func setupSearchDebouncing() {
        Publishers.CombineLatest($searchText, $selectedPropertyType)
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] searchText, _ in
                Task { @MainActor [weak self] in
                    await self?.handleSearchChange(searchText: searchText)
                }
            }
            .store(in: &cancellables)
    }

    @MainActor
    private func handleSearchChange(searchText: String) async {
        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedSearch.isEmpty {
            isSearching = false
            await loadOffers(refresh: true)
        } else {
            isSearching = true
            await performSearch(query: trimmedSearch, refresh: true)
        }
    }

    // MARK: - Search Logic

    private func performSearch(query: String, refresh: Bool) async {
        guard let apiService = apiService else {
            await loadMockData()
            return
        }

        if refresh {
            await MainActor.run {
                currentPage = 0
                hasMorePages = true
                if !isLoading {
                    offers = []
                    filteredOffers = []
                    searchResultsCount = 0
                }
            }
        }

        guard hasMorePages else { return }

        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }

        do {
            let typeFilter: Operations.getAllHousings.Input.Query._typePayload? = {
                guard let selectedType = selectedPropertyType else { return nil }
                switch selectedType {
                case .cottage: return .COTTAGE
                case .room: return .ROOM
                case .hotel: return .HOTEL
                }
            }()

            print("🔍 Searching offers - Page: \(currentPage), Query: '\(query)', Type: \(String(describing: typeFilter))")

            async let titleSearchTask = apiService.getAllHousings(
                page: Int32(currentPage),
                size: pageSize,
                title: query,
                address: nil,
                type: typeFilter
            )
            async let addressSearchTask = apiService.getAllHousings(
                page: Int32(currentPage),
                size: pageSize,
                title: nil,
                address: query,
                type: typeFilter
            )

            let (titleResponse, addressResponse) = try await (titleSearchTask, addressSearchTask)
            let combinedResults = await combineSearchResults(
                titleResponse: titleResponse,
                addressResponse: addressResponse
            )

            await MainActor.run {
                if refresh {
                    self.offers = combinedResults.offers
                    self.searchResultsCount = combinedResults.totalItems
                } else {
                    self.offers.append(contentsOf: combinedResults.offers)
                }

                self.filteredOffers = self.offers
                self.currentPage += 1
                self.hasMorePages = self.currentPage < combinedResults.maxTotalPages
                self.isLoading = false

                print("✅ Search completed - Found \(combinedResults.offers.count) new offers, total: \(self.offers.count)")
                print("📊 Search Pagination: Page \(self.currentPage) of \(combinedResults.maxTotalPages), hasMore: \(self.hasMorePages)")
            }
        } catch {
            await handleSearchError(error)
        }
    }

    private func combineSearchResults(
        titleResponse: Components.Schemas.PageDTOHousingResponseDTO,
        addressResponse: Components.Schemas.PageDTOHousingResponseDTO
    ) async -> (offers: [UnifiedPropertyModel], totalItems: Int, maxTotalPages: Int) {
        let titleContent = titleResponse.content ?? []
        let addressContent = addressResponse.content ?? []

        var allHousingDTOs = titleContent + addressContent

        var seenIds = Set<String>()
        allHousingDTOs = allHousingDTOs.filter { dto in
            guard let id = dto.id else { return false }
            if seenIds.contains(id) {
                return false
            }
            seenIds.insert(id)
            return true
        }

        let offers = allHousingDTOs.compactMap { housingDTO in
            let converted = UnifiedPropertyModel.from(housingDTO: housingDTO)
            if converted == nil {
                print("⚠️ Failed to convert search result DTO with ID: \(housingDTO.id ?? "unknown")")
            }
            return converted
        }

        let titleTotalItems = titleResponse.totalItems ?? 0
        let addressTotalItems = addressResponse.totalItems ?? 0
        let combinedTotalItems = max(titleTotalItems, addressTotalItems)

        let titleTotalPages = titleResponse.totalPages ?? 0
        let addressTotalPages = addressResponse.totalPages ?? 0
        let maxTotalPages = max(titleTotalPages, addressTotalPages)

        print("🔍 Search results combined:")
        print("   Title results: \(titleContent.count) items (\(titleTotalItems) total)")
        print("   Address results: \(addressContent.count) items (\(addressTotalItems) total)")
        print("   Combined unique: \(offers.count) items")
        print("   Max total pages: \(maxTotalPages)")

        return (offers: offers, totalItems: Int(combinedTotalItems), maxTotalPages: Int(maxTotalPages))
    }

    private func handleSearchError(_ error: Error) async {
        print("❌ Failed to perform search: \(error)")
        if let apiError = error as? APIError {
            print("   API Error type: \(apiError)")
        } else if let urlError = error as? URLError {
            print("   URL Error: \(urlError.localizedDescription)")
        } else {
            print("   Unknown error: \(error.localizedDescription)")
        }

        await MainActor.run {
            self.errorMessage = error.localizedDescription
            self.isLoading = false

            if self.offers.isEmpty {
                print("🔄 No search results, falling back to mock data")
                Task {
                    await self.loadMockData()
                }
            }
        }
    }

    // MARK: - Regular API Calls (Non-Search)

    func loadOffers(refresh: Bool = false) async {
        guard let apiService = apiService else {
            await loadMockData()
            return
        }

        if refresh {
            await MainActor.run {
                currentPage = 0
                hasMorePages = true
                if !isLoading {
                    offers = []
                    filteredOffers = []
                }
            }
        }

        guard hasMorePages else { return }

        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }

        do {
            let typeFilter: Operations.getAllHousings.Input.Query._typePayload? = {
                guard let selectedType = selectedPropertyType else { return nil }
                switch selectedType {
                case .cottage: return .COTTAGE
                case .room: return .ROOM
                case .hotel: return .HOTEL
                }
            }()

            print("🏠 Loading offers - Page: \(currentPage), Type: \(String(describing: typeFilter))")

            let response = try await apiService.getAllHousings(
                page: Int32(currentPage),
                size: pageSize,
                title: nil,
                address: nil,
                type: typeFilter
            )

            let content = response.content ?? []
            let totalPages = response.totalPages ?? 0
            let currentPageFromResponse = response.currentPage ?? 0
            let totalItems = response.totalItems ?? 0

            print("📄 Response details:")
            print("   Content count: \(content.count)")
            print("   Total pages: \(totalPages)")
            print("   Current page: \(currentPageFromResponse)")
            print("   Total items: \(totalItems)")

            let newOffers = content.compactMap { housingDTO in
                let converted = UnifiedPropertyModel.from(housingDTO: housingDTO)
                if converted == nil {
                    print("⚠️ Failed to convert housing DTO with ID: \(housingDTO.id ?? "unknown")")
                }
                return converted
            }

            await MainActor.run {
                if refresh {
                    self.offers = newOffers
                } else {
                    self.offers.append(contentsOf: newOffers)
                }

                self.filteredOffers = self.offers
                self.currentPage += 1
                self.hasMorePages = self.currentPage < totalPages
                self.isLoading = false

                print("✅ Loaded \(newOffers.count) offers, total: \(self.offers.count)")
                print("📊 Pagination: Page \(self.currentPage) of \(totalPages), hasMore: \(self.hasMorePages)")
            }
        } catch {
            print("❌ Failed to load offers: \(error)")
            if let apiError = error as? APIError {
                print("   API Error type: \(apiError)")
            } else if let urlError = error as? URLError {
                print("   URL Error: \(urlError.localizedDescription)")
            } else {
                print("   Unknown error: \(error.localizedDescription)")
            }

            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false

                if self.offers.isEmpty {
                    print("🔄 No offers loaded, falling back to mock data")
                    Task {
                        await self.loadMockData()
                    }
                }
            }
        }
    }

    func loadMoreOffersIfNeeded(currentOffer: UnifiedPropertyModel) {
        guard !isLoading,
              hasMorePages,
              let lastOffer = offers.last,
              lastOffer.id == currentOffer.id else { return }

        Task {
            if isSearching {
                await performSearch(query: searchText.trimmingCharacters(in: .whitespacesAndNewlines), refresh: false)
            } else {
                await loadOffers(refresh: false)
            }
        }
    }

    func refresh() {
        Task {
            if isSearching {
                await performSearch(query: searchText.trimmingCharacters(in: .whitespacesAndNewlines), refresh: true)
            } else {
                await loadOffers(refresh: true)
            }
        }
    }

    func setPropertyTypeFilter(_ type: PropertyType?) {
        selectedPropertyType = type
    }

    // MARK: - Favorite Management

    @MainActor
    func updateOfferFavoriteStatus(offerId: String, isFavorite: Bool) {
        if let index = offers.firstIndex(where: { $0.id == offerId }) {
            offers[index].isFavorite = isFavorite
            print("✅ Updated offer favorite status in main array: \(offerId) -> \(isFavorite)")
        }

        if let filteredIndex = filteredOffers.firstIndex(where: { $0.id == offerId }) {
            filteredOffers[filteredIndex].isFavorite = isFavorite
            print("✅ Updated offer favorite status in filtered array: \(offerId) -> \(isFavorite)")
        }
    }

    // MARK: - Big-page map loading for MapView

    func loadAllOffersForMap(refresh: Bool = true) async {
        await loadOffers(refresh: refresh)
    }

    func refreshMapOffers() {
        Task {
            await loadAllOffersForMap()
        }
    }

    
    var validMapOffers: [UnifiedPropertyModel] {
        return filteredOffers.filter { offer in
            offer.coordinates.latitude != 0 && offer.coordinates.longitude != 0
        }
    }

    @MainActor
    func toggleFavorite(for offerId: String) {
        guard apiService != nil else {
           
            if let index = offers.firstIndex(where: { $0.id == offerId }) {
                offers[index].isFavorite.toggle()
            }

            if let filteredIndex = filteredOffers.firstIndex(where: { $0.id == offerId }) {
                filteredOffers[filteredIndex].isFavorite.toggle()
            }
            return
        }

        Task {
            if isSearching {
                await performSearch(query: searchText.trimmingCharacters(in: .whitespacesAndNewlines), refresh: false)
            } else {
                await loadOffers(refresh: false)
            }
        }
    }

    // MARK: - Mock Data (Fallback)

    func loadMockData() async {
        await MainActor.run {
            isLoading = true
        }

        try? await Task.sleep(nanoseconds: 800_000_000)

        let mockOffers = createMockOffers()

        await MainActor.run {
            self.offers = mockOffers
            self.filteredOffers = mockOffers
            self.isLoading = false
        }
    }

    private func createMockOffers() -> [UnifiedPropertyModel] {
        return [
            UnifiedPropertyModel(id: UUID().uuidString,
                                 title: "Красивая квартира в центре",
                                 addressName: "Бишкек, ул. Ленина, 10",
                                 coordinates: Coordinates(latitude: 42.8746, longitude: 74.5698),
                                 cost: 100000,
                                 period: .perDay,
                                 closedDates: [],
                                 firstFreeDate: Date(),
                                 firstClosedDate: nil),
            UnifiedPropertyModel(id: UUID().uuidString,
                                 title: "Уютный коттедж",
                                 addressName: "Кант, ул. Садовая, 15",
                                 coordinates: Coordinates(latitude: 42.8946, longitude: 74.6898),
                                 cost: 150000,
                                 period: .perDay,
                                 closedDates: [],
                                 firstFreeDate: Date(),
                                 firstClosedDate: nil)
        ]
    }
}
