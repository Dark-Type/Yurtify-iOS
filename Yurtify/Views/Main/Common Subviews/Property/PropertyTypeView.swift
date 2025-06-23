//
//  PropertyTypeView.swift
//  Yurtify
//
//  Created by dark type on 23.06.2025.
//


import SwiftUI

struct PropertyTypeView: View {
    // MARK: - Properties
    let propertyType: PropertyType
    let width: CGFloat
    let height: CGFloat
    let isSelected: Bool
    let onSelect: () -> Void
    
    // MARK: - Body
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 8) {
                Image.appIcon(propertyType.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(isSelected ? .primaryVariant : .textPrimary)
                
                Text(propertyType.localizedName)
                    .font(.app.poppinsMedium(size: 12))
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(isSelected ? .primaryVariant : .textPrimary)
            }
            .frame(width: width, height: height)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.accentLight))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(isSelected ? Color.primaryVariant : Color.clear, lineWidth: 2)
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(ScaleButtonStyle()) 
    }
}
