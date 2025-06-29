//
//  PropertyModel.swift
//  Yurtify
//
//  Created by dark type on 23.06.2025.
//

import CoreLocation
import Foundation

struct PropertyModel: Identifiable, Codable {
    var id: String
    var name: String
    var description: String
    var propertyType: PropertyType.RawValue
    
    // Measurements
    var area: Double
    var beds: Int
    var bathrooms: Int
    var capacity: Int
    
    // Location
    var address: Address
    
    // Pricing
    var price: Double
    var pricePeriodRaw: String
    
    // Conveniences
    var conveniences: [String]
    
    // Additional metadata
    var createdAt: Date
    var updatedAt: Date
    var ownerId: String
    
    var pricePeriod: L10n.Measures.Price {
        get {
            return L10n.Measures.Price(rawValue: pricePeriodRaw) ?? .perMonth
        }
        set {
            pricePeriodRaw = newValue.rawValue
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, propertyType
        case area, beds, bathrooms, capacity
        case address
        case price, pricePeriodRaw = "pricePeriod"
        case conveniences
        case createdAt, updatedAt, ownerId
    }
    
    init(
        id: String = UUID().uuidString,
        name: String = "",
        description: String = "",
        propertyType: PropertyType.RawValue = "",
        area: Double = 0,
        beds: Int = 0,
        bathrooms: Int = 0,
        capacity: Int = 0,
        address: Address = Address(),
        price: Double = 0,
        pricePeriod: L10n.Measures.Price = .perMonth,
        conveniences: [String] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        ownerId: String = ""
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.propertyType = propertyType
        self.area = area
        self.beds = beds
        self.bathrooms = bathrooms
        self.capacity = capacity
        self.address = address
        self.price = price
        self.pricePeriodRaw = pricePeriod.rawValue
        self.conveniences = conveniences
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.ownerId = ownerId
    }
}

struct Address: Codable, Equatable {
    var street: String
    var houseNumber: String
    var city: String
    var postalCode: String
    var country: String
    var coordinates: Coordinates
    
    var formattedAddress: String {
        var components = [String]()
           
        if !street.isEmpty {
            var streetLine = street
            if !houseNumber.isEmpty {
                if !street.contains(houseNumber) {
                    streetLine += " \(houseNumber)"
                }
            }
            components.append(streetLine)
        } else if !houseNumber.isEmpty {
            components.append(houseNumber)
        }
           
        if !city.isEmpty || !postalCode.isEmpty {
            var locationLine = ""
            if !postalCode.isEmpty {
                locationLine += postalCode
                if !city.isEmpty {
                    locationLine += " "
                }
            }
            if !city.isEmpty {
                locationLine += city
            }
            components.append(locationLine)
        }
           
        if !country.isEmpty {
            components.append(country)
        }
           
        let result = components.joined(separator: ", ")
        return result.isEmpty ? "No address selected" : result
    }
    
    init(
        street: String = "",
        houseNumber: String = "",
        city: String = "",
        postalCode: String = "",
        country: String = "",
        coordinates: Coordinates = Coordinates()
    ) {
        self.street = street
        self.houseNumber = houseNumber
        self.city = city
        self.postalCode = postalCode
        self.country = country
        self.coordinates = coordinates
    }
}

struct Coordinates: Codable, Equatable, Hashable {
    var latitude: Double
    var longitude: Double
    
    init(latitude: Double = 0, longitude: Double = 0) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    var clLocation: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
