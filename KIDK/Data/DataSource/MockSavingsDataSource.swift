//
//  MockSavingsDataSource.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/19/25.
//

import Foundation

final class MockSavingsDataSource {

    static func getSavingsGoals() -> [SavingsGoal] {
        let calendar = Calendar.current
        let now = Date()

        return [
            // 1. 진행 중인 저축 - 새 자전거 사기
            SavingsGoal(
                id: "savings_1",
                userId: "user_1",
                name: "새 자전거 사기",
                targetAmount: 150000,
                currentAmount: 85000,
                imageName: "bicycle",
                imageData: nil,
                startDate: calendar.date(byAdding: .day, value: -30, to: now)!,
                targetDate: calendar.date(byAdding: .day, value: 30, to: now),
                status: .inProgress,
                createdAt: calendar.date(byAdding: .day, value: -30, to: now)!,
                completedAt: nil,
                linkedMissionIds: ["mission_1", "mission_2"]
            ),

            // 2. 진행 중인 저축 - 새 게임기
            SavingsGoal(
                id: "savings_2",
                userId: "user_1",
                name: "새 게임기",
                targetAmount: 300000,
                currentAmount: 120000,
                imageName: "gamecontroller",
                imageData: nil,
                startDate: calendar.date(byAdding: .day, value: -45, to: now)!,
                targetDate: calendar.date(byAdding: .day, value: 60, to: now),
                status: .inProgress,
                createdAt: calendar.date(byAdding: .day, value: -45, to: now)!,
                completedAt: nil,
                linkedMissionIds: ["mission_3"]
            ),

            // 3. 진행 중인 저축 - 가족 여행 기금
            SavingsGoal(
                id: "savings_3",
                userId: "user_1",
                name: "가족 여행 기금",
                targetAmount: 200000,
                currentAmount: 145000,
                imageName: "airplane",
                imageData: nil,
                startDate: calendar.date(byAdding: .day, value: -60, to: now)!,
                targetDate: calendar.date(byAdding: .day, value: 20, to: now),
                status: .inProgress,
                createdAt: calendar.date(byAdding: .day, value: -60, to: now)!,
                completedAt: nil,
                linkedMissionIds: ["mission_4", "mission_5"]
            ),

            // 4. 진행 중인 저축 - 친구 생일 선물
            SavingsGoal(
                id: "savings_4",
                userId: "user_1",
                name: "친구 생일 선물",
                targetAmount: 50000,
                currentAmount: 35000,
                imageName: "gift",
                imageData: nil,
                startDate: calendar.date(byAdding: .day, value: -15, to: now)!,
                targetDate: calendar.date(byAdding: .day, value: 10, to: now),
                status: .inProgress,
                createdAt: calendar.date(byAdding: .day, value: -15, to: now)!,
                completedAt: nil,
                linkedMissionIds: []
            ),

            // 5. 진행 중인 저축 - 새 운동화
            SavingsGoal(
                id: "savings_5",
                userId: "user_1",
                name: "새 운동화",
                targetAmount: 80000,
                currentAmount: 25000,
                imageName: "shoe",
                imageData: nil,
                startDate: calendar.date(byAdding: .day, value: -10, to: now)!,
                targetDate: calendar.date(byAdding: .day, value: 50, to: now),
                status: .inProgress,
                createdAt: calendar.date(byAdding: .day, value: -10, to: now)!,
                completedAt: nil,
                linkedMissionIds: ["mission_6"]
            ),

            // 6. 완료된 저축 - 새 책가방
            SavingsGoal(
                id: "savings_6",
                userId: "user_1",
                name: "새 책가방",
                targetAmount: 60000,
                currentAmount: 60000,
                imageName: "bag",
                imageData: nil,
                startDate: calendar.date(byAdding: .day, value: -90, to: now)!,
                targetDate: calendar.date(byAdding: .day, value: -5, to: now),
                status: .completed,
                createdAt: calendar.date(byAdding: .day, value: -90, to: now)!,
                completedAt: calendar.date(byAdding: .day, value: -5, to: now),
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
