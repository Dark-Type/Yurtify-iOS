//
//  PropertyType.swift
//  Yurtify
//
//  Created by dark type on 23.06.2025.
//


import SwiftUI

/// Enum representing all available property types
enum PropertyType: String, Identifiable, CaseIterable {
    var id: String { rawValue }
    
    case hotel
    case boardingHouse
    case privateSector
    case guestHouse
    case childrenCamp
    case camping
    case recreationCenter
    
    // MARK: - Display Properties
    
    /// Localized display name for the property type
    var localizedName: String {
        switch self {
        case .hotel: return L10n.Detail.PropertyType.hotel
        case .boardingHouse: return L10n.Detail.PropertyType.boardingHouse
        case .privateSector: return L10n.Detail.PropertyType.privateSector
        case .guestHouse: return L10n.Detail.PropertyType.guestHouse
        case .childrenCamp: return L10n.Detail.PropertyType.childrenCamp
        case .camping: return L10n.Detail.PropertyType.camping
        case .recreationCenter: return L10n.Detail.PropertyType.recreationCenter
        }
    }
    
    /// Icon to display for the property type
    var icon: AppIcons {
        switch self {
        case .hotel: return .bed
        case .camping: return .place
        case .recreationCenter: return .sportsArea
        case .guestHouse: return .spaceOffer
        default: return .space
        }
    }
}
