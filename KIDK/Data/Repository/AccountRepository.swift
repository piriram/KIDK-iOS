//
//  AccountRepository.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/19/25.
//

import Foundation
import RxSwift

final class AccountRepository: BaseRepository, AccountRepositoryProtocol {

    static let shared = AccountRepository()

    private override init() {
        super.init()
    }

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

    func getAllAccounts() -> Single<[Account]> {
        return Single.create { [weak self] (single: @escaping (SingleEvent<[Account]>) -> Void) -> Disposable in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "AccountRepository", code: -1))))
                return Disposables.create()
            }

            self.debugSuccess("Fetched \(self.mockAccounts.count) accounts")
            single(.success(self.mockAccounts))
            return Disposables.create()
        }
    }

    func getAccount(id: String) -> Single<Account?> {
        return Single.create { [weak self] (single: @escaping (SingleEvent<Account?>) -> Void) -> Disposable in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "AccountRepository", code: -1))))
                return Disposables.create()
            }

            let account = self.mockAccounts.first(where: { $0.id == id })
            if let account = account {
                self.debugSuccess("Found account: \(account.name)")
            } else {
                self.debugWarning("Account not found: \(id)")
            }
            single(.success(account))
            return Disposables.create()
        }
    }

    func getPrimaryAccount() -> Single<Account?> {
        return Single.create { [weak self] (single: @escaping (SingleEvent<Account?>) -> Void) -> Disposable in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "AccountRepository", code: -1))))
                return Disposables.create()
            }

            let primaryAccount = self.mockAccounts.first(where: { $0.isPrimary })
            if let account = primaryAccount {
                self.debugSuccess("Found primary account: \(account.name)")
            } else {
                self.debugWarning("No primary account found")
            }
            single(.success(primaryAccount))
            return Disposables.create()
        }
    }

    func getTotalBalance() -> Single<Int> {
        return Single.create { [weak self] (single: @escaping (SingleEvent<Int>) -> Void) -> Disposable in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "AccountRepository", code: -1))))
                return Disposables.create()
            }

            let totalBalance = self.mockAccounts.reduce(0) { $0 + $1.balance }
            self.debugSuccess("Total balance: \(totalBalance)원")
            single(.success(totalBalance))
            return Disposables.create()
        }
    }

    func updateAccountBalance(accountId: String, newBalance: Int) -> Single<Account> {
        return Single.create { [weak self] (single: @escaping (SingleEvent<Account>) -> Void) -> Disposable in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "AccountRepository", code: -1))))
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

            self.debugSuccess("Updated account balance: \(self.mockAccounts[accountIndex].name) -> \(newBalance)원")
            single(.success(self.mockAccounts[accountIndex]))
            return Disposables.create()
        }
    }

    func createAccount(type: AccountType, name: String, balance: Int, isPrimary: Bool) -> Single<Account> {
        return Single.create { [weak self] (single: @escaping (SingleEvent<Account>) -> Void) -> Disposable in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "AccountRepository", code: -1))))
                return Disposables.create()
            }

            let newAccount = Account(
                id: UUID().uuidString,
                type: type,
                name: name,
                balance: balance,
                isPrimary: isPrimary
            )

            self.mockAccounts.append(newAccount)
            self.debugSuccess("Created new account: \(name)")
            single(.success(newAccount))
            return Disposables.create()
        }
    }
}
