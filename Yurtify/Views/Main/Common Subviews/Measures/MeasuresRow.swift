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
    @Binding var bathrooms: Double
    @Binding var capacity: Double
    
    var isValid: Bool {
        return area > 0 && beds > 0 && bathrooms > 0 && capacity > 0
    }
    
    // MARK: - Body

    var body: some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width
            let itemWidth = (availableWidth - 3 * 12) / 4 // 12pt spacing between items
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
                    measureType: .bathrooms,
                    width: itemWidth - 24,
                    height: itemHeight - 24,
                    value: $bathrooms
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
        let isBathroomsValid = bathrooms > 0
        let isCapacityValid = capacity > 0
        
        return isAreaValid && isBedsValid && isBathroomsValid && isCapacityValid
    }
}

#Preview {
    Group {
        VStack(spacing: 20) {
            StateWrapper(initialState: 85.5) { $area in
                MeasureInputView(
                    measureType: .area,
                    width: 100,
                    height: 110,
                    value: $area
                )
            }
            
            StateWrapper(initialState: 0.0) { $beds in
                MeasureInputView(
                    measureType: .beds,
                    width: 100,
                    height: 110,
                    value: $beds
                )
            }
        }
        .padding()
        
        StateWrapper4(area: 85.5, beds: 2, bathrooms: 1, capacity: 4) { $area, $beds, $bathrooms, $capacity in
            MeasuresRow(
                area: $area,
                beds: $beds,
                bathrooms: $bathrooms,
                capacity: $capacity
            )
            .frame(height: 120)
        }
        .padding()
    }
}

struct StateWrapper4<Content: View>: View {
    @State var area: Double
    @State var beds: Double
    @State var bathrooms: Double
    @State var capacity: Double
    
    let content: (Binding<Double>, Binding<Double>, Binding<Double>, Binding<Double>) -> Content
    
    init(area: Double, beds: Double, bathrooms: Double, capacity: Double,
         content: @escaping (Binding<Double>, Binding<Double>, Binding<Double>, Binding<Double>) -> Content)
    {
        self._area = State(initialValue: area)
        self._beds = State(initialValue: beds)
        self._bathrooms = State(initialValue: bathrooms)
        self._capacity = State(initialValue: capacity)
        self.content = content
    }
    
    var body: some View {
        content($area, $beds, $bathrooms, $capacity)
    }
}
