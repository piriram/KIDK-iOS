//
//  AuthCoordinatorDelegate.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/13/25.
//
import UIKit
import RxSwift

protocol AuthCoordinatorDelegate: AnyObject {
    func authCoordinatorDidFinish(_ coordinator: AuthCoordinator, user: User)
}

final class AuthCoordinator: BaseCoordinator {
    
    weak var delegate: AuthCoordinatorDelegate?
    
    private let authRepository: AuthRepositoryProtocol
    
    init(navigationController: UINavigationController, authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        showLogin()
    }
    
    private func showLogin() {
        let viewModel = LoginViewModel(authRepository: authRepository)
        let viewController = LoginViewController(viewModel: viewModel)
        
        viewModel.loginSuccess
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] user in
                guard let self = self else { return }
                self.debugSuccess("Login successful")
                self.delegate?.authCoordinatorDidFinish(self, user: user)
            })
            .disposed(by: disposeBag)
        
        viewModel.navigateToSignup
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.showUserTypeSelection()
            })
            .disposed(by: disposeBag)
        
        navigationController.setViewControllers([viewController], animated: false)
    }
    
    private func showUserTypeSelection() {
        let viewModel = SignupViewModel(authRepository: authRepository)
        let viewController = SignupViewController(viewModel: viewModel)
        
        viewModel.signupSuccess
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] user in
                guard let self = self else { return }
                self.debugSuccess("User signup successful")
                self.delegate?.authCoordinatorDidFinish(self, user: user)
            })
            .disposed(by: disposeBag)
        
        navigationController.pushViewController(viewController, animated: true)
    }
}
