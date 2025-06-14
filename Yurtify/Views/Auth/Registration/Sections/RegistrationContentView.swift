//
//  RegistrationContentView.swift
//  Yurtify
//
//  Created by dark type on 15.06.2025.
//

import SwiftUI

struct RegistrationContentView: View {
    @ObservedObject var viewModel: RegistrationViewModel
    let authManager: AuthManager
    let geometry: GeometryProxy
    
    var body: some View {
        VStack(spacing: RegistrationMetrics.sectionSpacing(for: geometry)) {
            logoSection
            textFieldsSection
            submitButton
            errorSection
        }
    }
    
    // MARK: - Subviews
    
    private var logoSection: some View {
        Image.appIcon(.logo)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: RegistrationMetrics.logoHeight(for: geometry))
    }
    
    private var textFieldsSection: some View {
        VStack(spacing: RegistrationMetrics.textFieldSpacing(for: geometry)) {
            RegistrationTextField(
                placeholder: L10n.Registration.name,
                text: $viewModel.name,
                keyboardType: .default
            )
            
            RegistrationTextField(
                placeholder: L10n.Registration.surname,
                text: $viewModel.surname,
                keyboardType: .default
            )
            
            RegistrationTextField(
                placeholder: L10n.Registration.patronymic,
                text: $viewModel.patronymic,
                keyboardType: .default
            )
            
            RegistrationTextField(
                placeholder: L10n.Registration.phone,
                text: $viewModel.phoneNumber,
                keyboardType: .phonePad
            )
            
            RegistrationTextField(
                placeholder: L10n.Registration.email,
                text: $viewModel.email,
                keyboardType: .emailAddress
            )
            
            RegistrationSecureField(
                placeholder: L10n.Registration.password,
                text: $viewModel.password
            )
            
            RegistrationSecureField(
                placeholder: L10n.Registration.confirmation,
                text: $viewModel.confirmation
            )
        }
    }
    
    private var submitButton: some View {
        Button(action: { viewModel.register(authManager: authManager) }) {
            HStack {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Text(L10n.Registration.button)
                }
            }
            .font(.app.headline(.semiBold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, RegistrationMetrics.buttonPadding(for: geometry))
            .background(viewModel.isFormValid ? .primaryVariant : .gray)
            .cornerRadius(12)
            .contentShape(Rectangle()) 
        }
        .disabled(!viewModel.isFormValid || viewModel.isLoading)
        .animation(.easeInOut(duration: 0.2), value: viewModel.isFormValid)
    }

    @ViewBuilder
    private var errorSection: some View {
        if let errorMessage = viewModel.errorMessage {
            Text(errorMessage)
                .font(.app.caption1(.medium))
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}
