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
    var id: String
    init(
        fullName: String = "",
        email: String = "",
        phone: String = "",
        imageUrl: String = "",
        id: String = ""
    ) {
        self.fullName = fullName
        self.email = email
        self.phone = phone
        self.imageUrl = imageUrl
        self.id = id
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

extension UnifiedPropertyModel {
    struct OwnerInfo {
        let id: String
        let firstName: String
        let lastName: String
        let email: String
        let phone: String
        
        var fullName: String {
            return "\(firstName) \(lastName)".trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
}

extension UnifiedPropertyModel {
    static func from(housingDTO: Components.Schemas.HousingResponseDTO) -> UnifiedPropertyModel? {
        guard let id = housingDTO.id,
              let location = housingDTO.location
        else {
            print("❌ Critical fields missing from HousingResponseDTO")
            return nil
        }
        
        let period: L10n.Measures.Price = {
            guard let apiPeriod = housingDTO.period else { return .perDay }
            switch apiPeriod {
            case .DAY: return .perDay
            case .WEEK: return .perWeek
            case .MONTH: return .perMonth
            }
        }()
        
        let coordinates = Coordinates(
            latitude: Double(location.latitude ?? 0.0),
            longitude: Double(location.longitude ?? 0.0)
        )
        
        let owner = OwnerDto(
            fullName: {
                let firstName = housingDTO.owner?.firstName ?? ""
                let lastName = housingDTO.owner?.lastName ?? ""
                let fullName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespacesAndNewlines)
                return fullName.isEmpty ? "Неизвестный владелец" : fullName
            }(),
            email: housingDTO.owner?.email ?? "",
            phone: housingDTO.owner?.phone ?? "",
            imageUrl: "",
            id: housingDTO.owner?.id ?? UUID().uuidString
        )
        
        let properties = housingDTO.properties?.map { $0.rawValue } ?? []
        let territoryConveniences = housingDTO.territoryConveniences?.map { $0.rawValue } ?? []
        let roomAmenities = housingDTO.roomAmenities?.map { $0.rawValue } ?? []
        let features = housingDTO.features?.map { $0.rawValue } ?? []
        
        let allProperties = properties + territoryConveniences + roomAmenities + features
        
        return UnifiedPropertyModel(
            id: id,
            title: housingDTO.title?.isEmpty == false ? housingDTO.title! : "Без названия",
            addressName: housingDTO.addressName?.isEmpty == false ? housingDTO.addressName! : "Адрес не указан",
            coordinates: coordinates,
            cost: housingDTO.cost ?? 0.0,
            period: period,
            closedDates: [],
            firstFreeDate: Date(),
            firstClosedDate: nil,
            bedsCount: Int(housingDTO.bedsCount ?? 0),
            roomsCount: Int(housingDTO.roomsCount ?? 0),
            placeAmount: Int(housingDTO.placeAmount ?? 0),
            maxPeople: Int(housingDTO.maxPeople ?? 0),
            posterUrl: housingDTO.galleryIds?.first ?? "",
            galleryUrls: housingDTO.galleryIds ?? [],
            properties: allProperties,
            propertyType: housingDTO._type?.rawValue ?? "UNKNOWN",
            isFavorite: housingDTO.isFavorite ?? false,
            isOwn: false,
            owner: owner,
            createdAt: Date(),
            updatedAt: Date(),
            isOccupied: false
        )
    }
}

extension UnifiedPropertyModel {
  
    func toHousingCreateDTO() -> Components.Schemas.HousingCreateDTO {
     
        let periodPayload: Components.Schemas.HousingCreateDTO.periodPayload? = {
            switch self.period {
            case .perDay: return .DAY
            case .perWeek: return .WEEK
            case .perMonth: return .MONTH
            
            }
        }()
        
     
        let typePayload: Components.Schemas.HousingCreateDTO._typePayload? = {
            switch self.propertyType.uppercased() {
            case "COTTAGE": return .COTTAGE
            case "ROOM": return .ROOM
            case "HOTEL": return .HOTEL
            default: return nil
            }
        }()
        
    
        func mapProps<T: RawRepresentable & CaseIterable>(_ values: [String], enums: [T]) -> [T] where T.RawValue == String {
            values.compactMap { raw in enums.first(where: { $0.rawValue == raw }) }
        }
        
        let properties = mapProps(
            self.properties,
            enums: Components.Schemas.HousingCreateDTO.propertiesPayloadPayload.allCases
        )
        let territoryConveniences = mapProps(
            self.properties,
            enums: Components.Schemas.HousingCreateDTO.territoryConveniencesPayloadPayload.allCases
        )
        let roomAmenities = mapProps(
            self.properties,
            enums: Components.Schemas.HousingCreateDTO.roomAmenitiesPayloadPayload.allCases
        )
        let features = mapProps(
            self.properties,
            enums: Components.Schemas.HousingCreateDTO.featuresPayloadPayload.allCases
        )

      
        return Components.Schemas.HousingCreateDTO(
            title: self.title,
            addressName: self.addressName,
            location: Components.Schemas.Location(
                latitude: Float(self.coordinates.latitude),
                longitude: Float(self.coordinates.longitude)
            ),
            cost: self.cost,
            period: periodPayload,
            bedsCount: Int32(self.bedsCount),
            roomsCount: Int32(self.roomsCount),
            placeAmount: Int32(self.placeAmount),
            maxPeople: Int32(self.maxPeople),
            _type: typePayload,
            properties: properties.isEmpty ? nil : properties,
            territoryConveniences: territoryConveniences.isEmpty ? nil : territoryConveniences,
            roomAmenities: roomAmenities.isEmpty ? nil : roomAmenities,
            features: features.isEmpty ? nil : features,
            galleryIds: self.galleryUrls.isEmpty ? nil : self.galleryUrls
        )
    }
}
