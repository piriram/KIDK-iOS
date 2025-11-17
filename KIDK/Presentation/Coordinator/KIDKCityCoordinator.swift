//
//  KIDKCityCoordinator.swift
//  KIDK
//
//  Created by Claude on 11/17/25.
//

import UIKit

final class KIDKCityCoordinator: BaseCoordinator {

    override func start() {
        showKIDKCity()
    }

    private func showKIDKCity() {
        let viewModel = KIDKCityViewModel()
        let viewController = KIDKCityViewController(viewModel: viewModel)

        viewController.onBuildingEnter = { [weak self] buildingType in
            self?.handleBuildingEntry(buildingType)
        }

        navigationController.pushViewController(viewController, animated: true)
        debugSuccess("KIDKCityViewController pushed")
    }

    private func handleBuildingEntry(_ buildingType: BuildingType) {
        switch buildingType {
        case .home:
            showHomeScreen()
        case .mart:
            showMartScreen()
        case .school:
            showSchoolScreen()
        case .special:
            showSpecialScreen()
        }
    }

    private func showHomeScreen() {
        debugLog("🏠 Home screen requested")
        showPlaceholderAlert(for: "집")
    }

    private func showMartScreen() {
        debugLog("🛒 Mart screen requested")
        showPlaceholderAlert(for: "마트")
    }

    private func showSchoolScreen() {
        debugLog("🏫 School screen requested")
        showPlaceholderAlert(for: "학교")
    }

    private func showSpecialScreen() {
        debugLog("✨ Special screen requested")
        showPlaceholderAlert(for: "특별 건물")
    }

    private func showPlaceholderAlert(for location: String) {
        let alert = UIAlertController(
            title: "\(location)에 입장했습니다",
            message: "화면이 준비 중입니다.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))

        if let topViewController = navigationController.topViewController {
            topViewController.present(alert, animated: true)
        }
    }
}
