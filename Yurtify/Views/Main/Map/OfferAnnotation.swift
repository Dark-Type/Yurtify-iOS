//
//  class.swift
//  Yurtify
//
//  Created by dark type on 24.06.2025.
//

import MapKit

class OfferAnnotation: NSObject, MKAnnotation {
    let offerId: String
    var coordinate: CLLocationCoordinate2D
    var price: Double
    var period: L10n.Measures.Price
    var isSelected: Bool

    init(offerId: String, coordinate: CLLocationCoordinate2D, price: Double, period: L10n.Measures.Price, isSelected: Bool) {
        self.offerId = offerId
        self.coordinate = coordinate
        self.price = price
        self.period = period
        self.isSelected = isSelected
        super.init()
    }
}
