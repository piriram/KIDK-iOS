//
//  SettingsCoordinator.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/13/25.
//

import UIKit

final class SettingsCoordinator: BaseCoordinator {
    
    private let user: User
    
    init(navigationController: UINavigationController, user: User) {
        self.user = user
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        let viewController = UIViewController()
        viewController.view.backgroundColor = UIColor(hex: "#1C1C1E")
        navigationController.setViewControllers([viewController], animated: false)
    }
}
