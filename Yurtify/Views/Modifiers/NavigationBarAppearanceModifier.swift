//
//  NavigationBarAppearanceModifier.swift
//  Yurtify
//
//  Created by dark type on 25.06.2025.
//

import SwiftUI

struct NavigationBarAppearanceModifier: ViewModifier {
    let backgroundColor: UIColor
    let titleColor: UIColor
    let tintColor: UIColor?
    
    init(backgroundColor: UIColor, titleColor: UIColor, tintColor: UIColor? = nil) {
        self.backgroundColor = backgroundColor
        self.titleColor = titleColor
        self.tintColor = tintColor ?? titleColor
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = backgroundColor
        appearance.titleTextAttributes = [.foregroundColor: titleColor]
        appearance.largeTitleTextAttributes = [.foregroundColor: titleColor]
        
        appearance.shadowColor = .clear
        appearance.shadowImage = UIImage()
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        UINavigationBar.appearance().tintColor = tintColor
    }
    
    func body(content: Content) -> some View {
        content
    }
}

extension View {
    func customNavigationBarAppearance(
        backgroundColor: Color = .white,
        titleColor: Color = .black,
        tintColor: Color? = nil
    ) -> some View {
        self.modifier(NavigationBarAppearanceModifier(
            backgroundColor: UIColor(backgroundColor),
            titleColor: UIColor(titleColor),
            tintColor: tintColor != nil ? UIColor(tintColor!) : nil
        ))
    }
}
