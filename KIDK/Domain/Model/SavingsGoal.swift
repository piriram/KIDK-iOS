//
//  SavingsGoal.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/19/25.
//

import Foundation
import UIKit

enum SavingsGoalStatus: String, Codable {
    case inProgress = "IN_PROGRESS"
    case completed = "COMPLETED"
    case cancelled = "CANCELLED"
}

struct SavingsGoal: Codable {
    let id: String
    let userId: String
    let name: String
    let targetAmount: Int
    let currentAmount: Int
    let imageName: String?
    let imageData: Data?
    let startDate: Date
    let targetDate: Date?
    let status: SavingsGoalStatus
    let createdAt: Date
    let completedAt: Date?
    let linkedMissionIds: [String]
    
    var progress: Double {
        guard targetAmount > 0 else { return 0 }
        return min(Double(currentAmount) / Double(targetAmount), 1.0)
    }
    
    var progressPercentage: Double {
        guard targetAmount > 0 else { return 0 }
        return min(Double(currentAmount) / Double(targetAmount) * 100, 100)
    }
    
    var remainingAmount: Int {
        return max(targetAmount - currentAmount, 0)
    }
    
    var daysRemaining: Int? {
        guard let targetDate = targetDate else { return nil }
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: Date(), to: targetDate).day
        return days
    }
    
    var savingsDuration: Int {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: startDate, to: Date()).day
        return days ?? 0
    }
    
    var formattedTargetAmount: String {
        return targetAmount.formattedCurrency
    }

    var formattedCurrentAmount: String {
        return currentAmount.formattedCurrency
    }

    var formattedTargetDate: String? {
        guard let date = targetDate else { return nil }
        return date.formattedFullDate
    }

    var formattedRemainingAmount: String {
        return remainingAmount.formattedCurrency
    }
}

struct SavingsStats: Codable {
    let totalSavings: Int
    let thisMonthSavings: Int
    let savingsRate: Double
    let totalAllowance: Int
    let currentStreak: Int
    let completedGoalsCount: Int
    let averageWeeklySavings: Int
    let averageMonthlySavings: Int
    
    var formattedTotalSavings: String {
        return totalSavings.formattedCurrency
    }

    var formattedThisMonthSavings: String {
        return thisMonthSavings.formattedCurrency
    }

    var formattedSavingsRate: String {
        return String(format: "%.1f%%", savingsRate)
    }
}

struct SavingsTransaction: Codable {
    let id: String
    let savingsGoalId: String
    let amount: Int
    let date: Date
    let source: String
    let note: String?
    
    var formattedAmount: String {
        let formatted = FormatterCache.shared.currencyFormatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
        return "+\(formatted)원"
    }
}

struct SavingsAchievement: Codable {
    let id: String
    let name: String
    let description: String
    let iconName: String
    let unlockedAt: Date?
    
    var isUnlocked: Bool {
        return unlockedAt != nil
    }
}
