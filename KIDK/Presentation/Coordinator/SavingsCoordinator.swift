import UIKit
import RxSwift

final class SavingsCoordinator: BaseCoordinator {

    override func start() {
        let savingsRepository = SavingsRepository.shared
        let viewModel = SavingsViewModel(savingsRepository: savingsRepository)
        viewModel.coordinator = self

        let viewController = SavingsViewController(viewModel: viewModel)
        viewController.coordinator = self

        navigationController.setViewControllers([viewController], animated: false)
    }

    /// 저축 목표 상세 화면으로 이동
    func showSavingsDetail(goal: SavingsGoal) {
        let viewModel = SavingsDetailViewModel(savingsGoal: goal)
        let viewController = SavingsDetailViewController(viewModel: viewModel)
        viewController.coordinator = self

        navigationController.pushViewController(viewController, animated: true)
    }
}
