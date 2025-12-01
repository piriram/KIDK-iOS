//
//  ImprovedUserDefaultsManager.swift
//  KIDK
//
//  Computed Property + Nested Enumeration을 활용한 UserDefaults 추상화
//  - 카테고리별 키 그룹핑으로 가독성 향상
//  - Computed Property로 간결한 API 제공
//  - 타입 안정성 보장
//

import Foundation

final class ImprovedUserDefaultsManager {

    static let shared = ImprovedUserDefaultsManager()

    private let storage = UserDefaults.standard

    private init() {}

    // MARK: - Nested Enumeration (카테고리별 키 그룹핑)

    private enum StorageKey {

        enum Auth: String {
            case firebaseUID = "auth.firebaseUID"
            case userType = "auth.userType"
            case isAutoLoginEnabled = "auth.isAutoLoginEnabled"
            case savedEmail = "auth.savedEmail"
            case lastLoginDate = "auth.lastLoginDate"
        }

        enum App: String {
            case isFirstLaunch = "app.isFirstLaunch"
            case appVersion = "app.version"
            case lastOpenedDate = "app.lastOpenedDate"
        }

        enum User: String {
            case profileImageURL = "user.profileImageURL"
            case nickname = "user.nickname"
            case birthdate = "user.birthdate"
        }
    }

    // MARK: - Computed Properties (인증 관련)

    var firebaseUID: String? {
        get { storage.string(forKey: StorageKey.Auth.firebaseUID.rawValue) }
        set { storage.set(newValue, forKey: StorageKey.Auth.firebaseUID.rawValue) }
    }

    var userType: UserType? {
        get {
            guard let rawValue = storage.string(forKey: StorageKey.Auth.userType.rawValue) else {
                return nil
            }
            return UserType(rawValue: rawValue)
        }
        set {
            storage.set(newValue?.rawValue, forKey: StorageKey.Auth.userType.rawValue)
        }
    }

    var isAutoLoginEnabled: Bool {
        get { storage.bool(forKey: StorageKey.Auth.isAutoLoginEnabled.rawValue) }
        set { storage.set(newValue, forKey: StorageKey.Auth.isAutoLoginEnabled.rawValue) }
    }

    var savedEmail: String? {
        get { storage.string(forKey: StorageKey.Auth.savedEmail.rawValue) }
        set { storage.set(newValue, forKey: StorageKey.Auth.savedEmail.rawValue) }
    }

    var lastLoginDate: Date? {
        get { storage.object(forKey: StorageKey.Auth.lastLoginDate.rawValue) as? Date }
        set { storage.set(newValue, forKey: StorageKey.Auth.lastLoginDate.rawValue) }
    }

    // MARK: - Computed Properties (앱 관련)

    var isFirstLaunch: Bool {
        get { storage.bool(forKey: StorageKey.App.isFirstLaunch.rawValue) }
        set { storage.set(newValue, forKey: StorageKey.App.isFirstLaunch.rawValue) }
    }

    var appVersion: String? {
        get { storage.string(forKey: StorageKey.App.appVersion.rawValue) }
        set { storage.set(newValue, forKey: StorageKey.App.appVersion.rawValue) }
    }

    var lastOpenedDate: Date? {
        get { storage.object(forKey: StorageKey.App.lastOpenedDate.rawValue) as? Date }
        set { storage.set(newValue, forKey: StorageKey.App.lastOpenedDate.rawValue) }
    }

    // MARK: - Computed Properties (사용자 프로필)

    var profileImageURL: String? {
        get { storage.string(forKey: StorageKey.User.profileImageURL.rawValue) }
        set { storage.set(newValue, forKey: StorageKey.User.profileImageURL.rawValue) }
    }

    var nickname: String? {
        get { storage.string(forKey: StorageKey.User.nickname.rawValue) }
        set { storage.set(newValue, forKey: StorageKey.User.nickname.rawValue) }
    }

    var birthdate: Date? {
        get { storage.object(forKey: StorageKey.User.birthdate.rawValue) as? Date }
        set { storage.set(newValue, forKey: StorageKey.User.birthdate.rawValue) }
    }

    // MARK: - Clear Methods (카테고리별 삭제)

    func clearAuthData() {
        firebaseUID = nil
        userType = nil
        isAutoLoginEnabled = false
        savedEmail = nil
        lastLoginDate = nil
    }

    func clearUserData() {
        profileImageURL = nil
        nickname = nil
        birthdate = nil
    }

    func clearAll() {
        clearAuthData()
        clearUserData()
        // App 데이터는 유지 (isFirstLaunch 등)
    }
}

// MARK: - 사용 예시 (주석)
/*
 // Before (기존 방식)
 userDefaultsManager.saveUserType("child")
 let type = userDefaultsManager.loadUserType()

 // After (개선된 방식)
 ImprovedUserDefaultsManager.shared.userType = .child
 let type = ImprovedUserDefaultsManager.shared.userType

 // 이력서 어필 포인트:
 // 1. Computed Property로 간결한 API 제공
 // 2. Nested Enumeration으로 키 관리 체계화
 // 3. 타입 안정성 보장 (UserType Enum 직접 사용)
 */
