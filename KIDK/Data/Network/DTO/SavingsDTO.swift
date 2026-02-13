import Foundation

// MARK: - Savings Response

struct SavingsResponse: Decodable {
    let createdAt: String
    let updatedAt: String
    let id: Int
    let user: UserInfo
    let name: String
    let targetAmount: Double
    let currentAmount: Double
    let startDate: String
    let targetDate: String?
    let status: String
    let completedAt: String?
}

// MARK: - Savings Creation Request

struct SavingsCreationRequest: Encodable {
    let userId: Int
    let name: String
    let targetAmount: Double
    let startDate: String
    let targetDate: String?
    let status: String
}

// MARK: - Savings Deposit/Withdraw Request

struct SavingsTransactionRequest: Encodable {
    let amount: Double
    let accountId: Int
}

// MARK: - API Response Wrappers

typealias ApiResponseSavings = ApiResponse<SavingsResponse>
typealias ApiResponseSavingsList = ApiResponse<[SavingsResponse]>

// MARK: - DTO to Domain Model

extension SavingsResponse {
    func toDomain() -> SavingsGoal {
        // status 변환
        let goalStatus: SavingsGoalStatus
        switch status.uppercased() {
        case "IN_PROGRESS", "ACTIVE":
            goalStatus = .inProgress
        case "COMPLETED":
            goalStatus = .completed
        case "CANCELLED":
            goalStatus = .cancelled
        default:
            goalStatus = .inProgress
        }

        // ISO8601 날짜 파싱
        let dateFormatter = ISO8601DateFormatter()
        let createdDate = dateFormatter.date(from: createdAt) ?? Date()
        let completedDate = completedAt.flatMap { dateFormatter.date(from: $0) }

        // startDate와 targetDate는 "yyyy-MM-dd" 형식
        let simpleDateFormatter = DateFormatter()
        simpleDateFormatter.dateFormat = "yyyy-MM-dd"
        let startDateObject = simpleDateFormatter.date(from: startDate) ?? Date()
        let targetDateObject = targetDate.flatMap { simpleDateFormatter.date(from: $0) }

        return SavingsGoal(
            id: String(id),
            userId: String(user.id),
            name: name,
            targetAmount: Int(targetAmount),
            currentAmount: Int(currentAmount),
            imageName: nil,
            imageData: nil,
            startDate: startDateObject,
            targetDate: targetDateObject,
            status: goalStatus,
            createdAt: createdDate,
            completedAt: completedDate,
            linkedMissionIds: []
        )
    }
}

// MARK: - Domain to DTO

extension SavingsGoal {
    func toCreationRequest() -> SavingsCreationRequest? {
        guard let userIdInt = Int(userId) else { return nil }

        let simpleDateFormatter = DateFormatter()
        simpleDateFormatter.dateFormat = "yyyy-MM-dd"
        let startDateString = simpleDateFormatter.string(from: startDate)
        let targetDateString = targetDate.map { simpleDateFormatter.string(from: $0) }

        return SavingsCreationRequest(
            userId: userIdInt,
            name: name,
            targetAmount: Double(targetAmount),
            startDate: startDateString,
            targetDate: targetDateString,
            status: status.rawValue
        )
    }
}
