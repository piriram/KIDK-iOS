//
//  LoginViewModel.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/15/25.
//

import Foundation
import RxSwift
import RxCocoa

final class LoginViewModel: BaseViewModel {
    
    struct Input {
        let emailText: Observable<String>
        let passwordText: Observable<String>
        let autoLoginToggled: Observable<Bool>
        let loginButtonTapped: Observable<Void>
        let signupButtonTapped: Observable<Void>
    }
    
    struct Output {
        let isLoginEnabled: Driver<Bool>
        let isLoading: Driver<Bool>
        let savedEmail: Driver<String>
        let isAutoLoginEnabled: Driver<Bool>
    }
    
    let loginSuccess = PublishSubject<User>()
    let navigateToSignup = PublishSubject<Void>()
    
    private let authRepository: AuthRepositoryProtocol
    private let autoLoginEnabled = BehaviorRelay<Bool>(value: false)
    
    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
        super.init()
        
        autoLoginEnabled.accept(authRepository.isAutoLoginEnabled())
    }
    
    func transform(input: Input) -> Output {
        let credentials = Observable.combineLatest(
            input.emailText,
            input.passwordText
        )
        
        let isLoginEnabled = credentials
            .map { email, password in
                !email.isEmpty && !password.isEmpty && email.contains("@")
            }
        
        input.autoLoginToggled
            .subscribe(onNext: { [weak self] isEnabled in
                self?.autoLoginEnabled.accept(isEnabled)
                self?.authRepository.saveAutoLoginPreference(isEnabled)
                self?.debugLog("Auto-login toggled: \(isEnabled)")
            })
            .disposed(by: disposeBag)
        
        input.loginButtonTapped
            .withLatestFrom(credentials)
            .do(onNext: { [weak self] email, password in
                self?.startLoading()
                self?.debugLog("Login attempt with email: \(email)")
            })
            .flatMapLatest { [weak self] email, password -> Observable<User> in
                guard let self = self else { return .empty() }
                return self.mockLogin(email: email, password: password)
            }
            .do(onNext: { [weak self] user in
                self?.stopLoading()
                self?.debugSuccess("Login successful")
                
                if let isAutoLogin = self?.autoLoginEnabled.value, isAutoLogin {
                    self?.authRepository.saveLoginCredentials(email: user.name)
                }
            }, onError: { [weak self] error in
                self?.handleError(error)
            })
            .subscribe(onNext: { [weak self] user in
                self?.loginSuccess.onNext(user)
            })
            .disposed(by: disposeBag)
        
        input.signupButtonTapped
            .subscribe(onNext: { [weak self] in
                self?.debugLog("Navigate to signup")
                self?.navigateToSignup.onNext(())
            })
            .disposed(by: disposeBag)
        
        let savedEmail = Observable.just(authRepository.getLastLoginEmail() ?? "")
        
        return Output(
            isLoginEnabled: isLoginEnabled.asDriver(onErrorJustReturn: false),
            isLoading: isLoading.asDriver(),
            savedEmail: savedEmail.asDriver(onErrorJustReturn: ""),
            isAutoLoginEnabled: autoLoginEnabled.asDriver()
        )
    }
    
    private func mockLogin(email: String, password: String) -> Observable<User> {
        return Observable.create { [weak self] observer in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let userType: UserType = .child
//                let userType: UserType = email.contains("child") ? .child : .parent
                let firebaseUID = "mock_\(UUID().uuidString)"
                let user = User(
                    id: UUID().uuidString,
                    firebaseUID: firebaseUID,
                    userType: userType,
                    name: email.components(separatedBy: "@").first ?? "User",
                    status: .active
                )
                
                self?.authRepository.setFirstLaunchComplete()
                observer.onNext(user)
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
}
