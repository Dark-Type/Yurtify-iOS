//
//  ConvenienceView.swift
//  Yurtify
//
//  Created by dark type on 22.06.2025.
//

import SwiftUI


struct ConvenienceView: View {
    // MARK: - Properties
    let convenience: Convenience
    let width: CGFloat
    let height: CGFloat
    let isSelectable: Bool
    
    @Binding var isSelected: Bool
    init(convenience: Convenience, width: CGFloat, height: CGFloat) {
        self.convenience = convenience
        self.width = width
        self.height = height
        self.isSelectable = false
        self._isSelected = .constant(false)
    }
    
    init(convenience: Convenience, width: CGFloat, height: CGFloat, isSelected: Binding<Bool>) {
        self.convenience = convenience
        self.width = width
        self.height = height
        self.isSelectable = true
        self._isSelected = isSelected
    }
    
    // MARK: - Body
    var body: some View {
        Button(action: toggleSelection) {
            VStack(spacing: 8) {
                Image.appIcon(convenience.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(isSelected ? .primaryVariant : .textPrimary)
                
                Text(convenience.localizedName)
                    .font(.app.poppinsMedium(size: 10))
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
        .disabled(!isSelectable)
    }
    
    // MARK: - Actions
    private func toggleSelection() {
        if isSelectable {
            withAnimation(.easeInOut(duration: 0.2)) {
                isSelected.toggle()
            }
        }
    }
}

// MARK: - Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
