//
//  EditProfileSheet.swift
//  Yurtify
//
//  Created by dark type on 30.06.2025.
//

import PhotosUI
import SwiftUI

struct EditProfileSheet: View {
    @ObservedObject var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var surname: String = ""
    @State private var patronymic: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var profileImage: UIImage?
    
    @State private var isLoading = false
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var isProcessingImage = false
    @State private var showingImageSelection = false
    
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    profileImageSection
                    
                    personalInfoSection
                    
                    contactInfoSection
                    
                    Spacer(minLength: 50)
                }
                .padding()
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    saveProfile()
                }
                .disabled(isLoading)
            )
            .onAppear {
                loadCurrentUserData()
            }
            .confirmationDialog("Change Profile Picture", isPresented: $showingImageSelection) {
                Button("Camera") {
                    showingCamera = true
                }
                Button("Photo Library") {
                    showingImagePicker = true
                }
                Button("Cancel", role: .cancel) {}
            }
            .photosPicker(
                isPresented: $showingImagePicker,
                selection: $selectedPhotoItem,
                matching: .images
            )
            .fullScreenCover(isPresented: $showingCamera) {
                ImagePicker(
                    sourceType: .camera,
                    onImageSelected: { image in
                        profileImage = image
                        showingCamera = false
                    },
                    onCancel: {
                        showingCamera = false
                    }
                )
            }
            .background(Color.app.base)
            .onChange(of: selectedPhotoItem) { _ in
                processSelectedPhoto()
            }
            .alert("Update Profile", isPresented: $showingAlert) {
                Button("OK") {}
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private var profileImageSection: some View {
        VStack(spacing: 16) {
            Button(action: {
                showingImageSelection = true
            }) {
                ZStack {
                    if let profileImage = profileImage {
                        Image(uiImage: profileImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                    } else if let user = authManager.currentUser {
                        Circle()
                            .fill(Color.app.primaryVariant)
                            .frame(width: 120, height: 120)
                            .overlay(
                                Text("\(user.name.first?.uppercased() ?? "")\(user.surname.first?.uppercased() ?? "")")
                                    .font(.app.title1(.bold))
                                    .foregroundColor(.white)
                            )
                    }
                    
                    if isProcessingImage {
                        Circle()
                            .fill(Color.black.opacity(0.5))
                            .frame(width: 120, height: 120)
                            .overlay(
                                ProgressView()
                                    .tint(.white)
                            )
                    }
                    
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Circle()
                                .fill(Color.app.primaryVariant)
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(.white)
                                )
                                .offset(x: -8, y: -8)
                        }
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(isProcessingImage)
            
            Text("Tap to change profile picture")
                .font(.app.caption1())
                .foregroundColor(.app.textFade)
        }
    }
    
    private var personalInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Personal Information")
                .font(.app.headline())
                .foregroundColor(.app.textPrimary)
            
            VStack(spacing: 16) {
                CustomTextField(
                    title: "First Name",
                    text: $name,
                    placeholder: "Enter your first name"
                )
              
                CustomTextField(
                    title: "Last Name",
                    text: $surname,
                    placeholder: "Enter your last name"
                )
          
                CustomTextField(
                    title: "Patronymic (Optional)",
                    text: $patronymic,
                    placeholder: "Enter your patronymic"
                )
            }
        }
    }
    
    private var contactInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Contact Information")
                .font(.app.headline())
                .foregroundColor(.app.textPrimary)
            
            VStack(spacing: 16) {
                CustomTextField(
                    title: "Email",
                    text: $email,
                    placeholder: "Enter your email",
                    keyboardType: .emailAddress
                )
                
                CustomTextField(
                    title: "Phone Number",
                    text: $phone,
                    placeholder: "Enter your phone number",
                    keyboardType: .phonePad
                )
            }
        }
    }
    
    private func loadCurrentUserData() {
        guard let user = authManager.currentUser else { return }
        
        name = user.name
        surname = user.surname
        patronymic = user.patronymic ?? ""
        email = user.email ?? ""
        phone = user.phoneNumber
    }
    
    private func processSelectedPhoto() {
        guard let selectedPhotoItem = selectedPhotoItem else { return }
        
        isProcessingImage = true
        
        Task {
            do {
                if let data = try await selectedPhotoItem.loadTransferable(type: Data.self),
                   let image = UIImage(data: data)
                {
                    await MainActor.run {
                        self.profileImage = image
                        self.isProcessingImage = false
                        self.selectedPhotoItem = nil
                    }
                }
            } catch {
                await MainActor.run {
                    self.isProcessingImage = false
                    self.selectedPhotoItem = nil
                }
                print("Failed to process image: \(error)")
            }
        }
    }
    
    private func saveProfile() {
        guard validateForm() else { return }
        
        isLoading = true
        
        Task {
            do {
                try await Task.sleep(for: .seconds(2))
                
                await MainActor.run {
                    alertMessage = "Profile updated successfully!"
                    showingAlert = true
                    isLoading = false
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        dismiss()
                    }
                }
            } catch {
                await MainActor.run {
                    alertMessage = "Failed to update profile. Please try again."
                    showingAlert = true
                    isLoading = false
                }
            }
        }
    }
    
    private func validateForm() -> Bool {
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            alertMessage = "First name is required"
            showingAlert = true
            return false
        }
        
        if surname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            alertMessage = "Last name is required"
            showingAlert = true
            return false
        }
        
        if !email.isEmpty && !isValidEmail(email) {
            alertMessage = "Please enter a valid email address"
            showingAlert = true
            return false
        }
        
        return true
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}

struct CustomTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.app.subheadline(.semiBold))
                .foregroundColor(.app.textPrimary)
            
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
}
