//
//  SceneDelegate.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/13/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var appCoordinator: AppCoordinator?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        appCoordinator = AppCoordinator(window: window)
        appCoordinator?.start()
        
        // 커스텀 폰트가 잘 등록됐는지 테스트용
//        debugPrintInstalledFonts()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }
}

// MARK: - Font Debug

private extension SceneDelegate {
    func debugPrintInstalledFonts() {
        #if DEBUG
        for family in UIFont.familyNames.sorted() {
            print("=== \(family) ===")
            for name in UIFont.fontNames(forFamilyName: family).sorted() {
                print("  \(name)")
            }
        }
        #endif
    }
}
