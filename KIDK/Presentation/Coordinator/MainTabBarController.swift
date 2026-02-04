//
//  MainTabBarController.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/13/25.
//

import UIKit

final class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }
    
    private func setupTabBar() {
        tabBar.backgroundColor = .kidkDarkBackground
        tabBar.tintColor = .kidkPink
        tabBar.unselectedItemTintColor = .kidkGray
        tabBar.isTranslucent = false
        
        guard let items = tabBar.items else { return }
        
        items[0].title = Strings.TabBar.account
        items[0].image = UIImage(named: "tab_account_unselected")
        items[0].selectedImage = UIImage(named: "tab_account_selected")
        
        items[1].title = Strings.TabBar.mission
        items[1].image = UIImage(named: "tab_mission_unselected")
        items[1].selectedImage = UIImage(named: "tab_mission_selected")
        
        items[2].title = Strings.TabBar.settings
        items[2].image = UIImage(named: "tab_settings_unselected")
        items[2].selectedImage = UIImage(named: "tab_settings_selected")
    }
}
