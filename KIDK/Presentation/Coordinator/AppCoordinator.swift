//
//  AppCoordinator.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/13/25.
//

import UIKit
import RxSwift

final class AppCoordinator: BaseCoordinator {
    
    private let window: UIWindow
    private let authRepository: AuthRepositoryProtocol
    
    init(window: UIWindow, authRepository: AuthRepositoryProtocol = AuthRepository()) {
        self.window = window
        self.authRepository = authRepository
        let navController = UINavigationController()
        navController.setNavigationBarHidden(true, animated: false)
        super.init(navigationController: navController)
    }
    
    override func start() {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        checkAuthenticationStatus()
    }
    
    private func checkAuthenticationStatus() {
        if authRepository.isAutoLoginEnabled() {
            authRepository.getCurrentUser()
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { [weak self] user in
                    if let user = user {
                        self?.debugLog("Auto-login with user: \(user.name)")
                        self?.showMainFlow(user: user)
                    } else {
                        self?.debugLog("No saved user, showing login")
                        self?.showLogin()
                    }
                }, onError: { [weak self] error in
                    self?.debugError("Failed to get current user", error: error)
                    self?.showLogin()
                })
                .disposed(by: disposeBag)
        } else {
            debugLog("Auto-login disabled, showing login")
            showLogin()
        }
    }
    
    private func showLogin() {
        let authCoordinator = AuthCoordinator(
            navigationController: navigationController,
            authRepository: authRepository
        )
        authCoordinator.delegate = self
        addChildCoordinator(authCoordinator)
        authCoordinator.start()
    }
    
    private func showMainFlow(user: User) {
        let mainTabBarCoordinator = MainTabBarCoordinator(navigationController: navigationController, user: user)
        mainTabBarCoordinator.delegate = self
        addChildCoordinator(mainTabBarCoordinator)
        mainTabBarCoordinator.start()
    }
}

extension AppCoordinator: AuthCoordinatorDelegate {
    func authCoordinatorDidFinish(_ coordinator: AuthCoordinator, user: User) {
        removeChildCoordinator(coordinator)
        showMainFlow(user: user)
    }
}

extension AppCoordinator: MainTabBarCoordinatorDelegate {
    func mainTabBarCoordinatorDidLogout(_ coordinator: MainTabBarCoordinator) {
        removeChildCoordinator(coordinator)
        debugSuccess("Returning to login screen")
        showLogin()
    }
}
