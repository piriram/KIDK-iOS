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

    func transfer(
        fromAccountId: String,
        toAccountId: String,
        amount: Int,
        description: String
    ) -> Single<Void>

    // 카테고리별 거래 내역 조회
    func fetchTransactionsByCategory(
        for userId: String,
        category: TransactionCategory
    ) -> Single<[Transaction]>

    // 특정 사용자의 모든 거래 내역 조회
    func fetchAllTransactions(for userId: String) -> Single<[Transaction]>

    // 카테고리별 통계 (금액 합계)
    func fetchCategoryStatistics(for userId: String) -> Single<[TransactionCategory: Int]>
}
