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
        // Check user type and create appropriate tab bar controller
        if user.userType == .parent {
            setupParentTabBar()
        } else {
            setupChildTabBar()
        }
    }

    // MARK: - Child Tab Bar Setup

    private func setupChildTabBar() {
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
        tabBarController.configureTabBarItems()

        navigationController.setViewControllers([tabBarController], animated: false)

        debugSuccess("Child tab bar initialized with 3 tabs")
    }

    // MARK: - Parent Tab Bar Setup

    private func setupParentTabBar() {
        let tabBarController = ParentTabBarController()

        // Tab 0: Approval (승인 대기)
        let approvalNav = UINavigationController()
        let missionRepository = MissionRepository(currentUserId: user.id)
        let approvalViewModel = ParentApprovalViewModel(missionRepository: missionRepository)
        let approvalVC = ParentApprovalViewController(viewModel: approvalViewModel)
        approvalNav.viewControllers = [approvalVC]

        // Tab 1: Child Wallet (아이 지갑)
        let walletNav = UINavigationController()
        let walletVC = ParentChildWalletViewController()
        walletNav.viewControllers = [walletVC]

        // Tab 2: Child Info (아이 정보)
        let infoNav = UINavigationController()
        let infoVC = ParentChildInfoViewController()
        infoNav.viewControllers = [infoVC]

        tabBarController.viewControllers = [approvalNav, walletNav, infoNav]
        tabBarController.configureTabBarItems()

        navigationController.setViewControllers([tabBarController], animated: false)

        debugSuccess("Parent tab bar initialized with 3 tabs")
    }
}

extension MainTabBarCoordinator: SettingsCoordinatorDelegate {
    func settingsCoordinatorDidLogout(_ coordinator: SettingsCoordinator) {
        debugLog("Logout triggered from settings")
        delegate?.mainTabBarCoordinatorDidLogout(self)
    }
}
