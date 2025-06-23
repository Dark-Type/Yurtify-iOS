//
//  MeasureType.swift
//  Yurtify
//
//  Created by dark type on 23.06.2025.
//

import SwiftUI

enum MeasureType {
    case area
    case beds
    case bathrooms
    case capacity
    
    var icon: AppIcons {
        switch self {
        case .area: return .space
        case .beds: return .bed
        case .bathrooms: return .bath
        case .capacity: return .place
        }
    }
    
    func formatValue(_ value: Double) -> String {
        switch self {
        case .area:
            return L10n.Measures.formatArea(value)
        case .beds:
            return L10n.Measures.formatBeds(Int(value))
        case .bathrooms:
            return L10n.Measures.formatBathrooms(Int(value))
        case .capacity:
            return L10n.Measures.formatCapacity(Int(value))
        }
    }
    
    var keyboardType: UIKeyboardType {
        switch self {
        case .area:
            return .decimalPad
        default:
            return .numberPad
        }
    }
    
    var allowsDecimal: Bool {
        switch self {
        case .area:
            return true
        default:
            return false
        }
    }
}

struct MeasureInputView: View {
    // MARK: - Properties

    let measureType: MeasureType
    let width: CGFloat
    let height: CGFloat
    @Binding var value: Double
    @State private var isEditing = false
    @State private var inputText = ""
    @State private var showError = false
    @State private var hasBeenValidated = false
    
    // MARK: - Body

    var body: some View {
        ZStack {
            Button(action: {
                startEditing()
            }) {
                VStack(spacing: 8) {
                    Image.appIcon(measureType.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(showError ? .red : .textPrimary)
                    
                    Text(measureType.formatValue(value))
                        .font(.app.poppinsMedium(size: 12))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(showError ? .red : .textPrimary)
                }
                .frame(width: width, height: height)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.accentLight))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(showError ? Color.red : (hasBeenValidated ? Color.primaryVariant : Color.clear), lineWidth: 2)
                        )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            }
            .buttonStyle(ScaleButtonStyle())
            .modifier(ShakeEffect(shaking: showError))
            
            if isEditing {
                TextField("", text: $inputText)
                    .keyboardType(measureType.keyboardType)
                    .font(.app.poppinsMedium(size: 16))
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color(.accentLight).opacity(0.9))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(Color.primaryVariant, lineWidth: 2)
                    )
                    .shadow(radius: 5)
                    .onAppear {
                        if measureType.allowsDecimal {
                            let formatter = NumberFormatter()
                            formatter.locale = Locale.current
                            formatter.numberStyle = .decimal
                            formatter.maximumFractionDigits = 1
                            if L10n.isRussian || L10n.isKyrgyz {
                                formatter.decimalSeparator = ","
                            }
                            inputText = formatter.string(from: NSNumber(value: value)) ?? "\(value)"
                        } else {
                            inputText = "\(Int(value))"
                        }
                    }
                    .onSubmit {
                        submitValue()
                    }
                    .onChange(of: inputText) { newValue in
                        let filteredText = filterInput(newValue)
                        if filteredText != newValue {
                            inputText = filteredText
                        }
                    }
            }
        }
    }
    
    // MARK: - Methods

    private func startEditing() {
        withAnimation {
            isEditing = true
        }
        
        if showError {
            withAnimation {
                showError = false
            }
        }
    }
    
    private func submitValue() {
        let cleanedText = inputText
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: ",", with: ".")
        
        if let newValue = Double(cleanedText), newValue > 0 {
            withAnimation {
                value = measureType.allowsDecimal ? newValue : Double(Int(newValue))
                hasBeenValidated = true
                showError = false
            }
        } else {
            withAnimation(.default) {
                showError = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation {
                        showError = false
                    }
                }
            }
        }
        
        withAnimation {
            isEditing = false
        }
    }
    
    private func filterInput(_ input: String) -> String {
        let allowedChars = measureType.allowsDecimal ? "0123456789,." : "0123456789"
        
        var filtered = input.filter { allowedChars.contains($0) }
        
        if measureType.allowsDecimal {
            let decimalCount = filtered.filter { $0 == "." || $0 == "," }.count
            if decimalCount > 1 {
                if let firstDecimalIndex = filtered.firstIndex(where: { $0 == "." || $0 == "," }) {
                    let afterFirstDecimal = filtered[filtered.index(after: firstDecimalIndex)...]
                    filtered = String(filtered[...firstDecimalIndex]) +
                        String(afterFirstDecimal.filter { $0 != "." && $0 != "," })
                }
            }
            
            if L10n.isRussian || L10n.isKyrgyz {
                filtered = filtered.replacingOccurrences(of: ".", with: ",")
            } else {
                filtered = filtered.replacingOccurrences(of: ",", with: ".")
            }
        }
        
        return filtered
    }
}

// MARK: - Shake Animation for Error State

struct ShakeEffect: ViewModifier {
    var shaking: Bool
    @State private var animatableParameter: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .offset(x: shaking ? sin(animatableParameter * .pi * 10) * 5 : 0)
            .animation(
                shaking ?
                    Animation.easeInOut(duration: 0.5)
                    .repeatCount(2, autoreverses: true) :
                    .default,
                value: shaking
            )
            .onChange(of: shaking) { newValue in
                if newValue {
                    withAnimation {
                        animatableParameter = 1
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation {
                            animatableParameter = 0
                        }
                    }
                }
            }
    }
}
