//
//  CreateView.swift
//  Yurtify
//
//  Created by dark type on 14.06.2025.
//

import SwiftUI

struct CreateView: View {
    // MARK: - Properties

    @StateObject private var viewModel = CreateViewModel()
    @FocusState private var focusedField: FormField?
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isShowingSuccessView = false
    
    enum FormField: Hashable {
        case name
        case description
        case price
    }
    
    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                basicDetailsSection
                
                propertyTypeSection
                
                measurementsSection
                
                priceSection
                
                locationSection
                
                conveniencesSection
                
                submitButton
            }
            .padding()
        }
        .navigationTitle("Create Listing")
        .onTapGesture {
            focusedField = nil
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Message"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .fullScreenCover(isPresented: $isShowingSuccessView) {
            successView
        }
    }
    
    // MARK: - Sections
    
    private var basicDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Basic Details")
                .font(.app.latoBold(size: 20))
                .foregroundColor(Color.app.textPrimary)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Property Name")
                    .font(.app.latoRegular(size: 14))
                    .foregroundColor(Color.app.textFade)
                
                TextField("Enter property name", text: $viewModel.property.name)
                    .font(.app.latoRegular(size: 16))
                    .foregroundColor(Color.app.textPrimary)
                    .padding()
                    .background(Color.app.accentLight)
                    .cornerRadius(12)
                    .focused($focusedField, equals: .name)
                    .modifier(ShakeEffect(shaking: viewModel.invalidFields.contains(.name)))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(viewModel.invalidFields.contains(.name) ? Color.red : Color.clear, lineWidth: 1)
                    )
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Description")
                    .font(.app.latoRegular(size: 14))
                    .foregroundColor(Color.app.textFade)
                
                TextEditor(text: $viewModel.property.description)
                    .frame(minHeight: 120)
                    .font(.app.latoRegular(size: 16))
                    .foregroundColor(Color.app.textPrimary)
                    .padding(4)
                    .background(Color.app.accentLight)
                    .cornerRadius(12)
                    .focused($focusedField, equals: .description)
                    .modifier(ShakeEffect(shaking: viewModel.invalidFields.contains(.description)))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(viewModel.invalidFields.contains(.description) ? Color.red : Color.clear, lineWidth: 1)
                    )
            }
        }
    }
    
    private var propertyTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.Detail.PropertyType.title)
                .font(.app.latoBold(size: 18))
                .foregroundColor(Color.app.textPrimary)
            
            AdaptivePropertyTypeRow(selectedType: $viewModel.selectedPropertyType)
                .frame(height: 140)
                .modifier(ShakeEffect(shaking: viewModel.invalidFields.contains(.propertyType)))
        }
    }
    
    private var measurementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Property Specifications")
                .font(.app.latoBold(size: 18))
                .foregroundColor(Color.app.textPrimary)
            
            MeasuresRow(
                area: $viewModel.area,
                beds: $viewModel.beds,
                bathrooms: $viewModel.bathrooms,
                capacity: $viewModel.capacity
            )
            .frame(height: 110)
        }
    }
    
    private var priceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Price")
                .font(.app.latoBold(size: 18))
                .foregroundColor(Color.app.textPrimary)
            
            HStack {
                TextField("Enter price", text: $viewModel.priceText)
                    .keyboardType(.decimalPad)
                    .font(.app.latoRegular(size: 16))
                    .foregroundColor(Color.app.textPrimary)
                    .padding()
                    .background(Color.app.accentLight)
                    .cornerRadius(12)
                    .focused($focusedField, equals: .price)
                    .modifier(ShakeEffect(shaking: viewModel.invalidFields.contains(.price)))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(viewModel.invalidFields.contains(.price) ? Color.red : Color.clear, lineWidth: 1)
                    )
                
                Picker("Period", selection: $viewModel.property.pricePeriod) {
                    ForEach(L10n.Measures.Price.allCases, id: \.self) { period in
                        Text(period.localized)
                            .tag(period)
                            .foregroundColor(Color.app.textPrimary)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                .background(Color.app.accentLight)
                .cornerRadius(12)
                .accentColor(Color.app.primaryVariant)
            }
        }
    }
    
    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Location")
                .font(.app.latoBold(size: 18))
                .foregroundColor(Color.app.textPrimary)
            
            LocationPickerView(address: $viewModel.property.address)
                .modifier(ShakeEffect(shaking: viewModel.invalidFields.contains(.location)))
        }
    }
    
    private var conveniencesSection: some View {
        VStack {
            ForEach(Convenience.Group.allCases, id: \.self) { group in
                VStack(alignment: .leading, spacing: 12) {
                    Text(group.localizedName)
                        .font(.app.latoBold(size: 18))
                        .foregroundColor(Color.app.textPrimary)
                    
                    ConvenienceGrid(
                        conveniences: Convenience.inGroup(group),
                        selectedConveniences: $viewModel.selectedConveniences
                    )
                    .frame(height: CGFloat((Convenience.inGroup(group).count + 3) / 4) * 110)
                }
            }
        }
    }
    
    private var submitButton: some View {
        Button(action: submitForm) {
            Text("Create Listing")
                .font(.app.latoBold(size: 16))
                .foregroundColor(Color.app.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.app.primaryVariant)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .padding(.vertical)
    }
    
    private var successView: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 24) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.green)
                
                Text("Property Created Successfully!")
                    .font(.app.latoBold(size: 24))
                    .foregroundColor(Color.app.textPrimary)
                
                Text("Your property has been listed and is now available for booking.")
                    .font(.app.latoRegular(size: 16))
                    .foregroundColor(Color.app.textFade)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button(action: {
                    isShowingSuccessView = false
                }) {
                    Text("Continue")
                        .font(.app.latoBold(size: 16))
                        .foregroundColor(Color.app.white)
                        .frame(width: 200)
                        .padding()
                        .background(Color.app.primaryVariant)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                }
                .padding(.top, 16)
            }
            .padding()
        }
    }
    
    // MARK: - Actions
    
    private func submitForm() {
        focusedField = nil
        
        if viewModel.validateForm() {
            viewModel.createProperty { success, message in
                if success {
                    isShowingSuccessView = true
                } else {
                    showAlert = true
                    alertMessage = message
                }
            }
        } else {
            showAlert = true
            alertMessage = "Please fill in all required fields correctly."
        }
    }
}
