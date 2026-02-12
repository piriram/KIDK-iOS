//
//  SavingsDetailViewModel.swift
//  KIDK
//
//  저축 목표 상세 ViewModel
//  - 목표 정보 조회
//  - 입금/출금 처리
//  - 거래 내역 관리
//

import Foundation
import RxSwift
import RxCocoa

final class SavingsDetailViewModel: BaseViewModel {

    // MARK: - Input/Output

    struct Input {
        let viewDidLoad: Observable<Void>
        let depositTapped: Observable<Void>
        let withdrawTapped: Observable<Void>
    }

    struct Output {
        let savingsGoal: Driver<SavingsGoal>
        let transactions: Driver<[SavingsTransaction]>
        let isLoading: Driver<Bool>
        let error: Driver<String>
    }

    // MARK: - Properties

    private let savingsGoal: SavingsGoal
    private let savingsRepository: SavingsRepositoryProtocol
    private let accountRepository: AccountRepositoryProtocol

    let depositSuccess = PublishSubject<Int>()
    let withdrawSuccess = PublishSubject<Int>()

    // MARK: - Initialization

    init(
        savingsGoal: SavingsGoal,
        savingsRepository: SavingsRepositoryProtocol = SavingsRepository.shared,
        accountRepository: AccountRepositoryProtocol = AccountRepository.shared
    ) {
        self.savingsGoal = savingsGoal
        self.savingsRepository = savingsRepository
        self.accountRepository = accountRepository
        super.init()
    }

    // MARK: - Transform

    func transform(input: Input) -> Output {
        let goalRelay = BehaviorRelay<SavingsGoal>(value: savingsGoal)
        let transactionsRelay = BehaviorRelay<[SavingsTransaction]>(value: [])

        // 화면 로드 시 거래 내역 조회
        input.viewDidLoad
            .do(onNext: { [weak self] in
                self?.startLoading()
            })
            .flatMapLatest { [weak self] _ -> Observable<[SavingsTransaction]> in
                guard let self = self else { return .empty() }
                // Mock 거래 내역 (실제로는 API 호출)
                return self.loadTransactions()
            }
            .do(onNext: { [weak self] _ in
                self?.stopLoading()
            })
            .subscribe(onNext: { transactions in
                transactionsRelay.accept(transactions)
            })
            .disposed(by: disposeBag)

        // 입금 버튼 탭
        input.depositTapped
            .subscribe(onNext: { [weak self] in
                self?.handleDeposit(goalRelay: goalRelay)
            })
            .disposed(by: disposeBag)

        // 출금 버튼 탭
        input.withdrawTapped
            .subscribe(onNext: { [weak self] in
                self?.handleWithdraw(goalRelay: goalRelay)
            })
            .disposed(by: disposeBag)

        return Output(
            savingsGoal: goalRelay.asDriver(),
            transactions: transactionsRelay.asDriver(),
            isLoading: isLoading.asDriver(),
            error: error.compactMap { $0 }.asDriver(onErrorJustReturn: "알 수 없는 오류")
        )
    }

    // MARK: - Private Methods

    private func loadTransactions() -> Observable<[SavingsTransaction]> {
        // TODO: 실제 API로 거래 내역 조회
        // 현재는 Mock 데이터

        let mockTransactions: [SavingsTransaction] = [
            SavingsTransaction(
                id: "1",
                savingsGoalId: savingsGoal.id,
                amount: 10000,
                date: Date().addingTimeInterval(-86400 * 7), // 7일 전
                source: "용돈",
                note: "주간 용돈"
            ),
            SavingsTransaction(
                id: "2",
                savingsGoalId: savingsGoal.id,
                amount: 5000,
                date: Date().addingTimeInterval(-86400 * 3), // 3일 전
                source: "미션 보상",
                note: "설거지 미션 완료"
            ),
            SavingsTransaction(
                id: "3",
                savingsGoalId: savingsGoal.id,
                amount: 15000,
                date: Date().addingTimeInterval(-86400), // 1일 전
                source: "용돈",
                note: "주간 용돈"
            )
        ]

        return Observable.just(mockTransactions)
            .delay(.milliseconds(500), scheduler: MainScheduler.instance)
    }

    private func handleDeposit(goalRelay: BehaviorRelay<SavingsGoal>) {
        debugLog("Deposit button tapped")

        // 입금 금액 입력 받기 (실제로는 Alert 또는 BottomSheet)
        // 여기서는 간단히 10,000원 고정

        let depositAmount = 10000

        Task {
            guard let user = await UserProfileManager.shared.getCurrentUser() else {
                self.error.accept("사용자 정보를 불러올 수 없습니다")
                return
            }

            // 사용자의 지출 계좌 조회
            guard let userId = Int(user.id) else {
                self.error.accept("유효하지 않은 사용자 ID입니다")
                return
            }

            self.startLoading()

            // 계좌 조회
            self.accountRepository.getAccountsByUser(userId: userId)
                .flatMap { accounts -> Single<SavingsGoal> in
                    guard let spendingAccount = accounts.first(where: { $0.accountType == .spending }) else {
                        return .error(RepositoryError.notFound(message: "지출 계좌를 찾을 수 없습니다"))
                    }

                    guard let savingsId = Int(self.savingsGoal.id),
                          let accountId = Int(spendingAccount.id) else {
                        return .error(RepositoryError.invalidParameter)
                    }

                    // 저축 입금 API 호출
                    return self.savingsRepository.deposit(
                        savingsId: savingsId,
                        amount: depositAmount,
                        accountId: accountId
                    )
                }
                .observe(on: MainScheduler.instance)
                .subscribe(
                    onSuccess: { [weak self] updatedGoal in
                        self?.stopLoading()
                        goalRelay.accept(updatedGoal)
                        self?.depositSuccess.onNext(depositAmount)
                        self?.debugSuccess("Deposited \(depositAmount) to savings goal")
                    },
                    onFailure: { [weak self] error in
                        self?.stopLoading()
                        self?.handleError(error)
                    }
                )
                .disposed(by: self.disposeBag)
        }
    }

    private func handleWithdraw(goalRelay: BehaviorRelay<SavingsGoal>) {
        debugLog("Withdraw button tapped")

        let currentGoal = goalRelay.value

        guard currentGoal.currentAmount > 0 else {
            self.error.accept("출금할 금액이 없습니다")
            return
        }

        // 출금 금액 입력 받기 (실제로는 Alert 또는 BottomSheet)
        // 여기서는 간단히 5,000원 고정

        let withdrawAmount = min(5000, currentGoal.currentAmount)

        Task {
            guard let user = await UserProfileManager.shared.getCurrentUser() else {
                self.error.accept("사용자 정보를 불러올 수 없습니다")
                return
            }

            guard let userId = Int(user.id) else {
                self.error.accept("유효하지 않은 사용자 ID입니다")
                return
            }

            self.startLoading()

            // 계좌 조회
            self.accountRepository.getAccountsByUser(userId: userId)
                .flatMap { accounts -> Single<SavingsGoal> in
                    guard let spendingAccount = accounts.first(where: { $0.accountType == .spending }) else {
                        return .error(RepositoryError.notFound(message: "지출 계좌를 찾을 수 없습니다"))
                    }

                    guard let savingsId = Int(self.savingsGoal.id),
                          let accountId = Int(spendingAccount.id) else {
                        return .error(RepositoryError.invalidParameter)
                    }

                    // 저축 출금 API 호출
                    return self.savingsRepository.withdraw(
                        savingsId: savingsId,
                        amount: withdrawAmount,
                        accountId: accountId
                    )
                }
                .observe(on: MainScheduler.instance)
                .subscribe(
                    onSuccess: { [weak self] updatedGoal in
                        self?.stopLoading()
                        goalRelay.accept(updatedGoal)
                        self?.withdrawSuccess.onNext(withdrawAmount)
                        self?.debugSuccess("Withdrew \(withdrawAmount) from savings goal")
                    },
                    onFailure: { [weak self] error in
                        self?.stopLoading()
                        self?.handleError(error)
                    }
                )
                .disposed(by: self.disposeBag)
        }
    }
}
