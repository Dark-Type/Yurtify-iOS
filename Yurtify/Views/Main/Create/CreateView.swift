//
//  CreateView.swift
//  Yurtify
//
//  Created by dark type on 14.06.2025.
//

import AVFoundation
import PhotosUI
import SwiftUI

struct CreateView: View {
    // MARK: - Properties

    @StateObject private var viewModel = CreateViewModel()
    @FocusState private var focusedField: FormField?
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isShowingSuccessView = false
    @EnvironmentObject var apiService: APIService
    
    enum FormField: Hashable {
        case name
        case description
        case price
        case area
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
                
                availabilitySection
                
                imageUploadSection
                
                posterImageSection
                
                conveniencesSection
                
                submitButton
            }
            .padding()
        }
        .background(.base)
        .navigationTitle("Create Listing")
        .onTapGesture {
            focusedField = nil
        }
        .onAppear {
            viewModel.setAPIService(apiService)
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Message"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        
        .photosPicker(
            isPresented: $viewModel.showingImagePicker,
            selection: $viewModel.selectedPhotoItems,
            maxSelectionCount: 30,
            matching: .images,
        )
        .photosPicker(
            isPresented: $viewModel.showingPosterPicker,
            selection: $viewModel.posterPhotoItems,
            maxSelectionCount: 1,
            matching: .images
        )
        .fullScreenCover(isPresented: $viewModel.showingCamera) {
            ImagePicker(
                sourceType: .camera,
                onImageSelected: { image in
                    viewModel.addCameraImage(image)
                },
                onCancel: {
                    viewModel.showingCamera = false
                }
            )
        }
        .sheet(isPresented: $viewModel.showingPosterSelectionSheet) {
            PosterSelectionSheet(
                galleryImages: viewModel.selectedImages,
                onSelectFromGallery: { image in
                    viewModel.selectPosterFromGallery(image)
                },
                onSelectFromLibrary: {
                    viewModel.showPosterPicker()
                },
                isPresented: $viewModel.showingPosterSelectionSheet
            )
        }
        .fullScreenCover(isPresented: $isShowingSuccessView) {
            successView
        }
        .onChange(of: viewModel.selectedPhotoItems) { _ in
            if !viewModel.selectedPhotoItems.isEmpty {
                viewModel.processSelectedPhotos()
            }
        }
        .onChange(of: viewModel.posterPhotoItems) { _ in
            if !viewModel.posterPhotoItems.isEmpty {
                viewModel.processPosterPhoto()
            }
        }
    }
    
    private var basicDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Basic Details")
                .font(.app.largeTitle())
                .foregroundColor(Color.app.textPrimary)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Property Name")
                    .font(.app.latoBold(size: 18))
                    .foregroundColor(Color.app.textPrimary)
                
                TextField("Enter property name", text: $viewModel.property.title)
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
                    .font(.app.latoRegular(size: 16))
                    .foregroundColor(Color.app.textPrimary)
                
                TextEditor(text: $viewModel.property.addressName)
                    .frame(minHeight: 120)
                    .font(.app.latoRegular(size: 16))
                    .foregroundColor(Color.app.textPrimary)
                    .scrollContentBackground(.hidden)
                    .background(Color.app.accentLight)
                    .cornerRadius(12)
                    .padding(4)
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
            
            EnhancedMeasuresRow(
                areaText: $viewModel.areaText,
                beds: $viewModel.beds,
                rooms: $viewModel.rooms,
                capacity: $viewModel.capacity,
                focusedField: $focusedField
            )
            .frame(height: 130)
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
                
                Picker("Period", selection: $viewModel.property.period) {
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
                .accentColor(Color.app.textPrimary)
            }
        }
    }
    
    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Location")
                .font(.app.latoBold(size: 18))
                .foregroundColor(Color.app.textPrimary)
            
            LocationPickerView(address: $viewModel.propertyAddress)
                .modifier(ShakeEffect(shaking: viewModel.invalidFields.contains(.location)))
        }
    }
    
    private var availabilitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Availability")
                .font(.app.latoBold(size: 18))
                .foregroundColor(Color.app.textPrimary)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Rental Period")
                    .font(.app.latoBold(size: 16))
                    .foregroundColor(Color.app.textPrimary)
                
                HStack(spacing: 16) {
                    VStack(alignment: .leading) {
                        Text("Start Date")
                            .font(.app.latoRegular(size: 14))
                            .foregroundColor(Color.app.textFade)
                        
                        DatePicker("", selection: $viewModel.startDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                    }
                    
                    VStack(alignment: .leading) {
                        Text("End Date")
                            .font(.app.latoRegular(size: 14))
                            .foregroundColor(Color.app.textFade)
                        
                        DatePicker("", selection: $viewModel.endDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                    }
                }
                .modifier(ShakeEffect(shaking: viewModel.invalidFields.contains(.dates)))
            }
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Unavailable Dates")
                        .font(.app.latoBold(size: 16))
                        .foregroundColor(Color.app.textPrimary)
                    
                    Spacer()
                    
                    Button(viewModel.isSelectingUnavailableDates ? "Done" : "Select") {
                        viewModel.isSelectingUnavailableDates.toggle()
                    }
                    .font(.app.latoRegular(size: 14))
                    .foregroundColor(Color.app.primaryVariant)
                }
                
                if viewModel.isSelectingUnavailableDates {
                    Text("Tap dates to mark as unavailable")
                        .font(.app.latoRegular(size: 12))
                        .foregroundColor(Color.app.textFade)
                    
                    CalendarView(
                        unavailableDates: $viewModel.unavailableDates,
                        startDate: viewModel.startDate,
                        endDate: viewModel.endDate
                    )
                    .frame(height: 300)
                }
                
                if !viewModel.unavailableDates.isEmpty {
                    Text("Unavailable: \(viewModel.unavailableDates.count) date(s)")
                        .font(.app.latoRegular(size: 12))
                        .foregroundColor(Color.app.textFade)
                }
            }
        }
    }
    
    private var imageUploadSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Property Images")
                .font(.app.latoBold(size: 18))
                .foregroundColor(Color.app.textPrimary)
            
            HStack(spacing: 12) {
                Button(action: {
                    print("🔘 Gallery button tapped - Using Apple's PhotosPicker")
                    viewModel.showPhotosPicker()
                }) {
                    HStack {
                        Image(systemName: "photo.on.rectangle")
                        Text("Gallery")
                    }
                    .font(.app.latoRegular(size: 14))
                    .foregroundColor(Color.app.primaryVariant)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.app.accentLight)
                    .cornerRadius(8)
                }
                .disabled(viewModel.isProcessingImages)
                
                Button(action: {
                    print("🔘 Camera button tapped - Using Apple's ImagePicker")
                    viewModel.showCamera()
                }) {
                    HStack {
                        Image(systemName: "camera")
                        Text("Camera")
                    }
                    .font(.app.latoRegular(size: 14))
                    .foregroundColor(Color.app.primaryVariant)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.app.accentLight)
                    .cornerRadius(8)
                }
                .disabled(viewModel.isProcessingImages)
                
                if viewModel.isProcessingImages {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Processing...")
                            .font(.app.latoRegular(size: 12))
                            .foregroundColor(Color.app.textFade)
                    }
                    .padding(.horizontal, 8)
                }
                
                Spacer()
            }
            
            if !viewModel.selectedImages.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array(viewModel.selectedImages.enumerated()), id: \.element.id) { index, propertyImage in
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: propertyImage.image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .clipped()
                                    .cornerRadius(8)
    
                                Button(action: {
                                    viewModel.removeImage(at: index)
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                        .background(Color.white)
                                        .clipShape(Circle())
                                }
                                .offset(x: 8, y: -8)
                            }
                            .padding(.top)
                        }
                    }
                    .padding(.horizontal, 4)
                }
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "photo.badge.plus")
                        .font(.system(size: 40))
                        .foregroundColor(Color.app.textFade)
                    
                    Text("No images selected")
                        .font(.app.latoRegular(size: 14))
                        .foregroundColor(Color.app.textFade)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 120)
                .background(Color.app.accentLight)
                .cornerRadius(12)
                .modifier(ShakeEffect(shaking: viewModel.invalidFields.contains(.images)))
            }
        }
    }
    
    private var posterImageSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Poster Image")
                    .font(.app.latoBold(size: 18))
                    .foregroundColor(Color.app.textPrimary)
                
                Text("*")
                    .font(.app.latoBold(size: 18))
                    .foregroundColor(.red)
                
                Spacer()
            }
            
            Text("Choose a main image that will represent your property")
                .font(.app.latoRegular(size: 14))
                .foregroundColor(Color.app.textFade)
            
            if let posterImage = viewModel.posterImage {
                HStack(spacing: 16) {
                    Image(uiImage: posterImage.image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 120, height: 120)
                        .clipped()
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.app.primaryVariant, lineWidth: 2)
                        )
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Poster Image Selected")
                            .font(.app.latoBold(size: 16))
                            .foregroundColor(Color.app.textPrimary)
                        
                        Text("This image will be shown as the main photo in property listings")
                            .font(.app.latoRegular(size: 12))
                            .foregroundColor(Color.app.textFade)
                        
                        HStack(spacing: 8) {
                            Button("Change") {
                                viewModel.showPosterSelection()
                            }
                            .font(.app.latoRegular(size: 14))
                            .foregroundColor(Color.app.primaryVariant)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.app.accentLight)
                            .cornerRadius(8)
                            
                            Button("Remove") {
                                viewModel.removePosterImage()
                            }
                            .font(.app.latoRegular(size: 14))
                            .foregroundColor(.red)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    
                    Spacer()
                }
            } else {
                VStack(spacing: 16) {
                    if viewModel.isProcessingPosterImage {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Processing poster image...")
                                .font(.app.latoRegular(size: 14))
                                .foregroundColor(Color.app.textFade)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 120)
                        .background(Color.app.accentLight)
                        .cornerRadius(12)
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "photo.badge.checkmark")
                                .font(.system(size: 40))
                                .foregroundColor(Color.app.textFade)
                            
                            Text("No poster image selected")
                                .font(.app.latoRegular(size: 14))
                                .foregroundColor(Color.app.textFade)
                            
                            Button("Select Poster Image") {
                                viewModel.showPosterSelection()
                            }
                            .font(.app.latoBold(size: 14))
                            .foregroundColor(Color.app.primaryVariant)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.app.accentLight)
                            .cornerRadius(8)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 160)
                        .background(Color.app.accentLight)
                        .cornerRadius(12)
                        .modifier(ShakeEffect(shaking: viewModel.invalidFields.contains(.poster)))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(viewModel.invalidFields.contains(.poster) ? Color.red : Color.clear, lineWidth: 1)
                        )
                    }
                }
            }
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
                .padding(.vertical)
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
