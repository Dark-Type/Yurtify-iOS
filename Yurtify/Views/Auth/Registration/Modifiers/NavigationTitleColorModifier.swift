//
//  NavigationTitleColorModifier.swift
//  Yurtify
//
//  Created by dark type on 15.06.2025.
//

import SwiftUI

struct NavigationTitleColorModifier: ViewModifier {
    let color: Color
    let font: UIFont?

    func body(content: Content) -> some View {
        content
            .onAppear {
                let appearance = UINavigationBarAppearance()
                appearance.configureWithTransparentBackground()

                var attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: UIColor(self.color)
                ]

                if let font = font {
                    attributes[.font] = font
                }

                appearance.largeTitleTextAttributes = attributes
                appearance.titleTextAttributes = attributes

                UINavigationBar.appearance().standardAppearance = appearance
                UINavigationBar.appearance().scrollEdgeAppearance = appearance
                UINavigationBar.appearance().compactAppearance = appearance
            }
    }
}

extension View {
    func navigationTitleColor(_ color: Color, font: UIFont? = nil) -> some View {
        self.modifier(NavigationTitleColorModifier(color: color, font: font))
    }
}
