//
//  SettingsCoordinator.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/13/25.
//

import UIKit

protocol SettingsCoordinatorDelegate: AnyObject {
    func settingsCoordinatorDidLogout(_ coordinator: SettingsCoordinator)
}

final class SettingsCoordinator: BaseCoordinator {
    
    weak var delegate: SettingsCoordinatorDelegate?
    
    private let user: User
    private let authRepository: AuthRepositoryProtocol
    
    init(navigationController: UINavigationController, user: User) {
        self.user = user
        self.authRepository = AuthRepository()
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        let viewController = SettingsViewController(authRepository: authRepository)
        viewController.coordinator = self
        navigationController.setViewControllers([viewController], animated: false)
    }
    
    func logout() {
        debugLog("Logout triggered from SettingsViewController")
        delegate?.settingsCoordinatorDidLogout(self)
    }
}
