//
//  EnhancedMeasuresRow.swift
//  Yurtify
//
//  Created by dark type on 29.06.2025.
//

import SwiftUI

struct EnhancedMeasuresRow: View {
    @Binding var areaText: String
    @Binding var beds: Double
    @Binding var rooms: Double
    @Binding var capacity: Double
    
    var focusedField: FocusState<CreateView.FormField?>.Binding
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                AreaInputItem(
                    icon: .space,
                    title: "Area",
                    text: $areaText,
                    suffix: "m²",
                    focusedField: focusedField
                )
                
                MeasureItem(
                    icon: .bed,
                    title: "Beds",
                    value: $beds,
                    suffix: "",
                    range: 1...20
                )
            }
            
            HStack(spacing: 16) {
                MeasureItem(
                    icon: .space,
                    title: "Rooms",
                    value: $rooms,
                    suffix: "",
                    range: 1...20
                )
                
                MeasureItem(
                    icon: .space,
                    title: "Max People",
                    value: $capacity,
                    suffix: "",
                    range: 1...50
                )
                
                Spacer()
            }
        }
    }
}

private struct AreaInputItem: View {
    let icon: AppIcons
    let title: String
    @Binding var text: String
    let suffix: String
    
    var focusedField: FocusState<CreateView.FormField?>.Binding
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                Image.appIcon(icon)
                    .foregroundColor(Color.app.primaryVariant)
                    .font(.system(size: 12))
                
                Text(title)
                    .font(.app.latoRegular(size: 10))
                    .foregroundColor(Color.app.textFade)
            }
            
            HStack(spacing: 4) {
                TextField("0", text: $text)
                    .keyboardType(.numberPad)
                    .font(.app.latoBold(size: 14))
                    .foregroundColor(Color.app.textPrimary)
                    .multilineTextAlignment(.center)
                    .focused(focusedField, equals: .area) 
                    .frame(minWidth: 40)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(Color.white)
                    .cornerRadius(6)
                
                Text(suffix)
                    .font(.app.latoRegular(size: 12))
                    .foregroundColor(Color.app.textFade)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color.app.accentLight)
        .cornerRadius(12)
    }
}

// MeasureItem stays the same...
private struct MeasureItem: View {
    let icon: AppIcons
    let title: String
    @Binding var value: Double
    let suffix: String
    let range: ClosedRange<Double>
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                Image.appIcon(icon)
                    .foregroundColor(Color.app.primaryVariant)
                    .font(.system(size: 12))
                
                Text(title)
                    .font(.app.latoRegular(size: 10))
                    .foregroundColor(Color.app.textFade)
            }
            
            HStack(spacing: 8) {
                Button(action: { decrementValue() }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(Color.app.primaryVariant)
                        .font(.system(size: 16))
                }
                
                Text("\(Int(value))\(suffix)")
                    .font(.app.latoBold(size: 14))
                    .foregroundColor(Color.app.textPrimary)
                    .frame(minWidth: 40)
                
                Button(action: { incrementValue() }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(Color.app.primaryVariant)
                        .font(.system(size: 16))
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color.app.accentLight)
        .cornerRadius(12)
    }
    
    private func incrementValue() {
        if value < range.upperBound {
            value += 1
        }
    }
    
    private func decrementValue() {
        if value > range.lowerBound {
            value -= 1
        }
    }
}
