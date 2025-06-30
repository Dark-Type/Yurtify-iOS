//
//  YurtifyApp.swift
//  Yurtify
//
//  Created by dark type on 14.06.2025.
//

import SwiftUI

@main
struct YurtifyApp: App {
    private let apiService = APIService()
    @StateObject private var authManager: AuthManager

    init() {
        let apiService = APIService()
        self._authManager = StateObject(wrappedValue: AuthManager(apiService: apiService))
    }

    var body: some Scene {
        WindowGroup {
            RootNavigationView()
                .environmentObject(authManager)
                .environmentObject(apiService)
        }
    }
}
