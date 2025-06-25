//
//  HorizontalSectionSelector.swift
//  Yurtify
//
//  Created by dark type on 26.06.2025.
//

import SwiftUI

struct HorizontalSectionSelector<Content: View>: View {
    @Binding var selectedIndex: Int
    let titles: [String]
    let content: Content
    
    init(selectedIndex: Binding<Int>, titles: [String], @ViewBuilder content: () -> Content) {
        self._selectedIndex = selectedIndex
        self.titles = titles
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(0 ..< titles.count, id: \.self) { index in
                    Button(action: {
                        withAnimation {
                            selectedIndex = index
                        }
                    }) {
                        VStack(spacing: 8) {
                            Text(titles[index])
                                .font(.app.headline())
                                .foregroundColor(selectedIndex == index ? .app.primaryVariant : .app.textFade)
                                .frame(maxWidth: .infinity)
                            
                            Rectangle()
                                .fill(selectedIndex == index ? Color.app.primaryVariant : Color.app.textFade.opacity(0.3))
                                .frame(height: 2)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
            
            content
                .frame(maxWidth: .infinity)
        }
    }
}
