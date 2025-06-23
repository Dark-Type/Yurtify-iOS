//
//  MainTabView.swift
//  Yurtify
//
//  Created by dark type on 14.06.2025.
//
import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var appRouter: AppRouter
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            mainContent
            CustomTabBar(selectedTab: $selectedTab)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
    
    // MARK: - Main Content
    
    @ViewBuilder
    private var mainContent: some View {
        Group {
            switch selectedTab {
            case TabItem.list.tag: ListView()
            case TabItem.map.tag: MapView()
            case TabItem.create.tag: createTabContent
            case TabItem.notifications.tag: notificationsTabContent
            case TabItem.profile.tag: ProfileView().environmentObject(appRouter)
            default: ListView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Tab Content Builders
    
    @ViewBuilder
    private var createTabContent: some View {
        if authManager.isAuthenticated {
            CreateView()
        } else {
            RequireLoginView(feature: L10n.TabBar.create) {
                switchToProfileTab()
            }
        }
    }
    
    @ViewBuilder
    private var notificationsTabContent: some View {
        if authManager.isAuthenticated {
            NotificationsView()
        } else {
            RequireLoginView(feature: L10n.TabBar.notifications) {
                switchToProfileTab()
            }
        }
    }
    
    // MARK: - Tab Navigation
    
    private func switchToProfileTab() {
        selectedTab = TabItem.profile.tag
    }
}
