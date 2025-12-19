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
            .subscribe(onNext: { (result: Result<TransactionResponse, NetworkError>) in
                switch result {
                case .success(let transactionResponse):
                    let transaction = transactionResponse.toDomain()
                    self.debugSuccess("Transaction created via API: \(type.displayName) \(amount)원")

                    // Post notification for UI update
                    NotificationCenter.default.post(name: .transactionCreated, object: transaction)

                    single(.success(transaction))

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
                .subscribe(onNext: { (result: Result<[TransactionResponse], NetworkError>) in
                    switch result {
                    case .success(let transactionResponses):
                        let transactions = transactionResponses.map { $0.toDomain() }
                        self.debugSuccess("Fetched \(transactions.count) transactions from API")
                        single(.success(transactions))

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

    func transfer(
        fromAccountId: String,
        toAccountId: String,
        amount: Int,
        description: String
    ) -> Single<Void> {
        return Single.create { [weak self] (single: @escaping (SingleEvent<Void>) -> Void) -> Disposable in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "TransactionRepository", code: -1))))
                return Disposables.create()
            }

            guard let fromAccountIdInt = Int(fromAccountId),
                  let toAccountIdInt = Int(toAccountId) else {
                single(.failure(RepositoryError.invalidParameter))
                return Disposables.create()
            }

            // Transfer API는 {success: true} 형태로 반환하므로 raw helper 사용
            self.transferRaw(
                fromAccountId: fromAccountIdInt,
                toAccountId: toAccountIdInt,
                amount: amount,
                description: description
            )
            .subscribe(onSuccess: { _ in
                self.debugSuccess("Transfer successful: \(amount)원 from \(fromAccountId) to \(toAccountId)")

                // Post notification for UI update
                NotificationCenter.default.post(
                    name: .transactionCreated,
                    object: nil,
                    userInfo: [
                        "type": "transfer",
                        "fromAccountId": fromAccountId,
                        "toAccountId": toAccountId,
                        "amount": amount
                    ]
                )

                single(.success(()))
            }, onFailure: { error in
                self.debugError("Failed to transfer", error: error)
                single(.failure(RepositoryError.networkError(error as? NetworkError ?? NetworkError.unknown(error))))
            })
            .disposed(by: self.disposeBag)

            return Disposables.create()
        }
    }

    // MARK: - Raw Response Helpers

    /// Transfer API는 {success: true} 형태로 직접 반환
    private func transferRaw(
        fromAccountId: Int,
        toAccountId: Int,
        amount: Int,
        description: String
    ) -> Single<Void> {
        return Single.create { [weak self] single in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "TransactionRepository", code: -1))))
                return Disposables.create()
            }

            let baseURL = Environment.current.baseURL
            guard let url = URL(string: "\(baseURL)/transactions/transfer") else {
                single(.failure(RepositoryError.unknown(NSError(domain: "TransactionRepository", code: -2))))
                return Disposables.create()
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            if let accessToken = self.tokenManager.accessToken {
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }

            let params: [String: Any] = [
                "fromAccountId": fromAccountId,
                "toAccountId": toAccountId,
                "amount": Double(amount),
                "description": description
            ]

            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: params)
            } catch {
                single(.failure(RepositoryError.unknown(error)))
                return Disposables.create()
            }

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    self.debugError("Transfer request error", error: error)
                    single(.failure(RepositoryError.unknown(error)))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    self.debugError("No HTTP response", error: nil)
                    single(.failure(RepositoryError.unknown(NSError(domain: "TransactionRepository", code: -3))))
                    return
                }

                guard httpResponse.statusCode == 200 else {
                    self.debugError("Transfer failed with status \(httpResponse.statusCode)", error: nil)
                    single(.failure(RepositoryError.unknown(NSError(
                        domain: "TransactionRepository",
                        code: httpResponse.statusCode,
                        userInfo: [NSLocalizedDescriptionKey: "Server returned error \(httpResponse.statusCode)"]
                    ))))
                    return
                }

                // {success: true} 응답만 확인
                self.debugSuccess("Transfer API call successful")
                single(.success(()))
            }

            task.resume()
            return Disposables.create { task.cancel() }
        }
    }

    // MARK: - Category & Statistics

    func fetchTransactionsByCategory(
        for userId: String,
        category: TransactionCategory
    ) -> Single<[Transaction]> {
        return fetchAllTransactions(for: userId)
            .map { transactions in
                transactions.filter { $0.category == category && $0.type == .withdrawal }
            }
    }

    func fetchAllTransactions(for userId: String) -> Single<[Transaction]> {
        return accountRepository.getAllAccounts()
            .flatMap { [weak self] accounts -> Single<[Transaction]> in
                guard let self = self else {
                    return Single.just([])
                }

                // 계좌가 없으면 빈 배열 반환
                guard !accounts.isEmpty else {
                    return Single.just([])
                }

                // 첫 번째 계좌만 있는 경우
                if accounts.count == 1 {
                    return self.fetchTransactions(for: accounts[0].id)
                }

                // 여러 계좌가 있는 경우
                return self.fetchMultipleAccountTransactions(accounts: accounts)
            }
    }

    private func fetchMultipleAccountTransactions(accounts: [Account]) -> Single<[Transaction]> {
        // 재귀적으로 거래 내역 합치기
        return fetchTransactionsRecursive(accounts: accounts, index: 0, accumulated: [])
    }

    private func fetchTransactionsRecursive(
        accounts: [Account],
        index: Int,
        accumulated: [Transaction]
    ) -> Single<[Transaction]> {
        // 모든 계좌를 처리했으면 정렬해서 반환
        guard index < accounts.count else {
            let sorted = accumulated.sorted { (t1: Transaction, t2: Transaction) -> Bool in
                return t1.date > t2.date
            }
            return Single.just(sorted)
        }

        // 현재 계좌의 거래 내역 가져오기
        let account = accounts[index]
        return fetchTransactions(for: account.id)
            .catchAndReturn([])
            .flatMap { [weak self] (transactions: [Transaction]) -> Single<[Transaction]> in
                guard let self = self else {
                    return Single.just(accumulated)
                }
                // 다음 계좌로 재귀 호출
                let newAccumulated = accumulated + transactions
                return self.fetchTransactionsRecursive(
                    accounts: accounts,
                    index: index + 1,
                    accumulated: newAccumulated
                )
            }
    }

    func fetchCategoryStatistics(for userId: String) -> Single<[TransactionCategory: Int]> {
        return fetchAllTransactions(for: userId)
            .map { transactions in
                var statistics: [TransactionCategory: Int] = [:]

                // 출금 거래만 필터링하여 카테고리별로 합산
                let withdrawals = transactions.filter { $0.type == .withdrawal }

                for transaction in withdrawals {
                    if let category = transaction.category {
                        statistics[category, default: 0] += transaction.amount
                    }
                }

                return statistics
            }
    }
}
