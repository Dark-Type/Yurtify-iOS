//
//  MeasuresRow.swift
//  Yurtify
//
//  Created by dark type on 23.06.2025.
//

import SwiftUI

struct MeasuresRow: View {
    // MARK: - Properties

    @Binding var area: Double
    @Binding var beds: Double
    @Binding var capacity: Double

    var isValid: Bool {
        return area > 0 && beds > 0 && capacity > 0
    }

    // MARK: - Body

    var body: some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width
            let itemWidth = (availableWidth - 3 * 12) / 4
            let itemHeight = itemWidth * 1.1

            HStack(spacing: 12) {
                MeasureInputView(
                    measureType: .area,
                    width: itemWidth - 24,
                    height: itemHeight - 24,
                    value: $area
                )

                MeasureInputView(
                    measureType: .beds,
                    width: itemWidth - 24,
                    height: itemHeight - 24,
                    value: $beds
                )

                MeasureInputView(
                    measureType: .capacity,
                    width: itemWidth - 24,
                    height: itemHeight - 24,
                    value: $capacity
                )
            }
            .frame(width: availableWidth, height: itemHeight)
        }
    }
}

// MARK: - Validation helper extension

extension MeasuresRow {
    func validateAndShake() -> Bool {
        let isAreaValid = area > 0
        let isBedsValid = beds > 0
        let isCapacityValid = capacity > 0

        return isAreaValid && isBedsValid && isCapacityValid
    }
}

struct StateWrapper4<Content: View>: View {
    @State var area: Double
    @State var beds: Double
    @State var capacity: Double

    let content: (Binding<Double>, Binding<Double>, Binding<Double>) -> Content

    init(area: Double, beds: Double, capacity: Double,
         content: @escaping (Binding<Double>, Binding<Double>, Binding<Double>) -> Content)
    {
        self._area = State(initialValue: area)
        self._beds = State(initialValue: beds)
        self._capacity = State(initialValue: capacity)
        self.content = content
    }

    var body: some View {
        content($area, $beds, $capacity)
    }
}
