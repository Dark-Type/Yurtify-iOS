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
    @State private var selectedOffer: Offer?
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 42.8746, longitude: 74.5698),
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )
    @StateObject private var locationManager = LocationManager()
    
    @State private var isProcessingSelection = false
    @State private var lastSelectionTime = Date.distantPast
    
    var body: some View {
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
                    Spacer()
                        .frame(height: geometry.safeAreaInsets.top)
                    
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
                        Task {
                            await requestUserLocation()
                        }
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
        .fullScreenCover(item: $selectedOffer) { offer in
            OfferDetailView(offer: offer, onDismiss: {
                selectedOffer = nil
            })
        }
    }
    
    private func handleOfferSelection(_ offerId: String) {
        if isProcessingSelection {
            return
        }
        
        let now = Date()
        if now.timeIntervalSince(lastSelectionTime) < 0.5 {
            return
        }
        
        isProcessingSelection = true
        lastSelectionTime = now
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let offer = self.viewModel.filteredOffers.first(where: { $0.id == offerId }) {
                self.selectedOffer = offer
            }
            
            self.isProcessingSelection = false
        }
    }
    
    private func formatPrice(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: price)) ?? "\(price)"
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
                    } else {
                        print("Could not get user location")
                    }
                }
            }
        }
    }
}

#Preview {
    MapView()
}
