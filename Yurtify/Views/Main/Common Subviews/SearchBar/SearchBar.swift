//
//  SearchBar.swift
//  Yurtify
//
//  Created by dark type on 24.06.2025.
//

import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    var placeholder: String
    var onSearch: (() -> Void)?
    var onCancel: (() -> Void)?
    
    @FocusState private var isFocused: Bool
    @State private var isEditing = false
    @State private var previousText = ""
    
    var body: some View {
        HStack(spacing: 10) {
            HStack {
                Image.appIcon(.search)
                    .foregroundColor(isFocused ? .app.primaryVariant : .app.textFade)
                    .animation(.easeInOut, value: isFocused)
                
                TextField(placeholder, text: $text)
                    .font(.app.body())
                    .foregroundColor(.app.textPrimary)
                    .focused($isFocused)
                    .onChange(of: text) { newValue in
                        if previousText != newValue {
                            previousText = newValue
                            onSearch?()
                        }
                    }
                    .onSubmit {
                        onSearch?()
                    }
                
                if !text.isEmpty {
                    Button(action: {
                        text = ""
                        onSearch?()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.app.textFade)
                            .padding(4)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
            )
            .animation(.easeInOut(duration: 0.2), value: isFocused)
            
            if isFocused {
                Button("Cancel") {
                    text = ""
                    isFocused = false
                    onCancel?()
                }
                .foregroundColor(.app.primaryVariant)
                .font(.app.body())
                .transition(.move(edge: .trailing).combined(with: .opacity))
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                )
            }
        }
        .padding(.horizontal)
        .animation(.easeInOut(duration: 0.2), value: isFocused)
        .onAppear {
            previousText = text
        }
    }
}
