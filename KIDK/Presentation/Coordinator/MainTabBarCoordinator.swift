//
//  MainTabBarCoordinator.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/13/25.
//

import UIKit
import RxSwift

final class MainTabBarCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    private let user: User
    private let disposeBag = DisposeBag()
    
    init(navigationController: UINavigationController, user: User) {
        self.navigationController = navigationController
        self.user = user
    }
    
    func start() {
        let tabBarController = MainTabBarController()
        
        let accountNav = UINavigationController()
        accountNav.setNavigationBarHidden(true, animated: false)
        let accountCoordinator = AccountCoordinator(navigationController: accountNav, user: user)
        addChildCoordinator(accountCoordinator)
        accountCoordinator.start()
        
        let missionNav = UINavigationController()
        missionNav.setNavigationBarHidden(true, animated: false)
        let missionCoordinator = MissionCoordinator(navigationController: missionNav, user: user)
        addChildCoordinator(missionCoordinator)
        missionCoordinator.start()
        
        let settingsNav = UINavigationController()
        settingsNav.setNavigationBarHidden(true, animated: false)
        let settingsCoordinator = SettingsCoordinator(navigationController: settingsNav, user: user)
        addChildCoordinator(settingsCoordinator)
        settingsCoordinator.start()
        
        tabBarController.viewControllers = [accountNav, missionNav, settingsNav]
        
        navigationController.setViewControllers([tabBarController], animated: true)
    }
}
