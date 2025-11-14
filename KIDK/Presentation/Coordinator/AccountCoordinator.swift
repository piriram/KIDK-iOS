//
//  AccountCoordinator.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/13/25.
//

import UIKit

final class AccountCoordinator: BaseCoordinator {
    
    private let user: User
    
    init(navigationController: UINavigationController, user: User) {
        self.user = user
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        let viewModel = AccountViewModel(user: user)
        let viewController = AccountViewController(viewModel: viewModel)
        navigationController.setViewControllers([viewController], animated: false)
    }
}
