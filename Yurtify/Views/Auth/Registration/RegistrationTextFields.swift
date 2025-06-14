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
        TextField(placeholder, text: $text)
            .font(.app.inter(size: 16, weight: .semiBold))
            .foregroundColor(.textFade)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.gray.opacity(0.3), lineWidth: 1)
            )
            .keyboardType(keyboardType)
            .autocapitalization(.none)
            .disableAutocorrection(true)
    }
}

struct RegistrationSecureField: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        SecureField(placeholder, text: $text)
            .font(.app.inter(size: 16, weight: .semiBold))
            .foregroundColor(.textFade)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.gray.opacity(0.3), lineWidth: 1)
            )
            .autocapitalization(.none)
            .disableAutocorrection(true)
    }
}
