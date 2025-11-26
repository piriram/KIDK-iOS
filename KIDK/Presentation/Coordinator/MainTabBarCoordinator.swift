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
        // userType에 따라 다른 탭바 사용
        if user.userType == .parent {
            startParentFlow()
        } else {
            startChildFlow()
        }
    }

    private func startChildFlow() {
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

    private func startParentFlow() {
        let tabBarController = ParentTabBarController()

        // Tab 0: 승인 대기
        let approvalNav = UINavigationController()
        approvalNav.setNavigationBarHidden(true, animated: false)
        let missionRepository = MissionRepository(currentUserId: user.id)
        let approvalViewModel = ParentApprovalViewModel(missionRepository: missionRepository)
        let approvalVC = ParentApprovalViewController(viewModel: approvalViewModel)
        approvalNav.setViewControllers([approvalVC], animated: false)

        // Tab 1: 아이 지갑
        let walletNav = UINavigationController()
        walletNav.setNavigationBarHidden(true, animated: false)
        let walletVC = ParentChildWalletViewController()
        walletNav.setViewControllers([walletVC], animated: false)

        // Tab 2: 아이 정보
        let infoNav = UINavigationController()
        infoNav.setNavigationBarHidden(true, animated: false)
        let infoVC = ParentChildInfoViewController()
        infoNav.setViewControllers([infoVC], animated: false)

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
