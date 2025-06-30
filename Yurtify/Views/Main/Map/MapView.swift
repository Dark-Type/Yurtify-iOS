//
//  MapView.swift
//  Yurtify
//
//  Created by dark type on 14.06.2025.
//

import MapKit
import SwiftUI

struct MapView: View {
    @StateObject private var viewModel = OffersViewModel()
    @State private var selectedOffer: UnifiedPropertyModel?
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 42.8746, longitude: 74.5698),
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )
    @StateObject private var locationManager = LocationManager()
    @EnvironmentObject var apiService: APIService
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack(alignment: .top) {
                MapRepresentable(
                    region: $region,
                    offers: viewModel.filteredOffers,
                    selectedOfferId: selectedOffer?.id,
                    onSelectOffer: { offerId in
                        handleOfferSelection(offerId)
                    }
                )
                .edgesIgnoringSafeArea(.all)

                GeometryReader { geometry in
                    VStack(spacing: 0) {
                        Spacer().frame(height: geometry.safeAreaInsets.top)
                        SearchBar(
                            text: $viewModel.searchText,
                            placeholder: "\(L10n.search) \(L10n.Detail.address)",
                            onSearch: {},
                            onCancel: {}
                        )
                        .padding(.vertical, 8)
                        .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 2)
                    }
                }

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            Task { await requestUserLocation() }
                        } label: {
                            Image(systemName: "location.fill")
                                .foregroundColor(.app.primaryVariant)
                                .padding()
                                .background(Circle().fill(Color.app.white))
                                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                        }
                        .padding([.bottom, .trailing], 16)
                    }
                }
            }
            .navigationDestination(for: UnifiedPropertyModel.self) { offer in
                OfferDetailView(property: offer, onDismiss: {
                    navigationPath.removeLast()
                })
            }
            .refreshable {
                viewModel.refresh()
            }
            .onAppear {
                viewModel.setAPIService(apiService)
            }
        }
        .environmentObject(apiService)
    }

    private func handleOfferSelection(_ offerId: String) {
        if let offer = viewModel.filteredOffers.first(where: { $0.id == offerId }) {
            navigationPath.append(offer)
        }
    }

    private func requestUserLocation() async {
        let authStatus = await locationManager.requestLocationPermission()
        if authStatus == .authorizedWhenInUse || authStatus == .authorizedAlways {
            if let userLocation = locationManager.currentLocation {
                await MainActor.run {
                    region = MKCoordinateRegion(
                        center: userLocation.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )
                }
            } else {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                await MainActor.run {
                    if let userLocation = locationManager.currentLocation {
                        region = MKCoordinateRegion(
                            center: userLocation.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                        )
                    }
                }
            }
        }
    }
}

#Preview {
    MapView()
}
