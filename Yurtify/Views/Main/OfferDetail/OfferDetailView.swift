//
//  OfferDetailView.swift
//  Yurtify
//
//  Created by dark type on 24.06.2025.
//

import MapKit
import SwiftUI

struct OfferDetailView: View {
    @StateObject private var viewModel: OfferDetailViewModel
    @State private var selectedImageIndex: Int = 0
    
    let onDismiss: () -> Void

    init(property: UnifiedPropertyModel, onDismiss: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: OfferDetailViewModel(property: property))
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.app.base.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        headerImageSection(geometry: geometry)
                        
                        VStack(spacing: 20) {
                            titleSection
                            sectionTabsView
                            
                            if viewModel.selectedSectionIndex == 0 {
                                descriptionSection
                            } else if viewModel.selectedSectionIndex == 1 {
                                gallerySection
                            } else {
                                similarSection
                            }
                        }
                        .padding(.top)
                        .padding(.bottom, 100)
                        .background(Color.app.base)
                    }
                }
                .edgesIgnoringSafeArea(.top)
                
                VStack {
                    HStack {
                        Button(action: onDismiss) {
                            Image.appIcon(.goBackButton)
                        }
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.9))
                                .frame(width: 40, height: 40)
                        )
                        
                        Spacer()
                        
                        HStack(spacing: 16) {
                            Button(action: viewModel.shareProperty) {
                                Image.appIcon(.shareButton)
                            }
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.9))
                                    .frame(width: 40, height: 40)
                            )
                            
                            Button(action: viewModel.toggleFavorite) {
                                Image.appIcon(viewModel.isFavorite ? .favoriteButtonSelected : .favoriteButtonUnselected)
                            }
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.9))
                                    .frame(width: 40, height: 40)
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, geometry.safeAreaInsets.top + 16)
                    
                    Spacer()
                }
                if !(viewModel.property?.isOwn ?? true) {
                    VStack {
                        Spacer()
                        bottomActionBar
                    }
                }
                
                if viewModel.isRentSuccessful {
                    rentSuccessOverlay
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $viewModel.showingBookingSheet) {
                BookingDateSheet(
                    viewModel: viewModel,
                    isPresented: $viewModel.showingBookingSheet
                )
            }
        }
    }

    // MARK: - Header Image Section
    
    private func headerImageSection(geometry: GeometryProxy) -> some View {
        ZStack {
            if let property = viewModel.property, !property.posterUrl.isEmpty {
                AsyncImage(url: URL(string: property.posterUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(width: geometry.size.width, height: geometry.size.height * 0.4)
                .clipped()
            } else {
                ZStack {
                    Color.gray.opacity(0.3)
                        .frame(width: geometry.size.width, height: geometry.size.height * 0.4)
                    
                    Image(systemName: "photo.fill")
                        .font(.system(size: 120))
                        .foregroundColor(.gray)
                }
            }
        }
    }
    
    // MARK: - Title Section
    
    private var titleSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.property?.title ?? "Property Details")
                    .font(.app.title2())
                    .foregroundColor(.app.textPrimary)
                
                Text(viewModel.property?.addressName ?? "")
                    .font(.app.footnote())
                    .foregroundColor(.app.textFade)
            }
            
            Spacer()
            
            if let propertyTypeRaw = viewModel.property?.propertyType,
               let propertyType = PropertyType(rawValue: propertyTypeRaw)
            {
                VStack {
                    Image.appIcon(propertyType.icon)
                        .foregroundColor(.app.primaryVariant)
                    
                    Text(propertyType.localizedName)
                        .font(.app.caption1())
                        .foregroundColor(.app.textFade)
                }
                .padding(8)
                .background(Color.app.accentLight)
                .cornerRadius(8)
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Section Tabs
    
    private var sectionTabsView: some View {
        HStack(spacing: 0) {
            ForEach(0..<3, id: \.self) { index in
                let titles = [L10n.Detail.description, L10n.Detail.gallery, L10n.Detail.similar]
                
                Button(action: {
                    withAnimation {
                        viewModel.selectedSectionIndex = index
                    }
                }) {
                    VStack(spacing: 8) {
                        Text(titles[index])
                            .font(.app.headline())
                            .foregroundColor(viewModel.selectedSectionIndex == index ? .app.primaryVariant : .app.textFade)
                            .frame(maxWidth: .infinity)
                        
                        Rectangle()
                            .fill(viewModel.selectedSectionIndex == index ? Color.app.primaryVariant : Color.app.textFade.opacity(0.3))
                            .frame(height: 2)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Description Section
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 40) {
            if let property = viewModel.property {
                propertyDetailsCard(property: property)
                ownerCard()
                conveniencesCard(property: property)
                mapCard(property: property)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 100)
    }
    
    private func propertyDetailsCard(property: UnifiedPropertyModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Property Details")
                .font(.app.headline())
                .foregroundColor(.app.textPrimary)
            
            MeasuresRow(
                area: .constant(Double(property.placeAmount)),
                beds: .constant(Double(property.bedsCount)),
                capacity: .constant(Double(property.maxPeople))
            )
            .frame(height: 120)
            .disabled(true)
        }
    }
    
    private func ownerCard() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.Detail.owner)
                .font(.app.headline())
                .foregroundColor(.app.textPrimary)
            
            if let owner = viewModel.owner, !owner.fullName.isEmpty {
                HStack(alignment: .center, spacing: 16) {
                    AsyncImage(url: URL(string: owner.imageUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 70))
                            .foregroundColor(.gray)
                    }
                    .frame(width: 70, height: 70)
                    .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(owner.fullName)
                            .font(.app.subheadline(.semiBold))
                            .foregroundColor(.app.textPrimary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 8) {
                        HStack(spacing: 6) {
                            Text(owner.email)
                                .font(.app.caption1())
                                .foregroundColor(.app.textPrimary)
                            
                            AppIcons.mail.image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 14, height: 14)
                                .foregroundColor(.app.primaryVariant)
                        }
                        
                        HStack(spacing: 6) {
                            Text(owner.phone)
                                .font(.app.caption1())
                                .foregroundColor(.app.textPrimary)
                            
                            AppIcons.phone.image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 14, height: 14)
                                .foregroundColor(.app.primaryVariant)
                        }
                    }
                }
                .padding(.vertical, 8)
            } else {
                Text("Owner information not available")
                    .font(.app.caption1())
                    .foregroundColor(.app.textFade)
                    .italic()
            }
        }
    }
    
    private func conveniencesCard(property: UnifiedPropertyModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.Detail.conveniences)
                .font(.app.headline())
                .foregroundColor(.app.textPrimary)
            
            let propertyConveniences = property.properties.compactMap { Convenience(rawValue: $0) }
            
            ConvenienceGrid(conveniences: propertyConveniences)
                .frame(height: CGFloat((propertyConveniences.count + 3) / 4) * 110)
                .padding(.bottom, 20)
        }
    }
    
    private func mapCard(property: UnifiedPropertyModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.Detail.address)
                .font(.app.headline())
                .foregroundColor(.app.textPrimary)
                .padding(.top, 10)
            
            OfferMapView(coordinate: property.coordinates.clLocation)
                .frame(height: 200)
                .cornerRadius(12)
        }
    }
    
    // MARK: - Gallery Section
    
    private var gallerySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(L10n.Detail.gallery)
                .font(.app.headline())
                .foregroundColor(.app.textPrimary)
                .padding(.horizontal)
            
            if viewModel.isLoadingImages {
                VStack {
                    ProgressView()
                    Text("Loading images...")
                        .font(.app.caption1())
                        .foregroundColor(.app.textFade)
                        .padding(.top, 8)
                }
                .frame(height: 200)
            } else if viewModel.galleryImages.isEmpty {
                VStack {
                    Image(systemName: "photo.badge.plus")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("No images available")
                        .font(.app.caption1())
                        .foregroundColor(.app.textFade)
                }
                .frame(height: 200)
            } else {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 8),
                        GridItem(.flexible(), spacing: 8)
                    ],
                    spacing: 12
                ) {
                    ForEach(0..<viewModel.galleryImages.count, id: \.self) { index in
                        Image(uiImage: viewModel.galleryImages[index])
                            .resizable()
                            .aspectRatio(1, contentMode: .fill)
                            .frame(maxWidth: .infinity)
                            .clipped()
                            .cornerRadius(12)
                            .onTapGesture {
                                selectedImageIndex = index
                                // TODO: Open full screen image viewer
                            }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Similar Section
    
    private var similarSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(L10n.Detail.similarOffers)
                .font(.app.headline())
                .foregroundColor(.app.textPrimary)
                .padding(.horizontal)
            
            ForEach(viewModel.similarOffers) { property in
                NavigationLink(value: property) {
                    OfferView(property: property)
                        .padding(.bottom, 8)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.vertical)
        .navigationDestination(for: UnifiedPropertyModel.self) { offer in
            OfferDetailView(property: offer, onDismiss: onDismiss)
        }
    }
    
    // MARK: - Bottom Action Bar
    
    private var bottomActionBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(L10n.Detail.price)
                    .font(.app.caption1())
                    .foregroundColor(.app.textFade)
                
                Text(L10n.Measures.formatPrice(
                    viewModel.property?.cost ?? 0,
                    period: viewModel.property?.period ?? .perMonth
                ))
                .font(.app.headline())
                .foregroundColor(.app.textPrimary)
            }
            
            Spacer()
            
            Button(action: viewModel.showBookingSheet) {
                Text(L10n.Detail.rent)
                    .font(.app.headline())
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                    .background(Color.app.primaryVariant)
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(Color.app.accentLight)
        .shadow(color: Color.black.opacity(0.1), radius: 4, y: -2)
    }
    
    // MARK: - Rent Success Overlay
    
    private var rentSuccessOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color.app.primaryVariant)
                
                Text("Booking Successful!")
                    .font(.app.title3())
                    .foregroundColor(.app.textPrimary)
                
                Text("Your reservation has been confirmed.")
                    .font(.app.body())
                    .foregroundColor(.app.textFade)
                    .multilineTextAlignment(.center)
                
                Button(action: {
                    onDismiss()
                }) {
                    Text("Continue")
                        .font(.app.headline())
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .background(Color.app.primaryVariant)
                        .cornerRadius(12)
                }
                .padding(.top, 16)
            }
            .padding(32)
            .background(Color.app.base)
            .cornerRadius(16)
            .shadow(radius: 20)
            .transition(.opacity)
            .animation(.easeInOut, value: viewModel.isRentSuccessful)
            .frame(maxWidth: 300)
        }
    }
}

// MARK: - Extensions

extension L10n.Measures.Price {
    static let total = L10n.Measures.Price(rawValue: "total") ?? .perDay
}

// MARK: - Preview

#Preview {
    NavigationStack {
        OfferDetailView(
            property: UnifiedPropertyModel(id: UUID().uuidString,
                                           title: "Квартира",
                                           addressName: "бишкек ",
                                           coordinates: Coordinates(latitude: 42.87462, longitude: 74.5698),
                                           cost: 200000,
                                           period: .perMonth,
                                           closedDates: [],
                                           firstFreeDate: Date(),
                                           firstClosedDate: nil,
                                           owner: OwnerDto(
                                            fullName: "John Doe\nSmith",
                                            email: "john.doe@example.com",
                                            phone: "+996 555 123 456",
                                            imageUrl: "https://example.com/avatar.jpg"
                                           )
                                          ),
                                            
            
            onDismiss: {}
        )
    }
}
