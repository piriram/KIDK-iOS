//
//  SavingsRepositoryProtocol.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/19/25.
//

import Foundation
import RxSwift

protocol SavingsRepositoryProtocol {
    func fetchSavingsGoals() -> Single<[SavingsGoal]>
    func fetchTotalSavings() -> Single<Int>
    func fetchMonthlyContribution() -> Single<Int>
    func fetchSavingsRate() -> Single<Double>
}
