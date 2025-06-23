//
//  TabBarItemView.swift
//  Yurtify
//
//  Created by dark type on 15.06.2025.
//

import SwiftUI

struct TabBarItemView: View {
    let item: TabItem
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: TabBarConstants.iconTextSpacing) {
                iconView
                textView
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Subviews

    private var iconView: some View {
        Image.appIcon(isSelected ? item.selectedIcon : item.unselectedIcon)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(
                width: TabBarConstants.iconSize * item.iconScale,
                height: TabBarConstants.iconSize * item.iconScale
            )
            .foregroundColor(isSelected ? .base : .secondaryVariant)
    }

    private var textView: some View {
        Text(item.title)
            .font(AppFonts.inter(size: TabBarConstants.fontSize, weight: .bold))
            .foregroundColor(isSelected ? .base : .secondaryVariant)
            .lineLimit(1)
    }
}
