//
//  TabItem.swift
//  Yurtify
//
//  Created by dark type on 15.06.2025.
//
import Foundation

enum TabItem: CaseIterable {
    case list
    case map
    case create
    case notifications
    case profile
    
    var tag: Int {
        switch self {
        case .list: return 0
        case .map: return 1
        case .create: return 2
        case .notifications: return 3
        case .profile: return 4
        }
    }
    
    var title: String {
        switch self {
        case .list: return L10n.TabBar.list
        case .map: return L10n.TabBar.map
        case .create: return L10n.TabBar.create
        case .notifications: return L10n.TabBar.notifications
        case .profile: return L10n.TabBar.profile
        }
    }
    
    var selectedIcon: AppIcons {
        switch self {
        case .list: return .listSelected
        case .map: return .mapSelected
        case .create: return .addSelected
        case .notifications: return .notificationsSelected
        case .profile: return .profileSelected
        }
    }
    
    var unselectedIcon: AppIcons {
        switch self {
        case .list: return .listUnselected
        case .map: return .mapUnselected
        case .create: return .addUnselected
        case .notifications: return .notificationsUnselected
        case .profile: return .profileUnselected
        }
    }
    
    var iconScale: CGFloat {
        switch self {
        case .list: return 0.9
        default: return 1.0
        }
    }
}
