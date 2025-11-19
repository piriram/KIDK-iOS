//
//  SavingsCoordinator.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/19/25.
//

import UIKit
import RxSwift

final class SavingsCoordinator: BaseCoordinator {

    override func start() {
        let savingsRepository = SavingsRepository.shared
        let viewModel = SavingsViewModel(savingsRepository: savingsRepository)
        let viewController = SavingsViewController(viewModel: viewModel)

        navigationController.setViewControllers([viewController], animated: false)
    }
}
