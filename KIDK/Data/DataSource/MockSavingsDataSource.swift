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
            SavingsGoal(
                id: "1",
                name: "닌텐도 스위치 사기",
                targetAmount: 300000,
                currentAmount: 75000,
                targetDate: Calendar.current.date(byAdding: .month, value: 3, to: Date()),
                linkedMissionIds: ["mission1", "mission2"]
            ),
            SavingsGoal(
                id: "2",
                name: "친구 생일 선물",
                targetAmount: 50000,
                currentAmount: 30000,
                targetDate: Calendar.current.date(byAdding: .day, value: 15, to: Date()),
                linkedMissionIds: ["mission3"]
            ),
            SavingsGoal(
                id: "3",
                name: "놀이공원 가기",
                targetAmount: 100000,
                currentAmount: 85000,
                targetDate: Calendar.current.date(byAdding: .month, value: 1, to: Date()),
                linkedMissionIds: []
            ),
            SavingsGoal(
                id: "4",
                name: "레고 세트",
                targetAmount: 80000,
                currentAmount: 80000,
                targetDate: Date().addingTimeInterval(-86400),
                linkedMissionIds: ["mission4"]
            ),
            SavingsGoal(
                id: "5",
                name: "자전거 사기",
                targetAmount: 200000,
                currentAmount: 50000,
                targetDate: nil,
                linkedMissionIds: []
            )
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
