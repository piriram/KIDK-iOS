//
//  SignupViewModel.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/15/25.
//

import Foundation
import RxSwift
import RxCocoa

final class SignupViewModel: BaseViewModel {
    
    struct Input {
        let nameText: Observable<String>
        let emailText: Observable<String>
        let passwordText: Observable<String>
        let passwordConfirmText: Observable<String>
        let userTypeSelected: Observable<UserType>
        let signupButtonTapped: Observable<Void>
    }
    
    struct Output {
        let isSignupEnabled: Driver<Bool>
        let isLoading: Driver<Bool>
        let selectedUserType: Driver<UserType>
    }
    
    let signupSuccess = PublishSubject<User>()
    
    private let authRepository: AuthRepositoryProtocol
    private let selectedUserType = BehaviorRelay<UserType>(value: .child)
    
    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
        super.init()
    }
    
    func transform(input: Input) -> Output {
        let formData = Observable.combineLatest(
            input.nameText,
            input.emailText,
            input.passwordText,
            input.passwordConfirmText
        )
        
        let isSignupEnabled = formData
            .map { name, email, password, passwordConfirm in
                return !name.isEmpty &&
                       !email.isEmpty &&
                       !password.isEmpty &&
                       !passwordConfirm.isEmpty &&
                       password == passwordConfirm
            }
        
        input.userTypeSelected
            .subscribe(onNext: { [weak self] userType in
                self?.selectedUserType.accept(userType)
                self?.debugLog("User type selected: \(userType)")
            })
            .disposed(by: disposeBag)
        
        input.signupButtonTapped
            .withLatestFrom(formData)
            .do(onNext: { [weak self] name, email, _, _ in
                self?.startLoading()
                self?.debugLog("Signup attempt with email: \(email)")
            })
            .flatMapLatest { [weak self] name, email, password, _ -> Observable<User> in
                guard let self = self else { return .empty() }
                return self.createUser(name: name, email: email, password: password)
            }
            .do(onNext: { [weak self] _ in
                self?.stopLoading()
                self?.debugSuccess("Signup successful")
            }, onError: { [weak self] error in
                self?.handleError(error)
            })
            .subscribe(onNext: { [weak self] user in
                self?.signupSuccess.onNext(user)
            })
            .disposed(by: disposeBag)
        
        return Output(
            isSignupEnabled: isSignupEnabled.asDriver(onErrorJustReturn: false),
            isLoading: isLoading.asDriver(),
            selectedUserType: selectedUserType.asDriver()
        )
    }
    
    private func createUser(name: String, email: String, password: String) -> Observable<User> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onError(RepositoryError.unknown(NSError(domain: "SignupViewModel", code: -1)))
                return Disposables.create()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let firebaseUID = "mock_\(UUID().uuidString)"
                let user = User(
                    id: UUID().uuidString,
                    firebaseUID: firebaseUID,
                    userType: self.selectedUserType.value,
                    name: name,
                    status: .active
                )
                
                self.authRepository.setFirstLaunchComplete()
                observer.onNext(user)
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
}
