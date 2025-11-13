//
//  UserTypeSelectionViewModel.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/13/25.
//

import Foundation
import RxSwift
import RxCocoa

final class UserTypeSelectionViewModel {
    
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
    private let disposeBag = DisposeBag()
    
    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }
    
    func transform(input: Input) -> Output {
        let isLoading = BehaviorRelay<Bool>(value: false)
        let error = PublishSubject<String>()
        
        input.childButtonTapped
            .do(onNext: { isLoading.accept(true) })
            .flatMapLatest { [weak self] _ -> Observable<User> in
                guard let self = self else { return .empty() }
                return self.authRepository.generateMockUser(userType: .child)
            }
            .do(onNext: { [weak self] _ in
                isLoading.accept(false)
                self?.authRepository.setFirstLaunchComplete()
            }, onError: { _ in
                isLoading.accept(false)
            })
            .subscribe(onNext: { [weak self] user in
                self?.userCreated.onNext(user)
            }, onError: { err in
                error.onNext("Failed to create child user: \(err.localizedDescription)")
            })
            .disposed(by: disposeBag)
        
        input.parentButtonTapped
            .do(onNext: { isLoading.accept(true) })
            .flatMapLatest { [weak self] _ -> Observable<User> in
                guard let self = self else { return .empty() }
                return self.authRepository.generateMockUser(userType: .parent)
            }
            .do(onNext: { [weak self] _ in
                isLoading.accept(false)
                self?.authRepository.setFirstLaunchComplete()
            }, onError: { _ in
                isLoading.accept(false)
            })
            .subscribe(onNext: { [weak self] user in
                self?.userCreated.onNext(user)
            }, onError: { err in
                error.onNext("Failed to create parent user: \(err.localizedDescription)")
            })
            .disposed(by: disposeBag)
        
        return Output(
            isLoading: isLoading.asDriver(),
            error: error.asDriver(onErrorJustReturn: "Unknown error occurred")
        )
    }
}
