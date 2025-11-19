//
//  ParentTabBarController.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/19/25.
//

import UIKit

final class ParentTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBarAppearance()
    }

    private func setupTabBarAppearance() {
        view.backgroundColor = .kidkDarkBackground
        tabBar.backgroundColor = .kidkDarkBackground
        tabBar.tintColor = .kidkPink
        tabBar.unselectedItemTintColor = .kidkGray
        tabBar.isTranslucent = false
    }

    func configureTabBarItems() {
        guard let items = tabBar.items else {
            #if DEBUG
            print("⚠️ Parent tab bar items not available")
            #endif
            return
        }

        // Tab 0: Approval Waiting
        items[0].title = "승인 대기"
        items[0].image = UIImage(systemName: "checkmark.circle")?.withRenderingMode(.alwaysTemplate)
        items[0].selectedImage = UIImage(systemName: "checkmark.circle.fill")?.withRenderingMode(.alwaysTemplate)

        // Tab 1: Child Wallet
        items[1].title = "아이 지갑"
        items[1].image = UIImage(systemName: "wallet.pass")?.withRenderingMode(.alwaysTemplate)
        items[1].selectedImage = UIImage(systemName: "wallet.pass.fill")?.withRenderingMode(.alwaysTemplate)

        // Tab 2: Child Info
        items[2].title = "아이 정보"
        items[2].image = UIImage(systemName: "person.circle")?.withRenderingMode(.alwaysTemplate)
        items[2].selectedImage = UIImage(systemName: "person.circle.fill")?.withRenderingMode(.alwaysTemplate)
    }
}
