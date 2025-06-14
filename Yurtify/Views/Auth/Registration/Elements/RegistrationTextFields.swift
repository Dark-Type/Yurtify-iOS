//
//  RegistrationTextField.swift
//  Yurtify
//
//  Created by dark type on 15.06.2025.
//

import SwiftUI

struct RegistrationTextField: View {
    let placeholder: String
    @Binding var text: String
    let keyboardType: UIKeyboardType

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .font(.app.inter(size: 16, weight: .semiBold))
                    .foregroundColor(.textPrimaryOpacity)
                    .padding(.horizontal, 16)
                    .allowsHitTesting(false)
            }

            TextField("", text: $text)
                .font(.app.inter(size: 16, weight: .semiBold))
                .foregroundColor(.textPrimaryOpacity)
                .padding(.horizontal, 16)
                .keyboardType(keyboardType)
                .autocapitalization(.none)
                .disableAutocorrection(true)
        }
        .padding(.vertical, 12)
        .background(.white)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

struct RegistrationSecureField: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .font(.app.inter(size: 16, weight: .semiBold))
                    .foregroundColor(.textPrimaryOpacity)
                    .padding(.horizontal, 16)
                    .allowsHitTesting(false)
            }

            SecureField("", text: $text)
                .font(.app.inter(size: 16, weight: .semiBold))
                .foregroundColor(.textPrimaryOpacity)
                .padding(.horizontal, 16)
                .autocapitalization(.none)
                .disableAutocorrection(true)
        }
        .padding(.vertical, 12)
        .background(.white)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.gray.opacity(0.3), lineWidth: 1)
        )
    }
}
