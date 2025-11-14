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
        if authRepository.isFirstLaunch() {
            showUserTypeSelection()
        } else {
            authRepository.getCurrentUser()
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { [weak self] user in
                    if let user = user {
                        self?.showMainFlow(user: user)
                    } else {
                        self?.showUserTypeSelection()
                    }
                }, onError: { [weak self] error in
                    self?.debugError("Failed to get current user", error: error)
                    self?.showUserTypeSelection()
                })
                .disposed(by: disposeBag)
        }
    }
    
    private func showUserTypeSelection() {
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
