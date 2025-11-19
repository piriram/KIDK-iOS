//
//  SavingsRepository.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/19/25.
//

import Foundation
import RxSwift

final class SavingsRepository: BaseRepository, SavingsRepositoryProtocol {

    func fetchSavingsGoals() -> Single<[SavingsGoal]> {
        return Single.create { single in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                let goals = MockSavingsDataSource.getSavingsGoals()
                self.debugLog("Fetched \(goals.count) savings goals")
                single(.success(goals))
            }
            return Disposables.create()
        }
    }

    func fetchTotalSavings() -> Single<Int> {
        return Single.create { single in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) {
                let total = MockSavingsDataSource.getTotalSavings()
                self.debugLog("Total savings: \(total)")
                single(.success(total))
            }
            return Disposables.create()
        }
    }

    func fetchMonthlyContribution() -> Single<Int> {
        return Single.create { single in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) {
                let monthly = MockSavingsDataSource.getMonthlyGoalContribution()
                self.debugLog("Monthly contribution: \(monthly)")
                single(.success(monthly))
            }
            return Disposables.create()
        }
    }

    func fetchSavingsRate() -> Single<Double> {
        return Single.create { single in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) {
                let rate = MockSavingsDataSource.getSavingsRate()
                self.debugLog("Savings rate: \(rate)%")
                single(.success(rate))
            }
            return Disposables.create()
        }
    }
}
