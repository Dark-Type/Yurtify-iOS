//
//  YurtifyApp.swift
//  Yurtify
//
//  Created by dark type on 14.06.2025.
//

import SwiftUI

@main
struct YurtifyApp: App {
    @StateObject private var authManager = AuthManager()

    var body: some Scene {
        WindowGroup {
            RootNavigationView()
                .environmentObject(authManager)
                .onAppear {}
        }
    }
}
