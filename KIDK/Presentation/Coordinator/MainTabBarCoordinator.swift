import UIKit
import RxSwift

protocol MainTabBarCoordinatorDelegate: AnyObject {
    func mainTabBarCoordinatorDidLogout(_ coordinator: MainTabBarCoordinator)
}

final class MainTabBarCoordinator: BaseCoordinator {
    
    weak var delegate: MainTabBarCoordinatorDelegate?
    
    private let user: User
    private var navigationStateControllers: [NavigationStateController] = []
    
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
        navigationStateControllers.removeAll()

        let accountNav = UINavigationController()
        configureNavigationState(for: accountNav, in: tabBarController)
        let accountCoordinator = AccountCoordinator(navigationController: accountNav, user: user)
        addChildCoordinator(accountCoordinator)
        accountCoordinator.start()

        let missionNav = UINavigationController()
        configureNavigationState(for: missionNav, in: tabBarController)
        let missionCoordinator = MissionCoordinator(navigationController: missionNav, user: user)
        addChildCoordinator(missionCoordinator)
        missionCoordinator.start()

        let settingsNav = UINavigationController()
        configureNavigationState(for: settingsNav, in: tabBarController)
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
        navigationStateControllers.removeAll()

        // Tab 0: 승인 대기
        let approvalNav = UINavigationController()
        configureNavigationState(for: approvalNav, in: tabBarController)
        let missionRepository = MissionRepository(currentUserId: user.id)
        let approvalViewModel = ParentApprovalViewModel(missionRepository: missionRepository)
        let approvalVC = ParentApprovalViewController(viewModel: approvalViewModel)
        approvalNav.setViewControllers([approvalVC], animated: false)

        // Tab 1: 아이 지갑
        let walletNav = UINavigationController()
        configureNavigationState(for: walletNav, in: tabBarController)
        let accountRepository = AccountRepository.shared
        let transactionRepository = TransactionRepository.shared
        let walletViewModel = ParentChildWalletViewModel(
            accountRepository: accountRepository,
            transactionRepository: transactionRepository
        )
        let walletVC = ParentChildWalletViewController(viewModel: walletViewModel)
        walletNav.setViewControllers([walletVC], animated: false)

        // Tab 2: 아이 정보
        let infoNav = UINavigationController()
        configureNavigationState(for: infoNav, in: tabBarController)
        let infoViewModel = ParentChildInfoViewModel(
            accountRepository: accountRepository,
            transactionRepository: transactionRepository,
            missionRepository: missionRepository
        )
        let infoVC = ParentChildInfoViewController(viewModel: infoViewModel)
        infoNav.setViewControllers([infoVC], animated: false)

        tabBarController.viewControllers = [approvalNav, walletNav, infoNav]
        tabBarController.configureTabBarItems()

        navigationController.setViewControllers([tabBarController], animated: false)

        debugSuccess("Parent tab bar initialized with 3 tabs")
    }

    private func configureNavigationState(for navigationController: UINavigationController, in tabBarController: UITabBarController) {
        let stateController = NavigationStateController(tabBarController: tabBarController)
        navigationController.delegate = stateController
        navigationStateControllers.append(stateController)
    }
}

extension MainTabBarCoordinator: SettingsCoordinatorDelegate {
    func settingsCoordinatorDidLogout(_ coordinator: SettingsCoordinator) {
        debugLog("Logout triggered from settings")
        delegate?.mainTabBarCoordinatorDidLogout(self)
    }
}
