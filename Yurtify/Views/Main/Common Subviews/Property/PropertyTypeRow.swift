//
//  PropertyTypeRow.swift
//  Yurtify
//
//  Created by dark type on 23.06.2025.
//

import SwiftUI

struct PropertyTypeRow: View {
    // MARK: - Properties

    @Binding var selectedType: PropertyType?
    let types: [PropertyType]
    let spacing: CGFloat
    let itemWidth: CGFloat
    let itemHeight: CGFloat

    init(
        selectedType: Binding<PropertyType?>,
        types: [PropertyType] = PropertyType.allCases,
        spacing: CGFloat = 12,
        itemWidth: CGFloat = 100,
        itemHeight: CGFloat = 100
    ) {
        self._selectedType = selectedType
        self.types = types
        self.spacing = spacing
        self.itemWidth = itemWidth
        self.itemHeight = itemHeight
    }

    // MARK: - Body

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: spacing) {
                ForEach(types) { propertyType in
                    PropertyTypeView(
                        propertyType: propertyType,
                        width: itemWidth,
                        height: itemHeight,
                        isSelected: propertyType == selectedType,
                        onSelect: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                if selectedType != propertyType {
                                    selectedType = propertyType
                                }
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, spacing)
            .padding(.vertical, spacing / 2)
        }
    }
}

// MARK: - Self-sizing row using GeometryReader

struct AdaptivePropertyTypeRow: View {
    // MARK: - Properties

    @Binding var selectedType: PropertyType?
    let types: [PropertyType]
    let spacing: CGFloat

    init(
        selectedType: Binding<PropertyType?>,
        types: [PropertyType] = PropertyType.allCases,
        spacing: CGFloat = 12
    ) {
        self._selectedType = selectedType
        self.types = types
        self.spacing = spacing
    }

    // MARK: - Body

    var body: some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width
            let idealItemWidth: CGFloat = min(120, availableWidth / 3)

            PropertyTypeRow(
                selectedType: $selectedType,
                types: types,
                spacing: spacing,
                itemWidth: idealItemWidth - 24,
                itemHeight: idealItemWidth * 1.1 - 24
            )
        }
    }
}

#Preview {
    Group {
        VStack(spacing: 20) {
            PropertyTypeView(
                propertyType: .hotel,
                width: 100,
                height: 110,
                isSelected: true,
                onSelect: {}
            )

            PropertyTypeView(
                propertyType: .camping,
                width: 100,
                height: 110,
                isSelected: false,
                onSelect: {}
            )
        }

        StateWrapper(initialState: PropertyType.hotel) { $selectedType in
            PropertyTypeRow(
                selectedType: $selectedType,
                itemWidth: 80,
                itemHeight: 70
            )
            .frame(height: 140)
        }
    }
}
