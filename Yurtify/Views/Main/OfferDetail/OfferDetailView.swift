//
//  OfferDetailView.swift
//  Yurtify
//
//  Created by dark type on 24.06.2025.
//

import SwiftUI

struct OfferDetailView: View {
    let offer: Offer
    let onDismiss: () -> Void

    var body: some View {
        NavigationView {
            VStack {
                Text(offer.title)
                    .font(.title)
                    .padding()

                Text("Price: \(formatPrice(offer.price)) \(offer.period.localized)")
                    .font(.headline)
                    .padding()

                Spacer()
            }
            .navigationTitle("Offer Details")
            .navigationBarItems(leading: Button("Close") {
                onDismiss()
            })
        }
    }

    private func formatPrice(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: price)) ?? "\(price)"
    }
}
