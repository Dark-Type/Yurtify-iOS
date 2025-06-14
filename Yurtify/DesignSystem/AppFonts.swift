import SwiftUI

enum AppFonts {
    // MARK: - Font Names (exact names from your imported fonts)
    private enum FontName: String {
        case interBold = "Inter_Bold"
        case interExtraBold = "Inter_ExtraBold"
        case interSemiBold = "Inter_SemiBold"
        case latoBold = "Lato_Bold"
        case latoRegular = "Lato_Regular"
        case poppinsMedium = "Poppins_Medium"
        case poppinsRegular = "Poppins_Regular"
        case poppinsSemiBold = "Poppins_SemiBold"
    }
    
    // MARK: - Font Families
    enum Family {
        case inter
        case lato
        case poppins
    }
    
    // MARK: - Font Weights
    enum Weight {
        case regular
        case medium
        case semiBold
        case bold
        case extraBold
        
        func fontName(for family: Family) -> String {
            switch family {
            case .inter:
                switch self {
                case .regular, .medium:
                    return FontName.interSemiBold.rawValue
                case .semiBold:
                    return FontName.interSemiBold.rawValue
                case .bold:
                    return FontName.interBold.rawValue
                case .extraBold:
                    return FontName.interExtraBold.rawValue
                }
            case .lato:
                switch self {
                case .regular, .medium, .semiBold:
                    return FontName.latoRegular.rawValue
                case .bold, .extraBold:
                    return FontName.latoBold.rawValue
                }
            case .poppins:
                switch self {
                case .regular:
                    return FontName.poppinsRegular.rawValue
                case .medium:
                    return FontName.poppinsMedium.rawValue
                case .semiBold, .bold, .extraBold:
                    return FontName.poppinsSemiBold.rawValue
                }
            }
        }
    }
    
    // MARK: - Custom Font Helper
    private static func customFont(family: Family, weight: Weight, size: CGFloat) -> Font {
        let fontName = weight.fontName(for: family)
        return Font.custom(fontName, size: size)
    }
    
    // MARK: - Typography Scale (Using Inter as primary)
    static func largeTitle(_ weight: Weight = .semiBold) -> Font {
        return customFont(family: .inter, weight: weight, size: 34)
    }
    
    static func title1(_ weight: Weight = .semiBold) -> Font {
        return customFont(family: .inter, weight: weight, size: 28)
    }
    
    static func title2(_ weight: Weight = .semiBold) -> Font {
        return customFont(family: .inter, weight: weight, size: 22)
    }
    
    static func title3(_ weight: Weight = .semiBold) -> Font {
        return customFont(family: .inter, weight: weight, size: 20)
    }
    
    static func headline(_ weight: Weight = .semiBold) -> Font {
        return customFont(family: .inter, weight: weight, size: 17)
    }
    
    static func body(_ weight: Weight = .regular) -> Font {
        return customFont(family: .inter, weight: weight, size: 17)
    }
    
    static func callout(_ weight: Weight = .regular) -> Font {
        return customFont(family: .inter, weight: weight, size: 16)
    }
    
    static func subheadline(_ weight: Weight = .regular) -> Font {
        return customFont(family: .inter, weight: weight, size: 15)
    }
    
    static func footnote(_ weight: Weight = .regular) -> Font {
        return customFont(family: .inter, weight: weight, size: 13)
    }
    
    static func caption1(_ weight: Weight = .regular) -> Font {
        return customFont(family: .inter, weight: weight, size: 12)
    }
    
    static func caption2(_ weight: Weight = .regular) -> Font {
        return customFont(family: .inter, weight: weight, size: 11)
    }
    
    // MARK: - Specific Font Family Methods
    static func inter(size: CGFloat, weight: Weight = .semiBold) -> Font {
        return customFont(family: .inter, weight: weight, size: size)
    }
    
    static func lato(size: CGFloat, weight: Weight = .regular) -> Font {
        return customFont(family: .lato, weight: weight, size: size)
    }
    
    static func poppins(size: CGFloat, weight: Weight = .regular) -> Font {
        return customFont(family: .poppins, weight: weight, size: size)
    }
    
    // MARK: - Direct Font Access (for specific use cases)
    static func interBold(size: CGFloat) -> Font {
        return Font.custom(FontName.interBold.rawValue, size: size)
    }
    
    static func interExtraBold(size: CGFloat) -> Font {
        return Font.custom(FontName.interExtraBold.rawValue, size: size)
    }
    
    static func interSemiBold(size: CGFloat) -> Font {
        return Font.custom(FontName.interSemiBold.rawValue, size: size)
    }
    
    static func latoBold(size: CGFloat) -> Font {
        return Font.custom(FontName.latoBold.rawValue, size: size)
    }
    
    static func latoRegular(size: CGFloat) -> Font {
        return Font.custom(FontName.latoRegular.rawValue, size: size)
    }
    
    static func poppinsMedium(size: CGFloat) -> Font {
        return Font.custom(FontName.poppinsMedium.rawValue, size: size)
    }
    
    static func poppinsRegular(size: CGFloat) -> Font {
        return Font.custom(FontName.poppinsRegular.rawValue, size: size)
    }
    
    static func poppinsSemiBold(size: CGFloat) -> Font {
        return Font.custom(FontName.poppinsSemiBold.rawValue, size: size)
    }
}

// MARK: - Extension for easy usage
extension Font {
    static let app = AppFonts.self
}
