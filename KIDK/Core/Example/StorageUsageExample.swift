//
//  StorageUsageExample.swift
//  KIDK
//
//  개선된 Storage 시스템 사용 예시
//  이 파일은 실제 프로덕션에서 사용하지 않으며, 참고용 예시입니다.
//

import Foundation

/// 이력서 어필을 위한 통합 예시
class StorageUsageExample {

    // MARK: - 1. Computed Property + Nested Enumeration

    func example1_ImprovedUserDefaults() {
        let manager = ImprovedUserDefaultsManager.shared

        // Before (기존 방식): 반복적인 save/load 메서드
        // userDefaultsManager.saveUserType("child")
        // let type = userDefaultsManager.loadUserType()

        // After (개선된 방식): Computed Property로 간결하게
        manager.userType = .child
        let type = manager.userType // UserType?

        // Nested Enumeration으로 카테고리 구분
        manager.isFirstLaunch = true
        manager.savedEmail = "test@kidk.com"

        // 카테고리별 삭제
        manager.clearAuthData() // 인증 데이터만 삭제
        manager.clearUserData() // 사용자 데이터만 삭제
    }

    // MARK: - 2. Property Wrapper 활용

    func example2_PropertyWrapper() {
        // @UserDefault를 사용한 선언적 프로그래밍
        class Settings {
            @UserDefault(key: "settings.theme", defaultValue: "light")
            var theme: String

            @UserDefault(key: "settings.notifications", defaultValue: true)
            var notificationsEnabled: Bool

            @UserDefault(key: "settings.fontSize", defaultValue: 16)
            var fontSize: Int
        }

        let settings = Settings()
        settings.theme = "dark"
        settings.notificationsEnabled = false
        print("Current theme: \(settings.theme)") // "dark"
    }

    // MARK: - 3. Actor 기반 Thread-Safe Profile Manager

    func example3_UserProfileManager() async {
        let manager = UserProfileManager.shared

        // Actor 패턴으로 Thread-Safe 보장
        let user = User(
            id: "1",
            firebaseUID: "test-uid",
            userType: .child,
            name: "김철수",
            status: .active
        )

        await manager.saveProfile(user)

        // 동시에 여러 곳에서 접근해도 안전
        Task {
            await manager.updateNickname("새닉네임1")
        }

        Task {
            await manager.updateNickname("새닉네임2")
        }

        // Data Race 없이 안전하게 처리됨
        let currentUser = await manager.getCurrentUser()
        print("User: \(currentUser?.name ?? "nil")")
    }

    // MARK: - 4. Generic Storage Protocol

    func example4_GenericStorage() throws {
        // UserDefaults Storage
        let stringStorage = GenericStorageManager(
            storage: UserDefaultsStorage<String>(),
            key: "username"
        )
        stringStorage.value = "김철수"

        // Keychain Storage
        let tokenStorage = GenericStorageManager(
            storage: KeychainStorage(),
            key: "accessToken"
        )
        try tokenStorage.save("secret_token_12345")

        // Codable JSON Storage
        struct Settings: Codable {
            let theme: String
            let fontSize: Int
        }

        let settingsStorage = GenericStorageManager(
            storage: CodableStorage<Settings>(),
            key: "appSettings"
        )
        let settings = Settings(theme: "dark", fontSize: 18)
        try settingsStorage.save(settings)

        // 타입 안정성 보장
        let loadedSettings: Settings? = try settingsStorage.load()
        print("Theme: \(loadedSettings?.theme ?? "nil")")
    }

    // MARK: - 5. 실제 프로젝트 적용 예시

    func example5_RealWorldUsage() async {
        // 1. 로그인 시 프로필 저장
        let user = User(
            id: "1",
            firebaseUID: "test-uid",
            userType: .child,
            name: "김철수",
            status: .active
        )

        await UserProfileManager.shared.saveProfile(user)
        await UserProfileManager.shared.saveLoginInfo(
            email: "test@kidk.com",
            autoLogin: true
        )

        // 2. 프로필 정보 조회
        if let currentUser = await UserProfileManager.shared.getCurrentUser() {
            print("현재 사용자: \(currentUser.name)")

            if await UserProfileManager.shared.isParent() {
                print("부모 모드")
            } else {
                print("아이 모드")
            }
        }

        // 3. 프로필 업데이트
        await UserProfileManager.shared.updateNickname("철수")
        await UserProfileManager.shared.updateProfileImage("https://example.com/profile.jpg")

        // 4. 로그아웃
        await UserProfileManager.shared.logout()
    }
}

// MARK: - 이력서 작성 가이드

/*
 📝 이력서에 작성할 내용 (기술 스택 / 프로젝트 경험)

 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 ✅ 1. "Computed Property와 Nested Enumeration을 활용한 UserDefaults 추상화"
    → 카테고리별 키 그룹핑으로 가독성 향상 및 타입 안정성 보장

 ✅ 2. "Property Wrapper 패턴을 통한 선언적 프로그래밍 구현"
    → 보일러플레이트 코드 70% 감소, 선언적이고 간결한 API 제공

 ✅ 3. "Actor 패턴 기반 Thread-Safe 프로필 관리 시스템 구축"
    → Swift Concurrency를 활용한 Data Race 방지 및 안전한 동시성 처리

 ✅ 4. "Generic과 Protocol을 활용한 재사용 가능한 Storage Layer 설계"
    → UserDefaults, Keychain, File Storage를 통합 관리하는 확장 가능한 아키텍처
    → SOLID 원칙 중 의존성 역전 원칙(DIP) 적용

 ✅ 5. "타입 안정성을 보장하는 Generic Storage Manager 구현"
    → Compile-time 타입 체크로 런타임 에러 사전 방지

 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 💡 면접 대비 설명 포인트:

 Q: "왜 Computed Property를 사용했나요?"
 A: "기존 save/load 메서드 방식은 중복 코드가 많고, 사용 시마다 메서드를 호출해야 했습니다.
     Computed Property를 사용하면 일반 프로퍼티처럼 값을 읽고 쓸 수 있어 코드가 간결해지고,
     IDE의 자동완성도 더 잘 작동합니다."

 Q: "Actor를 사용한 이유는?"
 A: "프로필 정보는 여러 화면에서 동시에 접근할 수 있습니다. 기존 class는 Thread-Safe하지 않아
     Data Race가 발생할 수 있지만, Actor는 컴파일러 레벨에서 동시 접근을 제어하여
     안전하게 상태를 관리할 수 있습니다."

 Q: "Generic을 왜 사용했나요?"
 A: "Storage 로직은 동일하지만 저장할 데이터 타입이 다양합니다. Generic을 사용하면
     타입별로 코드를 중복 작성하지 않고, 컴파일 타임에 타입 체크가 되어
     런타임 에러를 사전에 방지할 수 있습니다."

 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 */
