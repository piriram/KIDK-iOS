//
//  MissionCoordinator.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/13/25.
//

import UIKit
import RxSwift

final class MissionCoordinator: BaseCoordinator {
    
    private let user: User
    
    init(navigationController: UINavigationController, user: User) {
        self.user = user
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        let viewModel = MissionViewModel(user: user)
        let viewController = MissionViewController(viewModel: viewModel)
        
        viewModel.navigateToKIDKCity
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.showKIDKCity()
            })
            .disposed(by: disposeBag)
        
        navigationController.setViewControllers([viewController], animated: false)
    }
    
    private func showKIDKCity() {
        let viewModel = KIDKCityViewModel(user: user)
        let viewController = KIDKCityViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
        debugLog("Navigated to KIDK City")
    }
}
