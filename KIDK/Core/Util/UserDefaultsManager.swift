//
//  UserDefaultsManager.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/13/25.
//

import Foundation

final class UserDefaultsManager {
    
    static let shared = UserDefaultsManager()
    
    private let defaults = UserDefaults.standard
    
    private init() {}
    
    enum Keys: String {
        case mockFirebaseUID
        case userType
        case isFirstLaunch
        case autoLoginToken
        case lastLoginDate
    }
    
    func saveMockFirebaseUID(_ uid: String) {
        defaults.set(uid, forKey: Keys.mockFirebaseUID.rawValue)
    }
    
    func loadMockFirebaseUID() -> String? {
        return defaults.string(forKey: Keys.mockFirebaseUID.rawValue)
    }
    
    func saveUserType(_ type: String) {
        defaults.set(type, forKey: Keys.userType.rawValue)
    }
    
    func loadUserType() -> String? {
        return defaults.string(forKey: Keys.userType.rawValue)
    }
    
    func saveIsFirstLaunch(_ isFirst: Bool) {
        defaults.set(isFirst, forKey: Keys.isFirstLaunch.rawValue)
    }
    
    func loadIsFirstLaunch() -> Bool {
        return defaults.bool(forKey: Keys.isFirstLaunch.rawValue)
    }
    
    func saveAutoLoginToken(_ token: String) {
        defaults.set(token, forKey: Keys.autoLoginToken.rawValue)
    }
    
    func loadAutoLoginToken() -> String? {
        return defaults.string(forKey: Keys.autoLoginToken.rawValue)
    }
    
    func saveLastLoginDate(_ date: Date) {
        defaults.set(date, forKey: Keys.lastLoginDate.rawValue)
    }
    
    func loadLastLoginDate() -> Date? {
        return defaults.object(forKey: Keys.lastLoginDate.rawValue) as? Date
    }
    
    func clearAll() {
        Keys.allCases.forEach { key in
            defaults.removeObject(forKey: key.rawValue)
        }
    }
}

extension UserDefaultsManager.Keys: CaseIterable {}
