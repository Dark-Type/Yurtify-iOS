//
//  MainTabView.swift
//  Yurtify
//
//  Created by dark type on 14.06.2025.
//
import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var authCoordinator: AuthPresentationManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ListView()
                .environmentObject(authCoordinator)
                .tabItem {
                    Image.appIcon(selectedTab == 0 ? .listSelected : .listUnselected)
                    Text(L10n.TabBar.list)
                }
                .tag(0)
            
            MapView()
                .environmentObject(authCoordinator)
                .tabItem {
                    Image.appIcon(selectedTab == 1 ? .mapSelected : .mapUnselected)
                    Text(L10n.TabBar.map)
                }
                .tag(1)
            
            if authManager.isLoggedIn {
                CreateView()
                    .environmentObject(authCoordinator)
                    .tabItem {
                        Image("plus.circle")
                        Text(L10n.TabBar.create)
                    }
                    .tag(2)
            }
            
            NotificationsView()
                .environmentObject(authCoordinator)
                .tabItem {
                    Image.appIcon(selectedTab == 3 ? .notificationsSelected : .notificationsUnselected)
                    Text(L10n.TabBar.notifications)
                }
                .tag(3)
            
            ProfileView()
                .environmentObject(authCoordinator)
                .tabItem {
                    Image.appIcon(selectedTab == 4 ? .profileSelected : .profileUnselected)
                    Text(L10n.TabBar.profile)
                }
                .tag(4)
        }
    }
}
