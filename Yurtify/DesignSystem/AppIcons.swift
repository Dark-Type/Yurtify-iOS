import SwiftUI

enum AppIcons: String, CaseIterable {
    // MARK: - Property Icons
    case bath = "Bath"
    case bathBig = "BathBig"
    case bed = "Bed"
    case bedBig = "BedBig"
    case booked = "Booked"
    case cafe = "Cafe"
    case dividerBottom = "DividerBottom"
    case dividerTop = "DividerTop"
    case favoriteButtonSelected = "FavoriteButtonSelected"
    case favoriteButtonUnselected = "FavoriteButtonUnselected"
    case favoriteSelected = "FavoriteSelected"
    case favoriteUnselected = "FavoriteUnselected"
    case goBackButton = "GoBackButton"
    case gym = "Gym"
    case listSelected = "ListSelected"
    case listUnselected = "ListUnselected"
    case logo = "Logo"
    case logoWithText = "LogoWithText"
    case mail = "Mail"
    case mailbox = "Mailbox"
    case mapSelected = "MapSelected"
    case mapUnselected = "MapUnselected"
    case notificationsSelected = "NotificationsSelected"
    case notificationsUnselected = "NotificationsUnselected"
    case parking = "Parking"
    case pets = "Pets"
    case phone = "Phone"
    case place = "Place"
    case pool = "Pool"
    case preferencesButton = "PreferencesButton"
    case profileSelected = "ProfileSelected"
    case profileUnselected = "ProfileUnselected"
    case search = "Search"
    case shareButton = "ShareButton"
    case space = "Space"
    case sportsArea = "SportsArea"
    case star = "Star"
    case washingMachine = "WashingMachine"
    case wifi = "Wifi"
    
    // MARK: - Computed Properties for Organization
    var image: Image {
        Image(self.rawValue)
    }
    

}

// MARK: - SF Symbols Support (for system icons)
enum SFSymbols: String, CaseIterable {
    case house = "house"
    case houseFill = "house.fill"
    case magnifyingGlass = "magnifyingglass"
    case person = "person"
    case personFill = "person.fill"
    case gear = "gearshape"
    case gearFill = "gearshape.fill"
    case heart = "heart"
    case heartFill = "heart.fill"
    case star = "star"
    case starFill = "star.fill"
    
    var image: Image {
        Image(systemName: self.rawValue)
    }
}
extension Image {
    static func appIcon(_ icon: AppIcons) -> Image {
        return icon.image
    }
    
}
extension AppIcons {
    func toggleState(isSelected: Bool) -> AppIcons {
        switch self {
        case .listUnselected:
            return isSelected ? .listSelected : .listUnselected
        case .listSelected:
            return isSelected ? .listSelected : .listUnselected
        case .mapUnselected:
            return isSelected ? .mapSelected : .mapUnselected
        case .mapSelected:
            return isSelected ? .mapSelected : .mapUnselected
        case .profileUnselected:
            return isSelected ? .profileSelected : .profileUnselected
        case .profileSelected:
            return isSelected ? .profileSelected : .profileUnselected
        case .favoriteButtonUnselected:
            return isSelected ? .favoriteButtonSelected : .favoriteButtonUnselected
        case .favoriteButtonSelected:
            return isSelected ? .favoriteButtonSelected : .favoriteButtonUnselected
        default:
            return self
        }
    }
    
    var oppositeState: AppIcons {
        switch self {
        case .listUnselected: return .listSelected
        case .listSelected: return .listUnselected
        case .mapUnselected: return .mapSelected
        case .mapSelected: return .mapUnselected
        case .profileUnselected: return .profileSelected
        case .profileSelected: return .profileUnselected
        case .favoriteButtonUnselected: return .favoriteButtonSelected
        case .favoriteButtonSelected: return .favoriteButtonUnselected
        default: return self
        }
    }
}
