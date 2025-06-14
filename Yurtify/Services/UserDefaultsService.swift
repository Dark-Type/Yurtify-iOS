//
//  UserDefaultsService.swift
//  Yurtify
//
//  Created by dark type on 14.06.2025.
//

import Foundation

class UserDefaultsService {
    private enum Keys {
        static let isFirstLaunch = "isFirstLaunch"
        static let isUserLoggedIn = "isUserLoggedIn"
        static let isGuestMode = "isGuestMode"
    }
    
    var isFirstLaunch: Bool {
        if UserDefaults.standard.object(forKey: Keys.isFirstLaunch) == nil {
            return true
        }
        return UserDefaults.standard.bool(forKey: Keys.isFirstLaunch)
    }
    
    var isUserLoggedIn: Bool {
        UserDefaults.standard.bool(forKey: Keys.isUserLoggedIn)
    }
    
    var isGuestMode: Bool {
        UserDefaults.standard.bool(forKey: Keys.isGuestMode)
    }
    
    func setFirstLaunch(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: Keys.isFirstLaunch)
    }
    
    func setUserLoggedIn(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: Keys.isUserLoggedIn)
    }
    
    func setGuestMode(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: Keys.isGuestMode)
    }
}
