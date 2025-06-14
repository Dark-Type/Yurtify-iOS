//
//  ProfileActionRow.swift
//  Yurtify
//
//  Created by dark type on 15.06.2025.
//

import SwiftUI

struct ProfileActionRow: View {
    let icon: String
    let title: String
    let titleColor: Color
    let isLoading: Bool
    let action: () -> Void

    init(
        icon: String,
        title: String,
        titleColor: Color = .app.textPrimary,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.titleColor = titleColor
        self.isLoading = isLoading
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(titleColor == .red ? .red : .primaryVariant)
                    .frame(width: 28)

                Text(title)
                    .font(.app.body(.medium))
                    .foregroundColor(titleColor)

                Spacer()

                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: titleColor == .red ? .red : .primaryVariant))
                        .scaleEffect(0.8)
                } else if titleColor != .red {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.app.textSecondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isLoading)
    }
}

struct ProfileDivider: View {
    var body: some View {
        Divider()
            .padding(.leading, 44)
    }
}
