//
//  L10n.swift
//  Yurtify
//
//  Created by dark type on 14.06.2025.
//

import Foundation

enum L10n {
    // MARK: - Language Detection

    private static var currentLanguage: String {
        return Locale.current.language.languageCode?.identifier ?? "en"
    }
    
    private static var isRussian: Bool {
        return currentLanguage == "ru"
    }
    
    private static var isKyrgyz: Bool {
        return currentLanguage == "ky"
    }
    
    private static var isEnglish: Bool {
        return currentLanguage == "en"
    }
    
    // MARK: - Welcome Screen

    enum Welcome {
        static let title = NSLocalizedString("welcome.title", comment: "")
        static let quote = NSLocalizedString("welcome.quote", comment: "")
        static let register = NSLocalizedString("welcome.register", comment: "")
        static let login = NSLocalizedString("welcome.login", comment: "")
        static let or = NSLocalizedString("welcome.or", comment: "")
        static let guest = NSLocalizedString("welcome.guest", comment: "")
    }
    
    // MARK: - Registration Screen

    enum Registration {
        static let title = NSLocalizedString("registration.title", comment: "")
        static let surname = NSLocalizedString("registration.surname", comment: "")
        static let name = NSLocalizedString("registration.name", comment: "")
        static let patronymic = NSLocalizedString("registration.patronymic", comment: "")
        static let phone = NSLocalizedString("registration.phone", comment: "")
        static let email = NSLocalizedString("registration.email", comment: "")
        static let password = NSLocalizedString("registration.password", comment: "")
        static let confirmation = NSLocalizedString("registration.confirmation", comment: "")
        static let alreadyHaveAccount = "registration.already_have_account"
        static let button = NSLocalizedString("registration.button", comment: "")
    }
    
    // MARK: - Login Screen

    enum Login {
        static let title = NSLocalizedString("login.title", comment: "")
        static let phone = NSLocalizedString("login.phone", comment: "")
        static let password = NSLocalizedString("login.password", comment: "")
        static let button = NSLocalizedString("login.button", comment: "")
    }
    
    // MARK: - TabBar

    enum TabBar {
        static let list = NSLocalizedString("tabbar.list", comment: "")
        static let map = NSLocalizedString("tabbar.map", comment: "")
        static let create = NSLocalizedString("tabbar.create", comment: "")
        static let notifications = NSLocalizedString("tabbar.notifications", comment: "")
        static let profile = NSLocalizedString("tabbar.profile", comment: "")
    }
    
    // MARK: - Search

    static let search = NSLocalizedString("search", comment: "")
    
    // MARK: - Notifications Screen

    enum Notifications {
        static let title = NSLocalizedString("notifications.title", comment: "")
        static let today = NSLocalizedString("notifications.today", comment: "")
        static let yesterday = NSLocalizedString("notifications.yesterday", comment: "")
        static let client = NSLocalizedString("notifications.client", comment: "")
        static let confirmation = NSLocalizedString("notifications.confirmation", comment: "")
    }
    
    // MARK: - Profile Screen

    enum Profile {
        static let favorite = NSLocalizedString("profile.favorite", comment: "")
        static let rented = NSLocalizedString("profile.rented", comment: "")
        static let history = NSLocalizedString("profile.history", comment: "")
    }
    
    // MARK: - Detail Screen

    enum Detail {
        // MARK: - Basic

        static let owner = NSLocalizedString("detail.owner", comment: "")
        static let conveniences = NSLocalizedString("detail.conviniences", comment: "")
        static let address = NSLocalizedString("detail.adress", comment: "")
        static let map = NSLocalizedString("detail.map", comment: "")
        static let price = NSLocalizedString("detail.price", comment: "")
        static let rent = NSLocalizedString("detail.rent", comment: "")
        static let description = NSLocalizedString("detail.description", comment: "")
        static let gallery = NSLocalizedString("detail.galery", comment: "")
        static let similar = NSLocalizedString("detail.similar", comment: "")
        static let similarOffers = NSLocalizedString("detail.similar.offers", comment: "")
        static let sqm = NSLocalizedString("detail.sqm", comment: "")
        
        // MARK: - Property Complex

        enum Complex {
            static let membership = NSLocalizedString("detail.complex.membership", comment: "")
            static let none = NSLocalizedString("detail.complex.none", comment: "")
            static let name = NSLocalizedString("detail.complex.name", comment: "")
        }
        
        // MARK: - Additional Features

        enum Features {
            static let title = NSLocalizedString("detail.features.title", comment: "")
            static let cafe = NSLocalizedString("detail.features.cafe", comment: "")
            static let restaurants = NSLocalizedString("detail.features.restaurants", comment: "")
            static let gorges = NSLocalizedString("detail.features.gorges", comment: "")
            static let forests = NSLocalizedString("detail.features.forests", comment: "")
            static let hotSprings = NSLocalizedString("detail.features.hot_springs", comment: "")
        }
        
        // MARK: - Distance from Lake

        enum Distance {
            static let title = NSLocalizedString("detail.distance.title", comment: "")
        }
        
        // MARK: - Area

        enum Area {
            static let title = NSLocalizedString("detail.area.title", comment: "")
        }
        
        // MARK: - Price

        enum Price {
            static let perPerson = NSLocalizedString("detail.price.per_person", comment: "")
            static let entirePlace = NSLocalizedString("detail.price.entire_place", comment: "")
        }
        
        // MARK: -  Property Type

        enum PropertyType {
            static let title = NSLocalizedString("detail.type.title", comment: "")
            static let hotel = NSLocalizedString("detail.type.hotel", comment: "")
            static let boardingHouse = NSLocalizedString("detail.type.boarding_house", comment: "")
            static let privateSector = NSLocalizedString("detail.type.private_sector", comment: "")
            static let guestHouse = NSLocalizedString("detail.type.guest_house", comment: "")
            static let childrenCamp = NSLocalizedString("detail.type.children_camp", comment: "")
            static let camping = NSLocalizedString("detail.type.camping", comment: "")
            static let recreationCenter = NSLocalizedString("detail.type.recreation_center", comment: "")
        }
        
        // MARK: - Rooms

        enum Rooms {
            static let title = NSLocalizedString("detail.rooms.title", comment: "")
        }
        
        // MARK: - Capacity

        enum Capacity {
            static let title = NSLocalizedString("detail.capacity.title", comment: "")
        }
        
        // MARK: - Territory Amenities

        enum Territory {
            static let title = NSLocalizedString("detail.territory.title", comment: "")
            static let spa = NSLocalizedString("detail.territory.spa", comment: "")
            static let barbecue = NSLocalizedString("detail.territory.barbecue", comment: "")
            static let basketball = NSLocalizedString("detail.territory.basketball", comment: "")
            static let pool = NSLocalizedString("detail.territory.pool", comment: "")
            static let trampoline = NSLocalizedString("detail.territory.trampoline", comment: "")
            static let billiard = NSLocalizedString("detail.territory.billiard", comment: "")
            static let playground = NSLocalizedString("detail.territory.playground", comment: "")
            static let privateBeach = NSLocalizedString("detail.territory.private_beach", comment: "")
            static let kumysTreatment = NSLocalizedString("detail.territory.kumys_treatment", comment: "")
            static let guarded = NSLocalizedString("detail.territory.guarded", comment: "")
            static let parking = NSLocalizedString("detail.territory.parking", comment: "")
            static let sauna = NSLocalizedString("detail.territory.sauna", comment: "")
            static let tennis = NSLocalizedString("detail.territory.tennis", comment: "")
            static let gym = NSLocalizedString("detail.territory.gym", comment: "")
            static let football = NSLocalizedString("detail.territory.football", comment: "")
        }
        
        // MARK: - Room Amenities

        enum Room {
            static let title = NSLocalizedString("detail.room.title", comment: "")
            static let wifi = NSLocalizedString("detail.room.wifi", comment: "")
            static let balcony = NSLocalizedString("detail.room.balcony", comment: "")
            static let bathSupplies = NSLocalizedString("detail.room.bath_supplies", comment: "")
            static let separateShower = NSLocalizedString("detail.room.separate_shower", comment: "")
            static let airConditioning = NSLocalizedString("detail.room.air_conditioning", comment: "")
            static let kitchen = NSLocalizedString("detail.room.kitchen", comment: "")
            static let microwave = NSLocalizedString("detail.room.microwave", comment: "")
            static let stove = NSLocalizedString("detail.room.stove", comment: "")
            static let separateBathroom = NSLocalizedString("detail.room.separate_bathroom", comment: "")
            static let satelliteTV = NSLocalizedString("detail.room.satellite_tv", comment: "")
            static let washingMachine = NSLocalizedString("detail.room.washing_machine", comment: "")
            static let terrace = NSLocalizedString("detail.room.terrace", comment: "")
            static let cleaning = NSLocalizedString("detail.room.cleaning", comment: "")
            static let iron = NSLocalizedString("detail.room.iron", comment: "")
            static let hairDryer = NSLocalizedString("detail.room.hair_dryer", comment: "")
            static let refrigerator = NSLocalizedString("detail.room.refrigerator", comment: "")
            static let kettle = NSLocalizedString("detail.room.kettle", comment: "")
            static let heating = NSLocalizedString("detail.room.heating", comment: "")
        }
        
        // MARK: - Meals

        enum Meals {
            static let title = NSLocalizedString("detail.meals.title", comment: "")
            static let paidSeparately = NSLocalizedString("detail.meals.paid_separately", comment: "")
            static let breakfastOnly = NSLocalizedString("detail.meals.breakfast_only", comment: "")
            static let threeMeals = NSLocalizedString("detail.meals.three_meals", comment: "")
            static let noMeals = NSLocalizedString("detail.meals.no_meals", comment: "")
        }
    }
    
    // MARK: - Unified Measures System

    enum Measures {
        // MARK: - Time Periods

        enum Price: String, CaseIterable {
            case perDay = "measures.price.per_day"
            case perWeek = "measures.price.per_week"
            case perMonth = "measures.price.per_month"
            
            var localized: String {
                return NSLocalizedString(self.rawValue, comment: "")
            }
        }
        
        // MARK: - Units

        enum Unit: String, CaseIterable {
            case squareMeters = "measures.units.sqm"
            case people = "measures.units.people"
            case meters = "measures.units.meters"
            case kilometers = "measures.units.kilometers"
            
            var localized: String {
                return NSLocalizedString(self.rawValue, comment: "")
            }
        }
        
        // MARK: - Countable Items

        enum CountableItem: String, CaseIterable {
            case bed = "measures.plural.bed"
            case room = "measures.plural.room"
            case bathroom = "measures.plural.bathroom"
            case person = "measures.plural.person"
            case place = "measures.plural.place"
            
            func localized(count: Int) -> String {
                if L10n.isRussian {
                    let pluralForm = RussianPluralization.getPluralForm(for: count)
                    let key = "\(self.rawValue).\(pluralForm.rawValue)"
                    return NSLocalizedString(key, comment: "")
                } else if L10n.isKyrgyz {
                    let key = "\(self.rawValue).other"
                    return NSLocalizedString(key, comment: "")
                } else {
                    let pluralForm = count == 1 ? "one" : "other"
                    let key = "\(self.rawValue).\(pluralForm)"
                    return NSLocalizedString(key, comment: "")
                }
            }
            
            func localizedWithNumber(count: Int) -> String {
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = .decimal
                numberFormatter.locale = Locale.current
                
                if L10n.isRussian {
                    numberFormatter.groupingSeparator = " "
                    numberFormatter.decimalSeparator = ","
                } else if L10n.isKyrgyz {
                    numberFormatter.groupingSeparator = " "
                    numberFormatter.decimalSeparator = ","
                }
                
                let formattedNumber = numberFormatter.string(from: NSNumber(value: count)) ?? "\(count)"
                return "\(formattedNumber) \(self.localized(count: count))"
            }
        }
        
        // MARK: - Unified Helper Functions

        static func formatPrice(_ amount: Double, period: Price) -> String {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.locale = Locale.current
            
            if L10n.isRussian || L10n.isKyrgyz {
                formatter.groupingSeparator = " "
                formatter.decimalSeparator = ","
                formatter.maximumFractionDigits = 0
                
                let formattedAmount = formatter.string(from: NSNumber(value: amount)) ?? "\(Int(amount))"
                
                if L10n.isKyrgyz {
                    return "\(formattedAmount) сом \(period.localized)"
                } else {
                    return "\(formattedAmount) с \(period.localized)"
                }
            } else {
                formatter.currencySymbol = "$"
                formatter.numberStyle = .currency
                let formattedAmount = formatter.string(from: NSNumber(value: amount)) ?? "$\(Int(amount))"
                return "\(formattedAmount) \(period.localized)"
            }
        }
        
        static func formatArea(_ area: Double) -> String {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 1
            formatter.locale = Locale.current
            
            if L10n.isRussian || L10n.isKyrgyz {
                formatter.decimalSeparator = ","
                formatter.groupingSeparator = " "
            }
            
            let formattedArea = formatter.string(from: NSNumber(value: area)) ?? "\(area)"
            return "\(formattedArea) \(Unit.squareMeters.localized)"
        }
        
        static func formatDistance(_ distance: Int, unit: Unit = .meters) -> String {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.locale = Locale.current
            
            if L10n.isRussian || L10n.isKyrgyz {
                formatter.groupingSeparator = " "
            }
            
            let formattedDistance = formatter.string(from: NSNumber(value: distance)) ?? "\(distance)"
            return "\(formattedDistance) \(unit.localized)"
        }
        
        static func formatCapacity(_ count: Int) -> String {
            return CountableItem.person.localizedWithNumber(count: count)
        }
        
        static func formatPlaces(_ count: Int) -> String {
            return CountableItem.place.localizedWithNumber(count: count)
        }
        
        static func formatRooms(_ count: Int) -> String {
            return CountableItem.room.localizedWithNumber(count: count)
        }
        
        static func formatBeds(_ count: Int) -> String {
            return CountableItem.bed.localizedWithNumber(count: count)
        }
        
        static func formatBathrooms(_ count: Int) -> String {
            return CountableItem.bathroom.localizedWithNumber(count: count)
        }
    }
}

// MARK: - Russian Pluralization Rules

enum RussianPluralization {
    enum PluralForm: String {
        case one
        case few
        case many
    }
    
    static func getPluralForm(for count: Int) -> PluralForm {
        let absCount = abs(count)
        
        if (absCount % 100) >= 11 && (absCount % 100) <= 14 {
            return .many
        }
        
        switch absCount % 10 {
        case 1:
            return .one
        case 2, 3, 4:
            return .few
        default:
            return .many
        }
    }
}
