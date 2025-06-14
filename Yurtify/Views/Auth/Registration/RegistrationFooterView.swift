//
//  RegistrationFooterView.swift
//  Yurtify
//
//  Created by dark type on 15.06.2025.
//

import SwiftUI

struct RegistrationFooterView: View {
    @ObservedObject var viewModel: RegistrationViewModel
    let appRouter: AppRouter
    var body: some View {
        HStack {
            Text(L10n.Registration.alreadyHaveAccount)
                .foregroundColor(.app.textSecondary)

            Button(L10n.Login.button) {
                viewModel.navigateToLogin(appRouter: appRouter)
            }
            .foregroundColor(.textPrimary)
        }
        .font(.app.callout(.medium))
    }
}
