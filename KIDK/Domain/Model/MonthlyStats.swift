import Foundation

/// 부모 앱에서 사용하는 자녀의 이번 달 통계
struct MonthlyStats {
    let totalSpending: Int
    let totalSavings: Int
    let dailyLimit: Int
    let usagePercentage: Double

    init(totalSpending: Int = 0, totalSavings: Int = 0, dailyLimit: Int = 10000, usagePercentage: Double = 0) {
        self.totalSpending = totalSpending
        self.totalSavings = totalSavings
        self.dailyLimit = dailyLimit
        self.usagePercentage = usagePercentage
    }

    var formattedTotalSpending: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formatted = formatter.string(from: NSNumber(value: totalSpending)) ?? "\(totalSpending)"
        return "\(formatted)원"
    }

    var formattedTotalSavings: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formatted = formatter.string(from: NSNumber(value: totalSavings)) ?? "\(totalSavings)"
        return "\(formatted)원"
    }

    var formattedDailyLimit: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formatted = formatter.string(from: NSNumber(value: dailyLimit)) ?? "\(dailyLimit)"
        return "\(formatted)원"
    }
}
