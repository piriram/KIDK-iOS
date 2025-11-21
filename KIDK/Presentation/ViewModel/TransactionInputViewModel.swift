//
//  TransactionInputViewModel.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/19/25.
//

import Foundation
import RxSwift
import RxCocoa

final class TransactionInputViewModel: BaseViewModel {

    struct Input {
        let amount: Observable<Int>
        let category: Observable<TransactionCategory?>
        let account: Observable<Account>
        let memo: Observable<String?>
        let confirmTapped: Observable<Void>
    }

    struct Output {
        let isConfirmEnabled: Driver<Bool>
        let validationError: Driver<String?>
        let transactionCreated: Driver<Transaction>
        let balanceInsufficient: Driver<(current: Int, required: Int)?>
    }

    private let transactionType: TransactionType
    private let transactionRepository: TransactionRepositoryProtocol

    private let validationErrorRelay = PublishRelay<String?>()
    private let transactionCreatedRelay = PublishRelay<Transaction>()
    private let balanceInsufficientRelay = PublishRelay<(current: Int, required: Int)?>()

    init(
        transactionType: TransactionType,
        transactionRepository: TransactionRepositoryProtocol
    ) {
        self.transactionType = transactionType
        self.transactionRepository = transactionRepository
        super.init()
    }

    func transform(input: Input) -> Output {
        let isConfirmEnabled: Observable<Bool>

        if transactionType == .withdrawal {
            isConfirmEnabled = Observable.combineLatest(
                input.amount,
                input.category
            )
            .map { amount, category in
                return amount > 0 && category != nil
            }
        } else {
            isConfirmEnabled = input.amount
                .map { $0 > 0 }
        }

        input.confirmTapped
            .withLatestFrom(Observable.combineLatest(
                input.amount,
                input.category,
                input.account,
                input.memo
            ))
            .do(onNext: { [weak self] _ in
                self?.isLoading.accept(true)
            })
            .flatMapLatest { [weak self] (amount, category, account, memo) -> Observable<Transaction> in
                guard let self = self else { return .empty() }

                if self.transactionType == .withdrawal {
                    if account.balance < amount {
                        self.balanceInsufficientRelay.accept((current: account.balance, required: amount))
                        self.validationErrorRelay.accept("잔액이 부족해요")
                        self.isLoading.accept(false)
                        return .empty()
                    }
                }

                let description = self.makeDescription(
                    type: self.transactionType,
                    category: category,
                    amount: amount
                )

                return self.transactionRepository.createTransaction(
                    accountId: account.id,
                    type: self.transactionType,
                    amount: amount,
                    category: category,
                    description: description,
                    memo: memo
                )
                .asObservable()
                .catch { [weak self] error in
                    self?.debugError("Transaction creation failed", error: error)
                    self?.error.onNext(error)
                    self?.isLoading.accept(false)
                    return .empty()
                }
            }
            .do(onNext: { [weak self] transaction in
                self?.isLoading.accept(false)
                self?.transactionCreatedRelay.accept(transaction)
                self?.debugSuccess("Transaction created: \(transaction.type.displayName) \(transaction.amount)원")
            })
            .subscribe()
            .disposed(by: disposeBag)

        return Output(
            isConfirmEnabled: isConfirmEnabled.asDriver(onErrorJustReturn: false),
            validationError: validationErrorRelay.asDriver(onErrorJustReturn: nil),
            transactionCreated: transactionCreatedRelay.asDriver(onErrorDriveWith: .empty()),
            balanceInsufficient: balanceInsufficientRelay.asDriver(onErrorJustReturn: nil)
        )
    }

    private func makeDescription(
        type: TransactionType,
        category: TransactionCategory?,
        amount: Int
    ) -> String {
        switch type {
        case .deposit:
            return "입금"
        case .withdrawal:
            return category?.rawValue ?? "출금"
        case .transfer:
            return "이체"
        case .missionReward:
            return "미션 보상"
        }
    }
}
