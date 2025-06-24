//
//  Offer.swift
//  Yurtify
//
//  Created by dark type on 22.06.2025.
//

import CoreLocation
import SwiftUI

struct Offer: Identifiable, Equatable {
    let id: String
    let title: String
    let address: String
    let price: Double
    let period: L10n.Measures.Price
    let startDate: Date
    let endDate: Date
    let bedsCount: Int
    let bathroomsCount: Int
    let area: Double
    let maxOccupancy: Int
    let image: Image?
    let isOwner: Bool
    let coordinate: CLLocationCoordinate2D
    var isRented: Bool
    var isOccupied: Bool
    var isFavorited: Bool

    init(
        id: String = UUID().uuidString,
        title: String,
        address: String,
        price: Double,
        startDate: Date,
        endDate: Date,
        bedsCount: Int,
        bathroomsCount: Int,
        area: Double,
        period: L10n.Measures.Price = .perMonth,
        maxOccupancy: Int,
        image: Image? = nil,
        isOwner: Bool = false,
        coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 42.8746, longitude: 74.5698),
        isRented: Bool = false,
        isOccupied: Bool = false,
        isFavorited: Bool = false
    ) {
        self.id = id
        self.title = title
        self.address = address
        self.price = price
        self.period = period
        self.startDate = startDate
        self.endDate = endDate
        self.bedsCount = bedsCount
        self.bathroomsCount = bathroomsCount
        self.area = area
        self.maxOccupancy = maxOccupancy
        self.image = image
        self.isOwner = isOwner
        self.coordinate = coordinate
        self.isRented = isRented
        self.isOccupied = isOccupied
        self.isFavorited = isFavorited
    }

    // MARK: - Equatable Implementation

    static func == (lhs: Offer, rhs: Offer) -> Bool {
        guard lhs.id == rhs.id else { return false }

        return lhs.title == rhs.title &&
            lhs.address == rhs.address &&
            lhs.price == rhs.price &&
            lhs.period == rhs.period &&
            lhs.startDate == rhs.startDate &&
            lhs.endDate == rhs.endDate &&
            lhs.bedsCount == rhs.bedsCount &&
            lhs.bathroomsCount == rhs.bathroomsCount &&
            lhs.area == rhs.area &&
            lhs.maxOccupancy == rhs.maxOccupancy &&
            lhs.isOwner == rhs.isOwner &&
            lhs.coordinate.latitude == rhs.coordinate.latitude &&
            lhs.coordinate.longitude == rhs.coordinate.longitude &&
            lhs.isRented == rhs.isRented &&
            lhs.isOccupied == rhs.isOccupied &&
            lhs.isFavorited == rhs.isFavorited
    }
}
