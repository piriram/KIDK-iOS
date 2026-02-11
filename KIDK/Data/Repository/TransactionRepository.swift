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

    private override init(
        networkService: NetworkService = .shared,
        tokenManager: TokenManager = .shared
    ) {
        super.init(networkService: networkService, tokenManager: tokenManager)
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
        return Single.create { [weak self] (single: @escaping (SingleEvent<Transaction>) -> Void) -> Disposable in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "TransactionRepository", code: -1))))
                return Disposables.create()
            }

            guard let accountIdInt = Int(accountId) else {
                single(.failure(RepositoryError.invalidParameter))
                return Disposables.create()
            }

            // TransactionType을 백엔드 스펙 문자열로 변환
            let typeString = type.rawValue

            // Category를 백엔드 스펙 문자열로 변환
            let categoryString: String
            if type == .missionReward {
                categoryString = "MISSION_REWARD"
            } else {
                categoryString = category?.rawValue ?? "기타"
            }

            // 실제 API 호출
            self.networkService.request(
                TransactionAPI.createTransaction(
                    accountId: accountIdInt,
                    type: typeString,
                    amount: Double(amount),
                    category: categoryString,
                    description: description,
                    relatedMissionId: nil
                )
            )
            .subscribe(onNext: { (result: Result<ApiResponseTransaction, NetworkError>) in
                switch result {
                case .success(let apiResponse):
                    if let transactionResponse = apiResponse.data {
                        let transaction = transactionResponse.toDomain()
                        self.debugSuccess("Transaction created via API: \(type.displayName) \(amount)원")

                        // Post notification for UI update
                        NotificationCenter.default.post(name: .transactionCreated, object: transaction)

                        single(.success(transaction))
                    } else {
                        self.debugError("No transaction data in response", error: nil)
                        // Fallback to mock
                        self.createMockTransaction(accountId: accountId, type: type, amount: amount, category: category, description: description, memo: memo)
                            .subscribe(onSuccess: { transaction in
                                single(.success(transaction))
                            }, onFailure: { error in
                                single(.failure(error))
                            })
                            .disposed(by: self.disposeBag)
                    }

                case .failure(let error):
                    self.debugError("Failed to create transaction", error: error)
                    // Fallback to mock
                    self.createMockTransaction(accountId: accountId, type: type, amount: amount, category: category, description: description, memo: memo)
                        .subscribe(onSuccess: { transaction in
                            single(.success(transaction))
                        }, onFailure: { error in
                            single(.failure(error))
                        })
                        .disposed(by: self.disposeBag)
                }
            })
            .disposed(by: self.disposeBag)

            return Disposables.create()
        }
    }

    private func createMockTransaction(
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
                        self.debugSuccess("Mock transaction created: \(type.displayName) \(amount)원, New balance: \(newBalance)원")

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

            guard let accountIdInt = Int(accountId) else {
                // accountId가 숫자가 아니면 Mock 데이터 반환
                self.debugWarning("Invalid accountId, returning mock transactions")
                single(.success(self.mockTransactions))
                return Disposables.create()
            }

            // 실제 API 호출
            self.networkService.request(TransactionAPI.getAccountTransactions(accountId: accountIdInt))
                .subscribe(onNext: { (result: Result<ApiResponseTransactionList, NetworkError>) in
                    switch result {
                    case .success(let apiResponse):
                        if let transactionResponses = apiResponse.data {
                            let transactions = transactionResponses.map { $0.toDomain() }
                            self.debugSuccess("Fetched \(transactions.count) transactions from API")
                            single(.success(transactions))
                        } else {
                            self.debugWarning("No transaction data in response, returning mock")
                            single(.success(self.mockTransactions))
                        }

                    case .failure(let error):
                        self.debugError("Failed to fetch transactions", error: error)
                        // 에러 시 Mock 데이터 반환
                        single(.success(self.mockTransactions))
                    }
                })
                .disposed(by: self.disposeBag)

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
