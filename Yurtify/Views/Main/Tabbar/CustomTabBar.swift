//
//  CustomTabBar.swift
//  Yurtify
//
//  Created by dark type on 15.06.2025.
//

import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int

    private let tabItems = TabItem.allCases

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(tabItems, id: \.tag) { item in
                    TabBarItemView(
                        item: item,
                        isSelected: selectedTab == item.tag,
                        action: { selectedTab = item.tag }
                    )
                }
            }
            .padding(.top, TabBarConstants.topPadding)
            .padding(.bottom, TabBarConstants.bottomPadding)
            .padding(.horizontal, TabBarConstants.horizontalPadding)
            .background(.tabbar)
        }
    }
}
