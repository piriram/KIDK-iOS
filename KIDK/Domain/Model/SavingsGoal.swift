//
//  SavingsGoal.swift
//  KIDK
//
//  Created by Claude on 11/18/25.
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
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formatted = formatter.string(from: NSNumber(value: targetAmount)) ?? "\(targetAmount)"
        return "\(formatted)원"
    }

    var formattedCurrentAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formatted = formatter.string(from: NSNumber(value: currentAmount)) ?? "\(currentAmount)"
        return "\(formatted)원"
    }

    var formattedTargetDate: String? {
        guard let date = targetDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일"
        return formatter.string(from: date)
    }

    var formattedRemainingAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formatted = formatter.string(from: NSNumber(value: remainingAmount)) ?? "\(remainingAmount)"
        return "\(formatted)원"
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
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formatted = formatter.string(from: NSNumber(value: totalSavings)) ?? "\(totalSavings)"
        return "\(formatted)원"
    }

    var formattedThisMonthSavings: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formatted = formatter.string(from: NSNumber(value: thisMonthSavings)) ?? "\(thisMonthSavings)"
        return "\(formatted)원"
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
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formatted = formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
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
