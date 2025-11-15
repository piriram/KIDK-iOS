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
            print("⚠️ Tab bar items not available")
            #endif
            return
        }
        
        let accountUnselected = UIImage(named: "tab_account_unselected")
        let accountSelected = UIImage(named: "tab_account_selected")
        let missionUnselected = UIImage(named: "tab_mission_unselected")
        let missionSelected = UIImage(named: "tab_mission_selected")
        let settingsUnselected = UIImage(named: "tab_settings_unselected")
        let settingsSelected = UIImage(named: "tab_settings_selected")
        
        #if DEBUG
        print("🖼️ Tab bar image loading status:")
        print("  - tab_account_unselected: \(accountUnselected != nil)")
        print("  - tab_account_selected: \(accountSelected != nil)")
        print("  - tab_mission_unselected: \(missionUnselected != nil)")
        print("  - tab_mission_selected: \(missionSelected != nil)")
        print("  - tab_settings_unselected: \(settingsUnselected != nil)")
        print("  - tab_settings_selected: \(settingsSelected != nil)")
        #endif
        
        items[0].title = Strings.TabBar.account
        items[0].image = accountUnselected?.withRenderingMode(.alwaysTemplate)
        items[0].selectedImage = accountSelected?.withRenderingMode(.alwaysTemplate)
        
        items[1].title = Strings.TabBar.mission
        items[1].image = missionUnselected?.withRenderingMode(.alwaysTemplate)
        items[1].selectedImage = missionSelected?.withRenderingMode(.alwaysTemplate)
        
        items[2].title = Strings.TabBar.settings
        items[2].image = settingsUnselected?.withRenderingMode(.alwaysTemplate)
        items[2].selectedImage = settingsSelected?.withRenderingMode(.alwaysTemplate)
    }
}
