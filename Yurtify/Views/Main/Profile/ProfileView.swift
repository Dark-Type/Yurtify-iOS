//
//  ProfileView.swift
//  Yurtify
//
//  Created by dark type on 14.06.2025.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var appRouter: AppRouter
    @StateObject private var viewModel = ProfileViewModel()
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            Group {
                if authManager.isAuthenticated {
                    userProfileContent
                } else {
                    SuggestAccountView()
                }
            }
            .navigationTitle(L10n.TabBar.profile)
            .navigationDestination(for: UnifiedPropertyModel.self) { offer in
                OfferDetailView(property: offer, onDismiss: {
                    navigationPath.removeLast()
                })
            }
        }
        .confirmationDialog(
            "L10n.Profile.logoutConfirmationTitle",
            isPresented: $viewModel.showingLogoutConfirmation,
            titleVisibility: .visible
        ) {
            Button("L10n.Profile.logoutConfirm", role: .destructive) {
                viewModel.logout(authManager: authManager, appRouter: appRouter)
            }
            Button("L10n.Profile.cancel", role: .cancel) {
                viewModel.cancelLogout()
            }
        } message: {
            Text("L10n.Profile.logoutConfirmationMessage")
        }
    }
    
    private var userProfileContent: some View {
        VStack(spacing: 0) {
            userHeaderSection
            
            sectionTabsView
            
            ScrollView {
                VStack(spacing: 20) {
                    switch viewModel.selectedSectionIndex {
                    case 0:
                        favoritesSection
                    case 1:
                        myPropertiesSection
                    case 2:
                        bookingHistorySection
                    case 3:
                        accountSettingsSection
                    default:
                        EmptyView()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
                .padding(.top, 12)
            }
            .background(Color.app.base.edgesIgnoringSafeArea(.bottom))
        }
        .background(Color.app.base)
    }
    
    // MARK: - User Header Section
    
    private var userHeaderSection: some View {
        VStack(spacing: 16) {
            if let user = authManager.currentUser {
                HStack(spacing: 16) {
                    Circle()
                        .fill(.primaryVariant)
                        .frame(width: 80, height: 80)
                        .overlay(
                            Text(viewModel.getUserInitials(user: user))
                                .font(.app.title3(.bold))
                                .foregroundColor(.white)
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.getFullName(user: user))
                            .font(.app.headline())
                            .foregroundColor(.app.textPrimary)
                        
                        if let patronymic = user.patronymic, !patronymic.isEmpty {
                            Text(patronymic)
                                .font(.app.subheadline())
                                .foregroundColor(.app.textSecondary)
                        }
                        
                        Text(user.phoneNumber)
                            .font(.app.footnote())
                            .foregroundColor(.app.textSecondary)
                        
                        if let email = user.email, !email.isEmpty {
                            Text(email)
                                .font(.app.footnote())
                                .foregroundColor(.app.textSecondary)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
        }
        .background(Color.app.base)
    }
    
    // MARK: - Section Tabs
    
    private var sectionTabsView: some View {
        HStack(spacing: 0) {
            ForEach(0 ..< 4, id: \.self) { index in
                let titles = [L10n.Profile.favorite, "Сдаваемые", "История", "Настройки"]
                
                Button(action: {
                    withAnimation {
                        viewModel.selectedSectionIndex = index
                    }
                }) {
                    VStack(spacing: 8) {
                        Text(titles[index])
                            .font(.app.subheadline())
                            .foregroundColor(viewModel.selectedSectionIndex == index ? .app.primaryVariant : .app.textFade)
                            .lineLimit(1)
                            .minimumScaleFactor(0.4)
                            .frame(maxWidth: .infinity)
                        
                        Rectangle()
                            .fill(viewModel.selectedSectionIndex == index ? Color.app.primaryVariant : Color.app.textFade.opacity(0.3))
                            .frame(height: 2)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.top, 8)
        .padding(.horizontal)
        .background(Color.app.base)
        .shadow(color: Color.black.opacity(0.05), radius: 2, y: 2)
    }
    
    // MARK: - Favorites Section
    
    private var favoritesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Favorite Properties")
                .font(.app.title3())
                .foregroundColor(.app.textPrimary)
                .padding(.top, 8)
            
            if viewModel.favoriteOffers.isEmpty {
                emptyStateView("No favorite properties yet", "Heart your favorite listings to save them here")
            } else {
                VStack(spacing: 16) {
                    ForEach(viewModel.favoriteOffers) { offer in
                        Button(action: {
                            navigationPath.append(offer)
                        }) {
                            OfferView(property: offer)
                                .background(Color.app.base)
                                .cornerRadius(12)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
        .background(Color.app.base)
    }

    // MARK: - My Properties Section
    
    private var myPropertiesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("My Properties")
                .font(.app.title3())
                .foregroundColor(.app.textPrimary)
                .padding(.top, 8)
            
            if viewModel.ownedOffers.isEmpty {
                emptyStateView("You don't have any properties", "Add a property to start hosting")
            } else {
                VStack(spacing: 16) {
                    ForEach(viewModel.ownedOffers) { offer in
                        Button(action: {
                            navigationPath.append(offer)
                        }) {
                            OfferView(property: offer)
                                .background(Color.app.base)
                                .cornerRadius(12)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
        .background(Color.app.base)
    }
    
    // MARK: - Booking History Section
    
    private var bookingHistorySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Booking History")
                .font(.app.title3())
                .foregroundColor(.app.textPrimary)
                .padding(.top, 8)
            
            if viewModel.bookingHistory.isEmpty {
                emptyStateView("No booking history", "Your past bookings will appear here")
            } else {
                VStack(spacing: 16) {
                    ForEach(viewModel.bookingHistory) { offer in
                        Button(action: {
                            navigationPath.append(offer)
                        }) {
                            OfferView(property: offer)
                                .background(Color.app.base)
                                .cornerRadius(12)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
        .background(Color.app.base)
    }
    
    // MARK: - Account Settings Section
    
    private var accountSettingsSection: some View {
        VStack(spacing: 24) {
            VStack(spacing: 0) {
                ProfileActionRow(
                    icon: "person.circle",
                    title: "L10n.Profile.editProfile",
                    action: viewModel.editProfile
                )
                
                ProfileDivider()
                
                ProfileActionRow(
                    icon: "key",
                    title: "L10n.Profile.changePassword",
                    action: viewModel.changePassword
                )
            }
            .background(Color.app.base)
            .cornerRadius(12)
            
            VStack(spacing: 0) {
                ProfileActionRow(
                    icon: "bell",
                    title: "L10n.Profile.notifications",
                    action: viewModel.showNotificationSettings
                )
                
                ProfileDivider()
                
                ProfileActionRow(
                    icon: "questionmark.circle",
                    title: "L10n.Profile.help",
                    action: viewModel.showHelp
                )
                
                ProfileDivider()
                
                ProfileActionRow(
                    icon: "info.circle",
                    title: "L10n.Profile.about",
                    action: viewModel.showAbout
                )
                
                ProfileDivider()
                
                ProfileActionRow(
                    icon: "rectangle.portrait.and.arrow.right",
                    title: "L10n.Profile.signOut",
                    titleColor: .red,
                    isLoading: viewModel.isLoading,
                    action: viewModel.confirmLogout
                )
            }
            .background(Color.app.base)
            .cornerRadius(12)
        }
        .background(Color.app.base)
    }
    
    // MARK: - Empty State View
    
    private func emptyStateView(_ title: String, _ message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "square.stack.3d.up.slash")
                .font(.system(size: 50))
                .foregroundColor(.app.textFade)
                .padding(.bottom, 8)
            
            Text(title)
                .font(.app.headline())
                .foregroundColor(.app.textPrimary)
            
            Text(message)
                .font(.app.subheadline())
                .foregroundColor(.app.textFade)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 50)
        .background(Color.app.base)
    }
}
