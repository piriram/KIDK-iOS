//
//  WalletViewModel.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/19/25.
//

import Foundation
import RxSwift
import RxCocoa

final class WalletViewModel: BaseViewModel {

    // MARK: - Dependencies
    private let accountRepository: AccountRepositoryProtocol
    private let transactionRepository: TransactionRepositoryProtocol
    private let savingsRepository: SavingsRepositoryProtocol

    // MARK: - Outputs
    let accounts: BehaviorRelay<[Account]>
    let transactions: BehaviorRelay<[Transaction]>
    let savingsGoals: BehaviorRelay<[SavingsGoal]>
    let card: BehaviorRelay<Card?>
    let userLevel: BehaviorRelay<Int>
    let userExperience: BehaviorRelay<Int>
    let dailySpendingLimit: BehaviorRelay<Int>

    // MARK: - Initialization
    init(
        accountRepository: AccountRepositoryProtocol,
        transactionRepository: TransactionRepositoryProtocol,
        savingsRepository: SavingsRepositoryProtocol
    ) {
        self.accountRepository = accountRepository
        self.transactionRepository = transactionRepository
        self.savingsRepository = savingsRepository

        // Initialize relays with empty data
        self.accounts = BehaviorRelay(value: [])
        self.transactions = BehaviorRelay(value: [])
        self.savingsGoals = BehaviorRelay(value: [])

        // Mock data for features not yet connected to repositories
        let mockCard = Card(
            id: "1",
            characterImageName: "kidk_profile_one",
            isPhysicalCard: true,
            status: .active,
            lastFourDigits: "1234"
        )
        self.card = BehaviorRelay(value: mockCard)
        self.userLevel = BehaviorRelay(value: 5)
        self.userExperience = BehaviorRelay(value: 650)
        self.dailySpendingLimit = BehaviorRelay(value: 10000)

        super.init()

        // Load initial data
        loadData()
    }

    // MARK: - Methods
    func refreshData() {
        loadData()
    }

    func getPrimaryAccount() -> Account? {
        return accounts.value.first { $0.isPrimary }
    }

    func getTotalBalance() -> Int {
        return accounts.value.reduce(0) { $0 + $1.balance }
    }

    func getTransactionsByDate() -> [String: [Transaction]] {
        let calendar = Calendar.current
        var groupedTransactions: [String: [Transaction]] = [:]

        for transaction in transactions.value {
            let dateString = transaction.formattedDateWithDay
            if groupedTransactions[dateString] == nil {
                groupedTransactions[dateString] = []
            }
            groupedTransactions[dateString]?.append(transaction)
        }

        return groupedTransactions
    }

    func filterTransactions(by type: TransactionType?) -> [Transaction] {
        guard let type = type else {
            return transactions.value
        }
        return transactions.value.filter { $0.type == type }
    }

    func filterTransactions(by category: TransactionCategory?) -> [Transaction] {
        guard let category = category else {
            return transactions.value
        }
        return transactions.value.filter { $0.category == category }
    }

    // MARK: - Private Methods
    private func loadData() {
        isLoading.accept(true)

        // Fetch all data in parallel
        Observable.zip(
            fetchAccounts(),
            fetchTransactions(),
            fetchSavingsGoals()
        )
        .observe(on: MainScheduler.instance)
        .subscribe(
            onNext: { [weak self] accounts, transactions, savingsGoals in
                self?.accounts.accept(accounts)
                self?.transactions.accept(transactions)
                self?.savingsGoals.accept(savingsGoals)
                self?.isLoading.accept(false)
                self?.debugSuccess("Data loaded successfully")
            },
            onError: { [weak self] error in
                self?.isLoading.accept(false)
                self?.error.onNext(error)
                self?.debugError("Failed to load data", error: error)
            }
        )
        .disposed(by: disposeBag)
    }

    private func fetchAccounts() -> Observable<[Account]> {
        return accountRepository.getAllAccounts()
            .asObservable()
            .catch { [weak self] error in
                self?.debugError("Failed to fetch accounts", error: error)
                return .just([])
            }
    }

    private func fetchTransactions() -> Observable<[Transaction]> {
        // Get primary account to fetch its transactions
        return accountRepository.getPrimaryAccount()
            .asObservable()
            .flatMap { [weak self] primaryAccount -> Observable<[Transaction]> in
                guard let self = self, let account = primaryAccount else {
                    return .just([])
                }
                return self.transactionRepository.fetchTransactions(for: account.id)
                    .asObservable()
            }
            .catch { [weak self] error in
                self?.debugError("Failed to fetch transactions", error: error)
                return .just(self?.createMockTransactions() ?? [])
            }
    }

    private func fetchSavingsGoals() -> Observable<[SavingsGoal]> {
        return savingsRepository.fetchSavingsGoals()
            .asObservable()
            .catch { [weak self] error in
                self?.debugError("Failed to fetch savings goals", error: error)
                return .just([])
            }
    }

    // Fallback mock transactions for when repository returns empty
    private func createMockTransactions() -> [Transaction] {
        return [
            Transaction(
                id: "1",
                type: .missionReward,
                category: nil,
                amount: 1000,
                description: "책 30분 읽기 미션 완료",
                memo: nil,
                balanceAfter: 12450,
                date: Date().addingTimeInterval(-3600)
            ),
            Transaction(
                id: "2",
                type: .withdrawal,
                category: .food,
                amount: 3500,
                description: "편의점 간식",
                memo: "초코바, 우유",
                balanceAfter: 11450,
                date: Date().addingTimeInterval(-7200)
            ),
            Transaction(
                id: "3",
                type: .deposit,
                category: nil,
                amount: 5000,
                description: "용돈",
                memo: "엄마가 주신 용돈",
                balanceAfter: 14950,
                date: Date().addingTimeInterval(-86400)
            ),
            Transaction(
                id: "4",
                type: .withdrawal,
                category: .school,
                amount: 15000,
                description: "문구점",
                memo: "노트, 필통",
                balanceAfter: 9950,
                date: Date().addingTimeInterval(-172800)
            ),
            Transaction(
                id: "5",
                type: .transfer,
                category: nil,
                amount: 10000,
                description: "저축 통장으로 이체",
                memo: nil,
                balanceAfter: 24950,
                date: Date().addingTimeInterval(-259200)
            )
        ]
    }
}
