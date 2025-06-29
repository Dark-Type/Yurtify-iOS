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
    
    init(offer: Offer, onDismiss: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: OfferDetailViewModel(offer: offer))
        self.onDismiss = onDismiss
    }
    
    // MARK: - Main body structure

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.app.base.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ZStack(alignment: .top) {
                        if let image = viewModel.property?.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width, height: geometry.size.height * 0.4)
                                .clipped()
                                .edgesIgnoringSafeArea(.top)
                        } else {
                            Color.gray.opacity(0.3)
                                .frame(width: geometry.size.width, height: geometry.size.height * 0.4)
                                .edgesIgnoringSafeArea(.top)
                            
                            Image(systemName: "photo.fill")
                                .font(.system(size: 120))
                                .foregroundColor(.gray)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                        }
                        
                        HStack {
                            Button(action: {
                                onDismiss()
                            }) {
                                Image.appIcon(.goBackButton)
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 16) {
                                Button(action: viewModel.shareProperty) {
                                    Image.appIcon(.shareButton)
                                }
                                
                                Button(action: viewModel.toggleFavorite) {
                                    Image.appIcon(viewModel.isFavorite ? .favoriteButtonSelected : .favoriteButtonUnselected)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, geometry.safeAreaInsets.top + 8)
                    }
                    
                    ScrollView {
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
                    }
                    
                    Spacer(minLength: 0)
                    
                    bottomActionBar
                }
                
                if viewModel.isRentSuccessful {
                    rentSuccessOverlay
                }
            }
            .edgesIgnoringSafeArea(.top)
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Header Image Section
    
    private var headerImageSection: some View {
        ZStack {
            if let image = viewModel.property?.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.4)
                    .clipped()
            } else {
                Color.gray.opacity(0.3)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.4)
            }
        }
    }
    
    // MARK: - Navigation Buttons
    
    private var backButton: some View {
        Button(action: {
            onDismiss()
        }) {
            Image.appIcon(.goBackButton)
                .padding()
        }
        .padding(.top, 16)
    }
    
    private var topRightButtons: some View {
        HStack(spacing: 16) {
            Button(action: viewModel.shareProperty) {
                Image.appIcon(.shareButton)
            }
            
            Button(action: viewModel.toggleFavorite) {
                Image.appIcon(viewModel.isFavorite ? .favoriteButtonSelected : .favoriteButtonUnselected)
            }
        }
        .padding(.top, 16)
        .padding(.trailing, 16)
    }
    
    // MARK: - Title Section
    
    private var titleSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.property?.title ?? "Property Details")
                    .font(.app.title2())
                    .foregroundColor(.app.textPrimary)
                
                Text(viewModel.property?.address ?? "")
                    .font(.app.footnote())
                    .foregroundColor(.app.textFade)
            }
            
            Spacer()
            
            if let propertyType = PropertyType(rawValue: "hotel") {
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
    
    // MARK: - Section Tabs (Separated from content)
    
    private var sectionTabsView: some View {
        HStack(spacing: 0) {
            ForEach(0 ..< 3, id: \.self) { index in
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
    
    // MARK: - Section Content (TabView)
    
    private var sectionContentView: some View {
        TabView(selection: $viewModel.selectedSectionIndex) {
            ScrollView {
                descriptionSection
                    .padding(.top, 16)
            }
            .tag(0)
            
            ScrollView {
                gallerySection
                    .padding(.top, 16)
            }
            .tag(1)
            
            ScrollView {
                similarSection
                    .padding(.top, 16)
            }
            .tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(maxWidth: .infinity)
        .frame(minHeight: UIScreen.main.bounds.height * 0.45)
    }

    // MARK: - Description Section
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 40) {
            if let property = viewModel.property {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Property Details")
                        .font(.app.headline())
                        .foregroundColor(.app.textPrimary)
                    
                    MeasuresRow(
                        area: .constant(property.area),
                        beds: .constant(Double(property.bedsCount)),
                        capacity: .constant(Double(property.maxOccupancy))
                    )
                    .frame(height: 120)
                    .disabled(true)
                }
            }
            
            if let owner = viewModel.owner {
                VStack(alignment: .leading, spacing: 12) {
                    Text(L10n.Detail.owner)
                        .font(.app.headline())
                        .foregroundColor(.app.textPrimary)
                    
                    HStack(alignment: .center, spacing: 16) {
                        owner.image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 70, height: 70)
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(owner.firstName) \(owner.lastName)")
                                .font(.app.subheadline(.semiBold))
                                .foregroundColor(.app.textPrimary)
                            
                            Text(owner.patronymic ?? "")
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
                                Text(owner.phoneNumber)
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
                }
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text(L10n.Detail.conveniences)
                    .font(.app.headline())
                    .foregroundColor(.app.textPrimary)
                
                let allConveniences = Convenience.allCases
                
                ConvenienceGrid(conveniences: allConveniences)
                    .frame(height: CGFloat((allConveniences.count + 3) / 4) * 110)
                    .padding(.bottom, 20)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text(L10n.Detail.address)
                    .font(.app.headline())
                    .foregroundColor(.app.textPrimary)
                    .padding(.top, 10)
                
                if let property = viewModel.property {
                    OfferMapView(coordinate: property.coordinate)
                        .frame(height: 200)
                        .cornerRadius(12)
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 100)
    }
    
    // MARK: - Gallery Section
    
    private var gallerySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(L10n.Detail.gallery)
                .font(.app.headline())
                .foregroundColor(.app.textPrimary)
                .padding(.horizontal)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(0 ..< viewModel.galleryImages.count, id: \.self) { index in
                    viewModel.galleryImages[index]
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Similar Section
    
    private var similarSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(L10n.Detail.similarOffers)
                .font(.app.headline())
                .foregroundColor(.app.textPrimary)
                .padding(.horizontal)
            
            ForEach(viewModel.similarOffers) { offer in
                NavigationLink {
                    OfferDetailView(offer: offer, onDismiss: onDismiss)
                } label: {
                    OfferView(offer: offer)
                        .padding(.bottom, 8)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.vertical)
    }
    
    // MARK: - Bottom Action Bar
    
    private var bottomActionBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(L10n.Detail.price)
                    .font(.app.caption1())
                    .foregroundColor(.app.textFade)
                
                Text(L10n.Measures.formatPrice(
                    viewModel.property?.price ?? 0,
                    period: viewModel.property?.period ?? .perMonth
                ))
                .font(.app.headline())
                .foregroundColor(.app.textPrimary)
            }
            
            Spacer()
            
            Button(action: viewModel.rentProperty) {
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

// MARK: - Preview

#Preview {
    OfferDetailView(
        offer: Offer(
            title: "Cozy Apartment with Lake View",
            address: "Bishkek, Chuy Avenue 123",
            price: 25000,
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400 * 30),
            bedsCount: 2,
            area: 65.0,
            period: .perMonth,
            maxOccupancy: 4,
            coordinate: CLLocationCoordinate2D(latitude: 42.87462, longitude: 74.5698)
        ),
        onDismiss: {}
    )
}
