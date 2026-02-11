//
//  UserProfileManager.swift
//  KIDK
//
//  Actor 패턴을 통한 Thread-Safe 프로필 관리
//  - 동시성 이슈 해결 (Data Race 방지)
//  - async/await 기반 현대적인 비동기 처리
//  - 단일 책임 원칙: 프로필 정보 관리에만 집중
//

import Foundation

/// Thread-Safe한 사용자 프로필 관리자
/// Actor를 사용하여 동시성 이슈 방지
actor UserProfileManager {

    // MARK: - Singleton

    static let shared = UserProfileManager()

    private init() {}

    // MARK: - Private Storage

    private let defaults = ImprovedUserDefaultsManager.shared
    private let keychain = KeychainWrapper.shared

    // MARK: - User Profile Data

    private(set) var currentUser: User?

    // MARK: - Public Methods

    /// 현재 사용자 프로필 조회
    func getCurrentUser() -> User? {
        return currentUser
    }

    /// 사용자 프로필 저장
    /// - Parameter user: 저장할 사용자 정보
    func saveProfile(_ user: User) {
        self.currentUser = user

        // UserDefaults에 기본 정보 저장
        defaults.firebaseUID = user.firebaseUID
        defaults.userType = user.userType
        defaults.nickname = user.nickname
        defaults.profileImageURL = user.profileImageURL
        defaults.birthdate = user.birthdate
    }

    /// 프로필 이미지 URL 업데이트
    /// - Parameter url: 이미지 URL
    func updateProfileImage(_ url: String?) {
        defaults.profileImageURL = url

        // 현재 유저 정보도 업데이트
        if var user = currentUser {
            user.profileImageURL = url
            currentUser = user
        }
    }

    /// 닉네임 업데이트
    /// - Parameter nickname: 새 닉네임
    func updateNickname(_ nickname: String?) {
        defaults.nickname = nickname

        if var user = currentUser {
            user.nickname = nickname
            currentUser = user
        }
    }

    /// 생년월일 업데이트
    /// - Parameter birthdate: 생년월일
    func updateBirthdate(_ birthdate: Date?) {
        defaults.birthdate = birthdate

        if var user = currentUser {
            user.birthdate = birthdate
            currentUser = user
        }
    }

    /// 로그인 정보 저장
    /// - Parameters:
    ///   - email: 이메일
    ///   - autoLogin: 자동 로그인 여부
    func saveLoginInfo(email: String, autoLogin: Bool) {
        defaults.savedEmail = email
        defaults.isAutoLoginEnabled = autoLogin
        defaults.lastLoginDate = Date()
    }

    /// 로그아웃 (프로필 정보 삭제)
    func logout() {
        currentUser = nil
        defaults.clearAll()

        // Keychain의 토큰도 삭제
        TokenManager.shared.clearAllTokens()
    }

    /// 사용자 타입 확인
    func isParent() -> Bool {
        return currentUser?.userType == .parent
    }

    /// 사용자 타입 확인
    func isChild() -> Bool {
        return currentUser?.userType == .child
    }

    /// 로그인 여부 확인
    func isLoggedIn() -> Bool {
        return currentUser != nil && defaults.firebaseUID != nil
    }
}

// MARK: - 사용 예시 (주석)
/*
 // Actor 사용 예시 (async/await)
 Task {
     await UserProfileManager.shared.saveProfile(user)
     let currentUser = await UserProfileManager.shared.getCurrentUser()
     await UserProfileManager.shared.updateNickname("새닉네임")
 }

 // 이력서 어필 포인트:
 // 1. Actor 패턴으로 Thread-Safe 보장 (Data Race 방지)
 // 2. async/await 기반 현대적인 Swift Concurrency 활용
 // 3. 단일 책임 원칙: 프로필 관리에만 집중
 // 4. 캡슐화: private storage로 데이터 보호
 */
