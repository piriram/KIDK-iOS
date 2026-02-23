import UIKit

struct MissionCardData {
    let iconName: String
    let title: String
    let subtitle: String
    let buttonTitle: String
}

struct SavingsGoalSummary {
    let dDayText: String
    let title: String
}

struct AccountCardData {
    let iconName: String
    let title: String
    let amount: Int
    let message: String?
    let goalSummary: SavingsGoalSummary?

    init(
        iconName: String,
        title: String,
        amount: Int,
        message: String?,
        goalSummary: SavingsGoalSummary? = nil
    ) {
        self.iconName = iconName
        self.title = title
        self.amount = amount
        self.message = message
        self.goalSummary = goalSummary
    }

    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formatted = formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
        return "\(formatted)원"
    }
}

struct MonthlyReportCardData {
    let month: Int
    let totalAmount: Int
    let categories: [CategorySpending]
    
    var monthText: String {
        return "\(month)월"
    }
    
    var formattedTotalAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formatted = formatter.string(from: NSNumber(value: totalAmount)) ?? "\(totalAmount)"
        return "총 \(formatted)원"
    }
}
