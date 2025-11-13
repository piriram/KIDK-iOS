//
//  AppCoordinator.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/13/25.
//

import UIKit
import RxSwift

final class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    private let window: UIWindow
    private let authRepository: AuthRepositoryProtocol
    private let disposeBag = DisposeBag()
    
    init(
        window: UIWindow,
        authRepository: AuthRepositoryProtocol = AuthRepository()
    ) {
        self.window = window
        self.authRepository = authRepository
        self.navigationController = UINavigationController()
        self.navigationController.setNavigationBarHidden(true, animated: false)
    }
    
    func start() {
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
                }, onError: { [weak self] _ in
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
