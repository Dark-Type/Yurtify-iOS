//
//  Convenience.swift
//  Yurtify
//
//  Created by dark type on 23.06.2025.
//


import SwiftUI

/// Enum representing all available property conveniences/amenities
enum Convenience: String, Identifiable, CaseIterable {
    var id: String { rawValue }
    
    // MARK: - Territory Conveniences

    case spa
    case barbecue
    case basketball
    case pool
    case trampoline
    case billiard
    case playground
    case privateBeach
    case kumysTreatment
    case guarded
    case parking
    case sauna
    case tennis
    case gym
    case football
    
    // MARK: - Room Amenities

    case wifi
    case balcony
    case bathSupplies
    case separateShower
    case airConditioning
    case kitchen
    case microwave
    case stove
    case separateBathroom
    case satelliteTV
    case washingMachine
    case terrace
    case cleaning
    case iron
    case hairDryer
    case refrigerator
    case kettle
    case heating
    
    // MARK: - Features

    case cafe
    case restaurants
    case gorges
    case forests
    case hotSprings
    
    // MARK: - Display Properties
    
    /// Localized display name for the convenience
    var localizedName: String {
        switch self {
        // Territory
        case .spa: return L10n.Detail.Territory.spa
        case .barbecue: return L10n.Detail.Territory.barbecue
        case .basketball: return L10n.Detail.Territory.basketball
        case .pool: return L10n.Detail.Territory.pool
        case .trampoline: return L10n.Detail.Territory.trampoline
        case .billiard: return L10n.Detail.Territory.billiard
        case .playground: return L10n.Detail.Territory.playground
        case .privateBeach: return L10n.Detail.Territory.privateBeach
        case .kumysTreatment: return L10n.Detail.Territory.kumysTreatment
        case .guarded: return L10n.Detail.Territory.guarded
        case .parking: return L10n.Detail.Territory.parking
        case .sauna: return L10n.Detail.Territory.sauna
        case .tennis: return L10n.Detail.Territory.tennis
        case .gym: return L10n.Detail.Territory.gym
        case .football: return L10n.Detail.Territory.football
        // Room
        case .wifi: return L10n.Detail.Room.wifi
        case .balcony: return L10n.Detail.Room.balcony
        case .bathSupplies: return L10n.Detail.Room.bathSupplies
        case .separateShower: return L10n.Detail.Room.separateShower
        case .airConditioning: return L10n.Detail.Room.airConditioning
        case .kitchen: return L10n.Detail.Room.kitchen
        case .microwave: return L10n.Detail.Room.microwave
        case .stove: return L10n.Detail.Room.stove
        case .separateBathroom: return L10n.Detail.Room.separateBathroom
        case .satelliteTV: return L10n.Detail.Room.satelliteTV
        case .washingMachine: return L10n.Detail.Room.washingMachine
        case .terrace: return L10n.Detail.Room.terrace
        case .cleaning: return L10n.Detail.Room.cleaning
        case .iron: return L10n.Detail.Room.iron
        case .hairDryer: return L10n.Detail.Room.hairDryer
        case .refrigerator: return L10n.Detail.Room.refrigerator
        case .kettle: return L10n.Detail.Room.kettle
        case .heating: return L10n.Detail.Room.heating
        // Features
        case .cafe: return L10n.Detail.Features.cafe
        case .restaurants: return L10n.Detail.Features.restaurants
        case .gorges: return L10n.Detail.Features.gorges
        case .forests: return L10n.Detail.Features.forests
        case .hotSprings: return L10n.Detail.Features.hotSprings
        }
    }
    
    /// Icon to display for the convenience
    var icon: AppIcons {
        switch self {
        case .pool: return .pool

        case .gym: return .gym

        case .wifi: return .wifi

        case .cafe: return .cafe

        case .parking: return .parking

        case .washingMachine: return .washingMachine
            
        case .basketball, .tennis, .football, .playground:
            return .sportsArea
            
        case .bathSupplies, .separateShower, .separateBathroom:
            return .bath
            
        case .spa, .sauna, .hotSprings:
            return .pool
            
        case .kitchen, .microwave, .stove, .refrigerator, .kettle:
            return .cafe
            
        default:
            return .space
        }
    }
    
    /// Group that the convenience belongs to
    enum Group: String, CaseIterable {
        case territory = "Territory"
        case room = "Room"
        case features = "Features"
        
        var localizedName: String {
            switch self {
            case .territory: return L10n.Detail.Territory.title
            case .room: return L10n.Detail.Room.title
            case .features: return L10n.Detail.Features.title
            }
        }
    }
    
    /// Get the group this convenience belongs to
    var group: Group {
        switch self {
        case .spa, .barbecue, .basketball, .pool, .trampoline, .billiard, .playground,
             .privateBeach, .kumysTreatment, .guarded, .parking, .sauna, .tennis, .gym, .football:
            return .territory
            
        case .wifi, .balcony, .bathSupplies, .separateShower, .airConditioning, .kitchen,
             .microwave, .stove, .separateBathroom, .satelliteTV, .washingMachine, .terrace,
             .cleaning, .iron, .hairDryer, .refrigerator, .kettle, .heating:
            return .room
            
        case .cafe, .restaurants, .gorges, .forests, .hotSprings:
            return .features
        }
    }
    
    /// Get all conveniences in a specific group
    static func inGroup(_ group: Group) -> [Convenience] {
        return allCases.filter { $0.group == group }
    }
}
