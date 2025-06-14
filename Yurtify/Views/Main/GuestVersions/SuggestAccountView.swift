//
//  SuggestAccountView.swift
//  Yurtify
//
//  Created by dark type on 14.06.2025.
//
import SwiftUI

struct SuggestAccountView: View {
    @EnvironmentObject var appRouter: AppRouter
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()
                
                accountPrompt
                
                Spacer()
                
                actionButtons
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
            .background(.base)
            .navigationTitle("Your Account")
        }
    }
    
    private var accountPrompt: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(.textPrimary)
            
            Text("Join Yurtify")
                .font(.title)
                .foregroundColor(.app.textPrimary)
            
            Text("Create an account to unlock all features, save your favorites, and get personalized recommendations.")
                .font(.app.body(.regular))
                .foregroundColor(.app.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 16) {
            Button(action: {
                appRouter.navigateToRegister()
            }) {
                Text("Create Account")
                    .font(.app.headline(.semiBold))
                    .foregroundColor(.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(.secondaryVariant)
                    .cornerRadius(12)
            }
            
            Button(action: {
                appRouter.navigateToLogin()
            }) {
                Text("Sign In")
                    .font(.app.headline(.semiBold))
                    .foregroundColor(.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(.base)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.secondaryVariant, lineWidth: 2)
                    )
            }
            
            VStack(spacing: 12) {
                HStack {
                    Rectangle()
                        .fill(.secondaryVariant)
                        .frame(height: 1)
                    
                    Text("What you'll get")
                        .font(.app.caption1(.medium))
                        .foregroundColor(.app.textSecondary)
                        .padding(.horizontal, 12)
                    
                    Rectangle()
                        .fill(.secondaryVariant)
                        .frame(height: 1)
                }
                
                VStack(spacing: 8) {
                    featureRow(icon: "heart.fill", text: "Save favorites")
                    featureRow(icon: "bell.fill", text: "Get notifications")
                    featureRow(icon: "plus.circle.fill", text: "Create listings")
                    featureRow(icon: "person.2.fill", text: "Connect with others")
                }
            }
            .padding(.top, 8)
        }
    }
    
    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.textPrimary)
                .frame(width: 20)
            
            Text(text)
                .font(.app.callout(.medium))
                .foregroundColor(.secondaryVariant)
            
            Spacer()
        }
    }
}

#Preview {
    SuggestAccountView()
        .environmentObject(AppRouter())
}
