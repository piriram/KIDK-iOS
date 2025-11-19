//
//  TransactionRepository.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/19/25.
//

import Foundation
import RxSwift

final class TransactionRepository: BaseRepository, TransactionRepositoryProtocol {

    private var mockAccounts: [Account] = [
        Account(
            id: "1",
            type: .spending,
            name: "내 용돈 통장",
            balance: 12450,
            isPrimary: true
        ),
        Account(
            id: "2",
            type: .savings,
            name: "내 저축 통장",
            balance: 50000,
            isPrimary: false
        ),
        Account(
            id: "3",
            type: .goal,
            name: "놀이공원 가기",
            balance: 30000,
            isPrimary: false
        )
    ]

    private var mockTransactions: [Transaction] = []

    func createTransaction(
        accountId: String,
        type: TransactionType,
        amount: Int,
        category: TransactionCategory?,
        description: String,
        memo: String?
    ) -> Single<Transaction> {
        return Single.create { [weak self] (single: @escaping (SingleEvent<Transaction>) -> Void) -> Disposable in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "TransactionRepository", code: -1))))
                return Disposables.create()
            }

            guard let accountIndex = self.mockAccounts.firstIndex(where: { $0.id == accountId }) else {
                single(.failure(RepositoryError.notFound))
                return Disposables.create()
            }

            let currentBalance = self.mockAccounts[accountIndex].balance
            let newBalance: Int

            switch type {
            case .deposit, .missionReward:
                newBalance = currentBalance + amount
            case .withdrawal, .transfer:
                if currentBalance < amount {
                    single(.failure(RepositoryError.insufficientBalance))
                    return Disposables.create()
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

            self.mockTransactions.insert(transaction, at: 0)

            self.mockAccounts[accountIndex] = Account(
                id: accountId,
                type: self.mockAccounts[accountIndex].type,
                name: self.mockAccounts[accountIndex].name,
                balance: newBalance,
                isPrimary: self.mockAccounts[accountIndex].isPrimary
            )

            self.debugSuccess("Transaction created: \(type.displayName) \(amount)원")
            single(.success(transaction))

            return Disposables.create()
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
        return Single.create { [weak self] (single: @escaping (SingleEvent<Account>) -> Void) -> Disposable in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "TransactionRepository", code: -1))))
                return Disposables.create()
            }

            guard let accountIndex = self.mockAccounts.firstIndex(where: { $0.id == accountId }) else {
                single(.failure(RepositoryError.notFound))
                return Disposables.create()
            }

            self.mockAccounts[accountIndex] = Account(
                id: accountId,
                type: self.mockAccounts[accountIndex].type,
                name: self.mockAccounts[accountIndex].name,
                balance: newBalance,
                isPrimary: self.mockAccounts[accountIndex].isPrimary
            )

            single(.success(self.mockAccounts[accountIndex]))
            return Disposables.create()
        }
    }

    func getAccount(id: String) -> Single<Account?> {
        return Single.create { [weak self] (single: @escaping (SingleEvent<Account?>) -> Void) -> Disposable in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "TransactionRepository", code: -1))))
                return Disposables.create()
            }

            let account = self.mockAccounts.first(where: { $0.id == id })
            single(.success(account))
            return Disposables.create()
        }
    }

    func getAllAccounts() -> [Account] {
        return mockAccounts
    }
}
