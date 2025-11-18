//
//  SavingsGoal.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/19/25.
//

import Foundation

struct SavingsGoal {
    let id: String
    let name: String
    let targetAmount: Int
    let currentAmount: Int
    let targetDate: Date?
    let linkedMissionIds: [String]

    var progress: Double {
        guard targetAmount > 0 else { return 0 }
        return min(Double(currentAmount) / Double(targetAmount), 1.0)
    }

    var progressPercentage: Int {
        return Int(progress * 100)
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

    var remainingAmount: Int {
        return max(targetAmount - currentAmount, 0)
    }

    var formattedRemainingAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formatted = formatter.string(from: NSNumber(value: remainingAmount)) ?? "\(remainingAmount)"
        return "\(formatted)원"
    }
}
