import Foundation

struct MissionProgress {
    let id: String
    let missionId: String
    let userId: String
    let progressAmount: Double?
    let progressPercentage: Double?
    let lastActivityAt: Date

    /// Formatted progress percentage (0-100)
    var formattedPercentage: String {
        guard let percentage = progressPercentage else { return "0%" }
        return String(format: "%.0f%%", min(percentage, 100.0))
    }

    /// Formatted progress amount
    var formattedAmount: String? {
        guard let amount = progressAmount else { return nil }
        return String(format: "%.0f", amount)
    }
}
