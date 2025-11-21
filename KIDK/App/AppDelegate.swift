//
//  AppDelegate.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/13/25.
//
import UIKit
import IQKeyboardManagerSwift
import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        configureRealm()
        configureIQKeyboardManager()

        return true
    }

    private func configureRealm() {
        let config = Realm.Configuration(
            schemaVersion: 2, // 스키마 버전 증가
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 2 {
                    // currentAmount 프로퍼티가 추가된 경우
                    migration.enumerateObjects(ofType: "MissionEntity") { oldObject, newObject in
                        // currentAmount가 없으면 기본값 0 설정
                        if oldObject?["currentAmount"] == nil {
                            newObject?["currentAmount"] = 0
                        }
                    }
                }
            },
            deleteRealmIfMigrationNeeded: true // 개발 중이므로 마이그레이션 실패시 DB 삭제
        )

        Realm.Configuration.defaultConfiguration = config

        // Realm 초기화 테스트
        do {
            _ = try Realm()
            print("✅ Realm initialized successfully")
        } catch {
            print("❌ Failed to initialize Realm: \(error)")
        }
    }

    private func configureIQKeyboardManager() {
        IQKeyboardManager.shared.isEnabled = true
        IQKeyboardManager.shared.resignOnTouchOutside = true
        IQKeyboardManager.shared.keyboardDistance = 16
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}
