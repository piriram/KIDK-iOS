import UIKit

protocol NavigationChromeConfigurable where Self: UIViewController {
    var prefersNavigationBarHidden: Bool { get }
    var prefersTabBarHidden: Bool { get }
}

extension NavigationChromeConfigurable {
    var prefersNavigationBarHidden: Bool { false }
    var prefersTabBarHidden: Bool { false }
}
