//
//  RootNavigationView.swift
//  Yurtify
//
//  Created by dark type on 14.06.2025.
//

import SwiftUI

struct RootNavigationView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var authCoordinator = AuthPresentationManager()

    var body: some View {
        mainContent
            .environmentObject(authCoordinator)
            .sheet(isPresented: $authCoordinator.isPresented) {
                AuthFlowView()
                    .environmentObject(authCoordinator)
            }
    }

    @ViewBuilder
    private var mainContent: some View {
        switch authManager.userState {
        case .firstLaunch:
            WelcomeView()
        case .loggedIn, .guest:
            MainTabView()
        case .loggedOut:
            WelcomeView()
        }
    }
}
