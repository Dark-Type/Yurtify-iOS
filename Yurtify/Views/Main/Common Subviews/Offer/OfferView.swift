//
//  OfferView.swift
//  Yurtify
//
//  Created by dark type on 22.06.2025.
//

import SwiftUI

struct OfferView: View {
    @State private var offer: Offer
    private let sourceProperty: UnifiedPropertyModel?
    @State private var isFavorite: Bool
    @State private var showingAuthAlert = false
    @EnvironmentObject var apiService: APIService
    @EnvironmentObject var authManager: AuthManager
    
    init(offer: Offer) {
        self._offer = State(initialValue: offer)
        self.sourceProperty = nil
        self._isFavorite = State(initialValue: offer.isFavorited)
    }
    
    init(property: UnifiedPropertyModel) {
        self._offer = State(initialValue: property.toOffer())
        self.sourceProperty = property
        self._isFavorite = State(initialValue: property.isFavorite)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            headerSection
            imageSection
            priceSection
            propertyDetailsSection
        }
        .padding(20)
        .background(backgroundView)
        .overlay(triangleCornerElement, alignment: .bottomTrailing)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 20)
        .alert("Authentication Required", isPresented: $showingAuthAlert) {
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please sign in to add properties to your favorites.")
        }
    }

    // MARK: - View Sections

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(offer.title)
                    .font(.app.latoBold(size: 20))
                    .foregroundStyle(.textPrimary)
                
                Text(offer.address)
                    .font(.app.latoRegular(size: 12))
                    .foregroundStyle(.textFade)
            }
            
            Spacer()
            
            actionButton
        }
    }
    
    private var actionButton: some View {
        Button(action: handleActionButtonTap) {
            if offer.isOwner {
                Image.appIcon(.mailbox)
                    .foregroundColor(offer.isRented ? .primaryVariant : .textFade)
            } else {
                Image.appIcon(isFavorite ? .favoriteSelected : .favoriteUnselected)
                    .foregroundColor(isFavorite ? .primaryVariant : .textFade)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isFavorite)
        .animation(.easeInOut(duration: 0.2), value: offer.isRented)
    }
    
    private var imageSection: some View {
        GeometryReader { _ in
            if let property = sourceProperty,
               let firstImageId = property.galleryUrls.first,
               !firstImageId.isEmpty
            {
                AsyncImageView(imageId: firstImageId)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .cornerRadius(12)
                    .clipped()
            } else if let image = offer.image {
                image
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .cornerRadius(12)
                    .clipped()
            } else {
                placeholderImage
            }
        }
        .frame(height: 200)
    }
    
    private var placeholderImage: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.gray.opacity(0.1))
            .overlay(
                VStack(spacing: 8) {
                    Image(systemName: "photo.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.gray.opacity(0.6))
                    
                    Text("Фото недоступно")
                        .font(.caption)
                        .foregroundColor(.gray.opacity(0.8))
                }
            )
    }
    
    private var priceSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.Measures.formatPrice(offer.price, period: offer.period))
                .font(.app.latoBold(size: 20))
                .foregroundStyle(.textPrimary)
            
            Text("C \(offer.startDate.formatted(date: .abbreviated, time: .omitted)) до \(offer.endDate.formatted(date: .abbreviated, time: .omitted))")
                .font(.app.latoRegular(size: 12))
                .foregroundColor(Color.app.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var propertyDetailsSection: some View {
        HStack(spacing: 40) {
            propertyDetailItem(
                icon: .bed,
                text: L10n.Measures.formatBeds(offer.bedsCount)
            )
            
            propertyDetailItem(
                icon: .space,
                text: L10n.Measures.formatArea(offer.area)
            )
        }
    }
    
    private func propertyDetailItem(icon: AppIcons, text: String) -> some View {
        VStack {
            Image.appIcon(icon)
                .foregroundColor(.primaryVariant)
            
            Text(text)
                .font(.app.poppinsRegular(size: 12))
                .foregroundStyle(.primaryVariant)
            
            Spacer()
        }
    }
    
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color(.accentLight))
    }
    
    private var triangleCornerElement: some View {
        TriangleCornerElement(
            count: offer.maxOccupancy,
            isOccupied: false
        )
        .frame(width: 60, height: 60)
    }
}

// MARK: - Actions

private extension OfferView {
    func handleActionButtonTap() {
        if offer.isOwner {
            
            withAnimation(.easeInOut(duration: 0.2)) {
                offer.isRented.toggle()
            }
        } else {
            
            toggleFavorite()
        }
    }
    
    func toggleFavorite() {
        guard let property = sourceProperty else {
          
            withAnimation(.easeInOut(duration: 0.2)) {
                isFavorite.toggle()
                offer.isFavorited = isFavorite
            }
            return
        }
        
        guard authManager.isAuthenticated else {
            showingAuthAlert = true
            return
        }
        
        Task {
            do {
                if isFavorite {
                    try await apiService.removeFavorite(housingId: property.id)
                    print("✅ Removed from favorites in OfferView: \(property.id)")
                } else {
                    try await apiService.addFavorite(housingId: property.id)
                    print("✅ Added to favorites in OfferView: \(property.id)")
                }
                
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        self.isFavorite.toggle()
                        self.offer.isFavorited = self.isFavorite
                    }
                }
                
            } catch {
                print("❌ Failed to toggle favorite in OfferView: \(error)")
               
               
            }
        }
    }
}

// MARK: - Triangle Corner Element

struct TriangleCornerElement: View {
    let count: Int
    let isOccupied: Bool
    
    var body: some View {
        ZStack {
            Path { path in
                path.move(to: CGPoint(x: 60, y: 0))
                path.addLine(to: CGPoint(x: 60, y: 60))
                path.addLine(to: CGPoint(x: 0, y: 60))
                path.closeSubpath()
            }
            .fill(Color.app.primaryVariant)
            
            Text("\(count)" + L10n.Measures.Unit.people.localized)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .offset(x: 10, y: 15)
        }
    }
}

// MARK: - Preview 

#Preview {
    VStack(spacing: 20) {
        OfferView(offer: Offer(
            title: "Красивая квартира в центре",
            address: "Бишкек, ул. Ленина, 10",
            price: 100000.0,
            startDate: Date.now,
            endDate: Date.now.addingTimeInterval(86400),
            bedsCount: 2,
            area: 65.0,
            maxOccupancy: 4
        ))

        OfferView(offer: Offer(
            title: "Моя квартира для сдачи",
            address: "Кант, Комсомольский пр., 25",
            price: 75000,
            startDate: Date.now,
            endDate: Date.now.addingTimeInterval(86400),
            bedsCount: 1,
            area: 45.0,
            maxOccupancy: 2,
            isOwner: true,
            isRented: true
        ))
    }
    .padding()
    .background(Color(.systemGray6))
}

struct AsyncImageView: View {
    let imageId: String
    
    @State private var imageData: Data?
    @State private var isLoading = true
    @State private var loadError: Error?
    @EnvironmentObject var apiService: APIService
    
    var body: some View {
        Group {
            if let imageData = imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if isLoading {
                loadingView
            } else {
                errorPlaceholder
            }
        }
        .onAppear {
            loadImage()
        }
    }
    
    private var loadingView: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.gray.opacity(0.1))
            .overlay(
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .primaryVariant))
                    .scaleEffect(0.8)
            )
    }
    
    private var errorPlaceholder: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.gray.opacity(0.1))
            .overlay(
                VStack(spacing: 4) {
                    Image(systemName: "photo.slash.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.gray.opacity(0.6))
                    
                    Text("Не удалось загрузить")
                        .font(.caption2)
                        .foregroundColor(.gray.opacity(0.8))
                }
            )
    }
    
    private func loadImage() {
        Task {
            do {
                print("🖼️ Loading image with ID: \(imageId)")
                let data = try await apiService.getImage(imageId: imageId)
                
                await MainActor.run {
                    self.imageData = data
                    self.isLoading = false
                }
                
                print("✅ Image loaded successfully")
                
            } catch {
                print("❌ Failed to load image: \(error)")
                await MainActor.run {
                    self.loadError = error
                    self.isLoading = false
                }
            }
        }
    }
}
