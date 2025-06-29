//
//  PosterSelectionSheet.swift
//  Yurtify
//
//  Created by dark type on 29.06.2025.
//

import SwiftUI

struct PosterSelectionSheet: View {
    let galleryImages: [PropertyImage]
    let onSelectFromGallery: (PropertyImage) -> Void
    let onSelectFromLibrary: () -> Void
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Image(systemName: "photo.badge.checkmark")
                        .font(.system(size: 50))
                        .foregroundColor(Color.app.primaryVariant)
                    
                    Text("Choose Poster Image")
                        .font(.app.latoBold(size: 20))
                        .foregroundColor(Color.app.textPrimary)
                    
                    Text("Select a poster image that will represent your property in listings")
                        .font(.app.latoRegular(size: 14))
                        .foregroundColor(Color.app.textFade)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                if !galleryImages.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Choose from uploaded images")
                            .font(.app.latoBold(size: 16))
                            .foregroundColor(Color.app.textPrimary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(galleryImages) { image in
                                    Button(action: {
                                        onSelectFromGallery(image)
                                        isPresented = false
                                    }) {
                                        Image(uiImage: image.image)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 120, height: 120)
                                            .clipped()
                                            .cornerRadius(12)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.app.primaryVariant.opacity(0.3), lineWidth: 2)
                                            )
                                    }
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                    }
                    
                    Text("or")
                        .font(.app.latoRegular(size: 14))
                        .foregroundColor(Color.app.textFade)
                }
                
                Button(action: {
                    onSelectFromLibrary()
                    isPresented = false
                }) {
                    HStack {
                        Image(systemName: "photo.on.rectangle")
                        Text("Choose from Photo Library")
                    }
                    .font(.app.latoBold(size: 16))
                    .foregroundColor(Color.app.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.app.primaryVariant)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Poster Image")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Cancel") {
                isPresented = false
            })
        }
    }
}
