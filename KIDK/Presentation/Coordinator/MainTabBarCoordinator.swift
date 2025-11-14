//
//  MainTabBarCoordinator.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/13/25.
//

import UIKit
import RxSwift

protocol MainTabBarCoordinatorDelegate: AnyObject {
    func mainTabBarCoordinatorDidLogout(_ coordinator: MainTabBarCoordinator)
}

final class MainTabBarCoordinator: BaseCoordinator {
    
    weak var delegate: MainTabBarCoordinatorDelegate?
    
    private let user: User
    
    init(navigationController: UINavigationController, user: User) {
        self.user = user
        super.init(navigationController: navigationController)
    }
    
    override func start() {
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
        settingsCoordinator.delegate = self
        addChildCoordinator(settingsCoordinator)
        settingsCoordinator.start()
        
        tabBarController.viewControllers = [accountNav, missionNav, settingsNav]
        
        navigationController.setViewControllers([tabBarController], animated: false)
        
        debugSuccess("Main tab bar initialized with 3 tabs")
    }
}

extension MainTabBarCoordinator: SettingsCoordinatorDelegate {
    func settingsCoordinatorDidLogout(_ coordinator: SettingsCoordinator) {
        debugLog("Logout triggered from settings")
        delegate?.mainTabBarCoordinatorDidLogout(self)
    }
}
