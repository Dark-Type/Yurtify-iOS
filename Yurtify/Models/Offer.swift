//
//  Offer.swift
//  Yurtify
//
//  Created by dark type on 22.06.2025.
//

import SwiftUI

struct Offer {
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
        self.isRented = isRented
        self.isOccupied = isOccupied
        self.isFavorited = isFavorited
    }
}
