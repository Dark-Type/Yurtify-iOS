//
//  OfferView.swift
//  Yurtify
//
//  Created by dark type on 22.06.2025.
//

import SwiftUI

struct OfferView: View {
    @State private var offer: Offer
    
    init(offer: Offer) {
        self._offer = State(initialValue: offer)
    }
    
    init(property: UnifiedPropertyModel) {
        self._offer = State(initialValue: property.toOffer())
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
    }
}

// MARK: - View Sections

private extension OfferView {
    var headerSection: some View {
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
    
    var actionButton: some View {
        Button(action: toggleAction) {
            if offer.isOwner {
                Image.appIcon(.mailbox)
                    .foregroundColor(offer.isRented ? .primaryVariant : .textFade)
            } else {
                Image.appIcon(offer.isFavorited ? .favoriteSelected : .favoriteUnselected)
                    .foregroundColor(offer.isFavorited ? .primaryVariant : .textFade)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: offer.isFavorited)
        .animation(.easeInOut(duration: 0.2), value: offer.isRented)
    }
    
    var imageSection: some View {
        GeometryReader { _ in
            if let image = offer.image {
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
    
    var placeholderImage: some View {
        Image(systemName: "photo.fill")
            .font(.system(size: 60))
            .foregroundColor(.gray)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
    }
    
    var priceSection: some View {
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
    
    var propertyDetailsSection: some View {
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
    
    func propertyDetailItem(icon: AppIcons, text: String) -> some View {
        VStack {
            Image.appIcon(icon)
                .foregroundColor(.primaryVariant)
            
            Text(text)
                .font(.app.poppinsRegular(size: 12))
                .foregroundStyle(.primaryVariant)
            
            Spacer()
        }
    }
    
    var backgroundView: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color(.accentLight))
    }
    
    var triangleCornerElement: some View {
        TriangleCornerElement(
            count: offer.maxOccupancy,
            isOccupied: false
        )
        .frame(width: 60, height: 60)
    }
}

// MARK: - Actions

private extension OfferView {
    func toggleAction() {
        withAnimation(.easeInOut(duration: 0.2)) {
            if offer.isOwner {
                offer.isRented.toggle()
            } else {
                offer.isFavorited.toggle()
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
