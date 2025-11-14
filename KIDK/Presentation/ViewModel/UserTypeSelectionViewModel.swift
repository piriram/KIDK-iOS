//
//  UserTypeSelectionViewModel.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/13/25.
//

import Foundation
import RxSwift
import RxCocoa

final class UserTypeSelectionViewModel: BaseViewModel {
    
    struct Input {
        let childButtonTapped: Observable<Void>
        let parentButtonTapped: Observable<Void>
    }
    
    struct Output {
        let isLoading: Driver<Bool>
        let error: Driver<String>
    }
    
    let userCreated: PublishSubject<User> = PublishSubject()
    
    private let authRepository: AuthRepositoryProtocol
    
    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
        super.init()
    }
    
    func transform(input: Input) -> Output {
        let errorMessage = PublishSubject<String>()
        
        input.childButtonTapped
            .do(onNext: { [weak self] _ in
                self?.startLoading()
            })
            .flatMapLatest { [weak self] _ -> Observable<User> in
                guard let self = self else { return .empty() }
                return self.authRepository.generateMockUser(userType: .child)
            }
            .do(onNext: { [weak self] _ in
                self?.stopLoading()
                self?.authRepository.setFirstLaunchComplete()
                self?.debugSuccess("Child user created successfully")
            }, onError: { [weak self] err in
                self?.stopLoading()
                self?.debugError("Failed to create child user", error: err)
            })
            .subscribe(onNext: { [weak self] user in
                self?.userCreated.onNext(user)
            }, onError: { err in
                errorMessage.onNext("Failed to create child user: \(err.localizedDescription)")
            })
            .disposed(by: disposeBag)
        
        input.parentButtonTapped
            .do(onNext: { [weak self] _ in
                self?.startLoading()
            })
            .flatMapLatest { [weak self] _ -> Observable<User> in
                guard let self = self else { return .empty() }
                return self.authRepository.generateMockUser(userType: .parent)
            }
            .do(onNext: { [weak self] _ in
                self?.stopLoading()
                self?.authRepository.setFirstLaunchComplete()
                self?.debugSuccess("Parent user created successfully")
            }, onError: { [weak self] err in
                self?.stopLoading()
                self?.debugError("Failed to create parent user", error: err)
            })
            .subscribe(onNext: { [weak self] user in
                self?.userCreated.onNext(user)
            }, onError: { err in
                errorMessage.onNext("Failed to create parent user: \(err.localizedDescription)")
            })
            .disposed(by: disposeBag)
        
        return Output(
            isLoading: isLoading.asDriver(),
            error: errorMessage.asDriver(onErrorJustReturn: "Unknown error occurred")
        )
    }
}
