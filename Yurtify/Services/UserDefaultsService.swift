//
//  UserDefaultsService.swift
//  Yurtify
//
//  Created by dark type on 14.06.2025.
//

import Foundation

final class UserDefaultsService {
    private enum Keys {
        static let shouldBeAuthenticated = "shouldBeAuthenticated"
    }

    var shouldBeAuthenticated: Bool {
        UserDefaults.standard.bool(forKey: Keys.shouldBeAuthenticated)
    }

    func setShouldBeAuthenticated(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: Keys.shouldBeAuthenticated)
    }
}
