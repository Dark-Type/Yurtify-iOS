//
//  RequireLoginView.swift
//  Yurtify
//
//  Created by dark type on 14.06.2025.
//

import SwiftUI

struct RequireLoginView: View {
    let feature: String
    let onGoToProfile: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                
                loginPrompt
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .background(.base)
            .navigationTitle(feature)
        }
    }
    
    private var loginPrompt: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.badge.exclamationmark")
                .font(.system(size: 80))
                .foregroundColor(.app.textSecondary)
            
            Text("Sign in required")
                .font(.app.title2(.semiBold))
                .foregroundColor(.app.textPrimary)
            
            Text("You need to be signed in to access \(feature.lowercased()). Go to your profile to sign in or create an account.")
                .font(.app.body(.regular))
                .foregroundColor(.app.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
            
            Button(action: onGoToProfile) {
                HStack(spacing: 8) {
                    Image(systemName: "person.circle")
                    Text("Go to Profile")
                }
                .font(.app.headline(.semiBold))
                .foregroundColor(.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(.secondaryVariant)
                .cornerRadius(12)
            }
        }
    }
}

#Preview {
    RequireLoginView(feature: "Notifications") {
        print("Go to profile tapped")
    }
}
