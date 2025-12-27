import Foundation

/// 부모 앱에서 사용하는 자녀 정보 모델
struct ChildInfo {
    let user: User
    let level: Int
    let points: Int
    let totalBalance: Int

    init(user: User, level: Int = 1, points: Int = 0, totalBalance: Int = 0) {
        self.user = user
        self.level = level
        self.points = points
        self.totalBalance = totalBalance
    }

    var formattedBalance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formatted = formatter.string(from: NSNumber(value: totalBalance)) ?? "\(totalBalance)"
        return "\(formatted)원"
    }
}
