//
//  CreatePropertyViewModel.swift
//  Yurtify
//
//  Created by dark type on 23.06.2025.
//

import SwiftUI

@MainActor
final class CreateViewModel: ObservableObject {
    @Published var property = PropertyModel()
    @Published var selectedPropertyType: PropertyType?
    @Published var selectedConveniences = Set<Convenience>()
    @Published var priceText = ""
    
    // Form validation
    @Published var invalidFields = Set<ValidationField>()
    
    // Computed properties for MeasuresRow
    var area: Double {
        get { property.area }
        set { property.area = newValue }
    }
    
    var beds: Double {
        get { Double(property.beds) }
        set { property.beds = Int(newValue) }
    }
    
    var bathrooms: Double {
        get { Double(property.bathrooms) }
        set { property.bathrooms = Int(newValue) }
    }
    
    var capacity: Double {
        get { Double(property.capacity) }
        set { property.capacity = Int(newValue) }
    }
    
    enum ValidationField: Hashable {
        case name
        case description
        case propertyType
        case measurements
        case price
        case location
    }
    
    // MARK: - Form Validation

    func validateForm() -> Bool {
        invalidFields.removeAll()
        
        // Validate name
        if property.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            invalidFields.insert(.name)
        }
        
        // Validate description
        if property.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            invalidFields.insert(.description)
        }
        
        if selectedPropertyType == nil {
            invalidFields.insert(.propertyType)
        }
        
        if property.area <= 0 || property.beds <= 0 || property.bathrooms <= 0 || property.capacity <= 0 {
            invalidFields.insert(.measurements)
        }
        
        let cleanedPrice = priceText.replacingOccurrences(of: ",", with: ".")
        if let price = Double(cleanedPrice), price > 0 {
            property.price = price
        } else {
            invalidFields.insert(.price)
        }
        
        if property.address.city.isEmpty || property.address.coordinates.latitude == 0 {
            invalidFields.insert(.location)
        }
        
        if let type = selectedPropertyType {
            property.propertyType = type.rawValue
        }
        
        property.conveniences = selectedConveniences.map { $0.rawValue }
        
        return invalidFields.isEmpty
    }
    
    // MARK: - Property Creation
    
    func createPropertyAsync() async -> (success: Bool, message: String) {
        property.createdAt = Date()
        property.updatedAt = Date()
        
        property.ownerId = UUID().uuidString
        
        // Log property data
        logPropertyData()
        
        // Simulate network delay
        try? await Task.sleep(for: .seconds(1.5))
        
        // In production, this would be an API call
        return (true, "Property created successfully!")
    }
    
    func createProperty(completion: @escaping (Bool, String) -> Void) {
        Task {
            let result = await createPropertyAsync()
            completion(result.success, result.message)
        }
    }
    
    // MARK: - Helper Methods
    
    private func logPropertyData() {
        print("Creating property: \(property.name)")
        print("Type: \(property.propertyType)")
        print("Measurements: \(property.area)m², \(property.beds) beds, \(property.bathrooms) bathrooms, \(property.capacity) people")
        print("Price: \(property.price) \(property.pricePeriod.rawValue)")
        print("Address: \(property.address.formattedAddress)")
        print("Coordinates: \(property.address.coordinates.latitude), \(property.address.coordinates.longitude)")
        print("Conveniences: \(property.conveniences)")
    }
}
