//
//  MockSavingsDataSource.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/19/25.
//

import Foundation

final class MockSavingsDataSource {

    static func getSavingsGoals() -> [SavingsGoal] {
        return [
           
        ]
    }

    static func getTotalSavings() -> Int {
        return getSavingsGoals().reduce(0) { $0 + $1.currentAmount }
    }

    static func getMonthlyGoalContribution() -> Int {
        return 45000
    }

    static func getSavingsRate() -> Double {
        let goals = getSavingsGoals()
        let totalTarget = goals.reduce(0) { $0 + $1.targetAmount }
        let totalCurrent = goals.reduce(0) { $0 + $1.currentAmount }

        guard totalTarget > 0 else { return 0 }
        return Double(totalCurrent) / Double(totalTarget) * 100
    }
}
