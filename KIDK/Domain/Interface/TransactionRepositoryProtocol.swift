//
//  TransactionRepositoryProtocol.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/19/25.
//

import Foundation
import RxSwift

protocol TransactionRepositoryProtocol {
    func createTransaction(
        accountId: String,
        type: TransactionType,
        amount: Int,
        category: TransactionCategory?,
        description: String,
        memo: String?
    ) -> Single<Transaction>

    func fetchTransactions(for accountId: String) -> Single<[Transaction]>

    func updateAccountBalance(
        accountId: String,
        newBalance: Int
    ) -> Single<Account>

    func getAccount(id: String) -> Single<Account?>
}
