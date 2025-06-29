//
//  OwnerDto.swift
//  Yurtify
//
//  Created by dark type on 29.06.2025.
//

import CoreLocation
import Foundation
import SwiftUI

// MARK: - Owner Model

struct OwnerDto: Codable, Equatable, Hashable {
    var fullName: String
    var email: String
    var phone: String
    var imageUrl: String
    
    init(
        fullName: String = "",
        email: String = "",
        phone: String = "",
        imageUrl: String = ""
    ) {
        self.fullName = fullName
        self.email = email
        self.phone = phone
        self.imageUrl = imageUrl
    }
}

// MARK: - Unified Property Model

struct UnifiedPropertyModel: Identifiable, Codable, Hashable {
    var id: String
    var title: String
    var addressName: String
    var coordinates: Coordinates
    
    var cost: Double
    var period: L10n.Measures.Price
    var closedDates: [Date]
    var firstFreeDate: Date
    var firstClosedDate: Date?
    
    var bedsCount: Int
    var roomsCount: Int
    var placeAmount: Int
    var maxPeople: Int
    
    var posterUrl: String
    var galleryUrls: [String]
    
    var properties: [String]
    var propertyType: PropertyType.RawValue
    
    var isFavorite: Bool
    var isOwn: Bool
    var owner: OwnerDto
    
    var createdAt: Date
    var updatedAt: Date
    
    var isOccupied: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, title, addressName, coordinates
        case cost, period, closedDates, firstFreeDate, firstClosedDate
        case bedsCount, roomsCount, placeAmount, maxPeople
        case posterUrl, galleryUrls
        case properties, propertyType
        case isFavorite, isOwn, owner
        case createdAt, updatedAt, isOccupied
    }
    
    init(
        id: String = UUID().uuidString,
        title: String = "",
        addressName: String = "",
        coordinates: Coordinates = Coordinates(),
        cost: Double = 0,
        period: L10n.Measures.Price = .perMonth,
        closedDates: [Date] = [],
        firstFreeDate: Date = Date(),
        firstClosedDate: Date? = nil,
        bedsCount: Int = 0,
        roomsCount: Int = 0,
        placeAmount: Int = 0,
        maxPeople: Int = 0,
        posterUrl: String = "",
        galleryUrls: [String] = [],
        properties: [String] = [],
        propertyType: PropertyType.RawValue = "",
        isFavorite: Bool = false,
        isOwn: Bool = false,
        owner: OwnerDto = OwnerDto(),
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isOccupied: Bool = false
    ) {
        self.id = id
        self.title = title
        self.addressName = addressName
        self.coordinates = coordinates
        self.cost = cost
        self.period = period
        self.closedDates = closedDates
        self.firstFreeDate = firstFreeDate
        self.firstClosedDate = firstClosedDate
        self.bedsCount = bedsCount
        self.roomsCount = roomsCount
        self.placeAmount = placeAmount
        self.maxPeople = maxPeople
        self.posterUrl = posterUrl
        self.galleryUrls = galleryUrls
        self.properties = properties
        self.propertyType = propertyType
        self.isFavorite = isFavorite
        self.isOwn = isOwn
        self.owner = owner
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isOccupied = isOccupied
    }
}

// MARK: - Extensions for backward compatibility

extension UnifiedPropertyModel {
    func toOffer() -> Offer {
        return Offer(
            id: id,
            title: title,
            address: addressName,
            price: cost,
            startDate: firstFreeDate,
            endDate: firstClosedDate ?? Calendar.current.date(byAdding: .month, value: 1, to: firstFreeDate) ?? firstFreeDate,
            bedsCount: bedsCount,
            area: Double(placeAmount),
            period: period,
            maxOccupancy: maxPeople,
            image: nil,
            isOwner: isOwn,
            coordinate: coordinates.clLocation,
            isRented: false,
            isFavorited: isFavorite
        )
    }
    
    static func from(property: PropertyModel) -> UnifiedPropertyModel {
        return UnifiedPropertyModel(
            id: property.id,
            title: property.name,
            addressName: property.address.formattedAddress,
            coordinates: property.address.coordinates,
            cost: property.price,
            period: property.pricePeriod,
            bedsCount: property.beds,
            roomsCount: property.beds,
            placeAmount: Int(property.area),
            maxPeople: property.capacity,
            properties: property.conveniences,
            propertyType: property.propertyType,
            isOwn: true,
            createdAt: property.createdAt,
            updatedAt: property.updatedAt
        )
    }
}

// MARK: - Image Upload Helper

struct PropertyImage: Identifiable {
    let id = UUID()
    let image: UIImage
    var isUploading: Bool = false
    var uploadedUrl: String?
    var uploadError: String?
}
