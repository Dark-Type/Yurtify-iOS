//
//  RegistrationView.swift
//  Yurtify
//
//  Created by dark type on 14.06.2025.
//

import SwiftUI

struct RegistrationView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var appRouter: AppRouter
    @StateObject private var viewModel = RegistrationViewModel()

    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                ScrollView {
                    VStack(spacing: RegistrationMetrics.contentSpacing(for: geometry)) {
                        RegistrationContentView(
                            viewModel: viewModel,
                            authManager: authManager,
                            geometry: geometry
                        )

                        RegistrationFooterView(
                            viewModel: viewModel,
                            appRouter: appRouter
                        )
                    }
                    .padding(.horizontal, RegistrationMetrics.horizontalPadding(for: geometry))
                    .padding(.vertical, RegistrationMetrics.verticalPadding(for: geometry))
                }
                .background(.base)
                .navigationTitle(L10n.Registration.title)
                .navigationBarTitleDisplayMode(.large)
                .navigationTitleColor(.textPrimary) 
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { viewModel.navigateToWelcome(appRouter: appRouter) }) {
                            Image.appIcon(.goBackButton)
                                .foregroundColor(.textPrimary)
                        }
                    }
                }
            }
        }
    }
}
