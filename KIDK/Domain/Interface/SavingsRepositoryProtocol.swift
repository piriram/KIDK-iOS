import Foundation
import RxSwift

protocol SavingsRepositoryProtocol {
    func fetchSavingsGoals() -> Single<[SavingsGoal]>
    func fetchSavingsGoals(for userId: String) -> Single<[SavingsGoal]>
    func createSavingsGoal(_ goal: SavingsGoal) -> Single<SavingsGoal>
    func deposit(savingsId: String, amount: Int, accountId: String) -> Single<SavingsGoal>
    func withdraw(savingsId: String, amount: Int, accountId: String) -> Single<SavingsGoal>
    func fetchTotalSavings() -> Single<Int>
    func fetchMonthlyContribution() -> Single<Int>
    func fetchSavingsRate() -> Single<Double>
}
