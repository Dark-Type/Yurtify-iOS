//
//  WelcomeView.swift
//  Yurtify
//
//  Created by dark type on 14.06.2025.
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var appRouter: AppRouter
    @StateObject private var viewModel = WelcomeViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: WelcomeMetrics.spacing(for: geometry)) {
                Spacer()
                
                WelcomeContentView(geometry: geometry)
                
                Spacer()
                
                WelcomeActionButtons(
                    viewModel: viewModel,
                    authManager: authManager,
                    appRouter: appRouter,
                    geometry: geometry
                )
            }
            .padding(.horizontal, WelcomeMetrics.padding(for: geometry))
            .padding(.bottom, 40)
            .background(.base)
        }
    }
}
