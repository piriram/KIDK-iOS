//
//  TransactionRepository.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/19/25.
//

import Foundation
import RxSwift

final class TransactionRepository: BaseRepository, TransactionRepositoryProtocol {

    static let shared = TransactionRepository()

    private override init() {
        super.init()
    }

    private let accountRepository = AccountRepository.shared
    private var mockTransactions: [Transaction] = []

    func createTransaction(
        accountId: String,
        type: TransactionType,
        amount: Int,
        category: TransactionCategory?,
        description: String,
        memo: String?
    ) -> Single<Transaction> {
        return accountRepository.getAccount(id: accountId)
            .flatMap { [weak self] accountOpt -> Single<Transaction> in
                guard let self = self else {
                    return .error(RepositoryError.unknown(NSError(domain: "TransactionRepository", code: -1)))
                }

                guard let account = accountOpt else {
                    return .error(RepositoryError.notFound)
                }

                let currentBalance = account.balance
                let newBalance: Int

                switch type {
                case .deposit, .missionReward:
                    newBalance = currentBalance + amount
                case .withdrawal, .transfer:
                    if currentBalance < amount {
                        return .error(RepositoryError.insufficientBalance)
                    }
                    newBalance = currentBalance - amount
                }

                let transaction = Transaction(
                    id: UUID().uuidString,
                    type: type,
                    category: category,
                    amount: amount,
                    description: description,
                    memo: memo,
                    balanceAfter: newBalance,
                    date: Date()
                )

                // Update account balance
                return self.accountRepository.updateAccountBalance(accountId: accountId, newBalance: newBalance)
                    .map { _ in
                        // Save transaction
                        self.mockTransactions.insert(transaction, at: 0)
                        self.debugSuccess("Transaction created: \(type.displayName) \(amount)원, New balance: \(newBalance)원")

                        // Post notification for UI update
                        NotificationCenter.default.post(name: .transactionCreated, object: transaction)

                        return transaction
                    }
            }
    }

    func fetchTransactions(for accountId: String) -> Single<[Transaction]> {
        return Single.create { [weak self] (single: @escaping (SingleEvent<[Transaction]>) -> Void) -> Disposable in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "TransactionRepository", code: -1))))
                return Disposables.create()
            }

            single(.success(self.mockTransactions))
            return Disposables.create()
        }
    }

    func updateAccountBalance(accountId: String, newBalance: Int) -> Single<Account> {
        return accountRepository.updateAccountBalance(accountId: accountId, newBalance: newBalance)
    }

    func getAccount(id: String) -> Single<Account?> {
        return accountRepository.getAccount(id: id)
    }

    func getAllAccounts() -> [Account] {
        // Synchronous helper method for quick access
        // Note: This is a workaround - ideally should be async
        var accounts: [Account] = []
        _ = accountRepository.getAllAccounts()
            .subscribe(onSuccess: { fetchedAccounts in
                accounts = fetchedAccounts
            })
        return accounts
    }
}
