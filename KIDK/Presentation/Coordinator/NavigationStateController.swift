import UIKit

final class NavigationStateController: NSObject, UINavigationControllerDelegate {

    weak var tabBarController: UITabBarController?

    init(tabBarController: UITabBarController?) {
        self.tabBarController = tabBarController
        super.init()
    }

    func navigationController(
        _ navigationController: UINavigationController,
        willShow viewController: UIViewController,
        animated: Bool
    ) {
        let targetViewController = resolvedTarget(from: viewController)
        let chromeConfig = targetViewController as? NavigationChromeConfigurable

        let shouldHideNavigationBar = chromeConfig?.prefersNavigationBarHidden ?? false
        let shouldHideTabBar = chromeConfig?.prefersTabBarHidden ?? false

        navigationController.setNavigationBarHidden(shouldHideNavigationBar, animated: animated)
        tabBarController?.tabBar.isHidden = shouldHideTabBar
    }

    private func resolvedTarget(from viewController: UIViewController) -> UIViewController {
        if let navigationController = viewController as? UINavigationController,
           let topViewController = navigationController.topViewController {
            return topViewController
        }

        return viewController
    }
}
