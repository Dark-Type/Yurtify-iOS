//
//  UserProfileSheetView.swift
//  Yurtify
//
//  Created by dark type on 25.06.2025.
//

import SwiftUI

struct CompactUserProfileView: View {
    let userContacts: UserContacts
    @State private var showingCallConfirmation = false
    @State private var showingEmailConfirmation = false
    @State private var copyFeedback = ""
    @State private var showingCopyFeedback = false
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                userContacts.image
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 56, height: 56)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(userContacts.fullName)
                        .font(.app.headline())
                        .foregroundColor(AppColors.textPrimary)
                }
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                HStack(spacing: 8) {
                    AppIcons.mail.image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 16, height: 16)
                        .foregroundColor(AppColors.primaryVariant)
                    
                    Text(userContacts.email)
                        .font(.app.footnote())
                        .foregroundColor(AppColors.textPrimary)
                        .contextMenu {
                            Button(action: {
                                showingEmailConfirmation = true
                            }) {
                                Label("Send Email", systemImage: "envelope")
                            }
                            
                            Button(action: {
                                UIPasteboard.general.string = userContacts.email
                                copyFeedback = "Email copied!"
                                showingCopyFeedback = true
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    showingCopyFeedback = false
                                }
                            }) {
                                Label("Copy Email", systemImage: "doc.on.doc")
                            }
                        }
                        .onTapGesture {
                            UIPasteboard.general.string = userContacts.email
                            copyFeedback = "Email copied!"
                            showingCopyFeedback = true
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                showingCopyFeedback = false
                            }
                        }
                    
                    Spacer()
                }
                
                HStack(spacing: 8) {
                    AppIcons.phone.image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 16, height: 16)
                        .foregroundColor(AppColors.primaryVariant)
                    
                    Text(userContacts.phoneNumber)
                        .font(.app.footnote())
                        .foregroundColor(AppColors.textPrimary)
                        .contextMenu {
                            Button(action: {
                                showingCallConfirmation = true
                            }) {
                                Label("Call", systemImage: "phone")
                            }
                            
                            Button(action: {
                                UIPasteboard.general.string = userContacts.phoneNumber
                                copyFeedback = "Phone number copied!"
                                showingCopyFeedback = true
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    showingCopyFeedback = false
                                }
                            }) {
                                Label("Copy Number", systemImage: "doc.on.doc")
                            }
                        }
                        .onTapGesture {
                            UIPasteboard.general.string = userContacts.phoneNumber
                            copyFeedback = "Phone number copied!"
                            showingCopyFeedback = true
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                showingCopyFeedback = false
                            }
                        }
                    
                    Spacer()
                }
            }
            
            if showingCopyFeedback {
                Text(copyFeedback)
                    .font(.app.caption1())
                    .foregroundColor(.white)
                    .padding(6)
                    .background(AppColors.accentDark)
                    .cornerRadius(4)
                    .transition(.opacity)
                    .animation(.easeInOut, value: showingCopyFeedback)
            }
        }
        .padding(16)
        .frame(width: 280)
        .background(AppColors.base)
        .confirmationDialog("Call \(userContacts.fullName)?", isPresented: $showingCallConfirmation) {
            Button("Call \(userContacts.phoneNumber)") {
                makePhoneCall(userContacts.phoneNumber)
            }
        }
        .confirmationDialog("Email \(userContacts.fullName)?", isPresented: $showingEmailConfirmation) {
            Button("Email \(userContacts.email)") {
                sendEmail(userContacts.email)
            }
        }
    }
    
    private func makePhoneCall(_ phoneNumber: String) {
        if let url = URL(string: "tel://\(phoneNumber.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: ""))"),
           UIApplication.shared.canOpenURL(url)
        {
            UIApplication.shared.open(url)
        }
    }
    
    private func sendEmail(_ email: String) {
        if let url = URL(string: "mailto:\(email)"),
           UIApplication.shared.canOpenURL(url)
        {
            UIApplication.shared.open(url)
        }
    }
}
