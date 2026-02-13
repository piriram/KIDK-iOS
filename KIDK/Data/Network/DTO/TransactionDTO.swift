import Foundation

// MARK: - Create Transaction Request

struct CreateTransactionRequest: Encodable {
    let accountId: Int
    let type: String           // "DEPOSIT", "WITHDRAWAL"
    let amount: Double
    let category: String       // "MISSION_REWARD", 카테고리명
    let description: String
    let relatedMissionId: Int?
}

// MARK: - Transfer Request

struct TransferRequest: Encodable {
    let fromAccountId: Int
    let toAccountId: Int
    let amount: Double
    let description: String
}

// MARK: - Transaction Response

struct TransactionResponse: Decodable {
    let id: Int
    let accountId: Int
    let type: String
    let amount: Double
    let balanceAfter: Double
    let category: String
    let description: String
    let createdAt: String      // ISO8601 date string
}

// MARK: - API Response Wrapper

typealias ApiResponseTransaction = ApiResponse<TransactionResponse>
typealias ApiResponseTransactionList = ApiResponse<[TransactionResponse]>

// MARK: - DTO to Domain Model

extension TransactionResponse {
    func toDomain() -> Transaction {
        // type 문자열을 TransactionType enum으로 변환
        let transactionType: TransactionType
        switch type.uppercased() {
        case "DEPOSIT":
            transactionType = .deposit
        case "WITHDRAWAL":
            transactionType = .withdrawal
        case "TRANSFER":
            transactionType = .transfer
        case "MISSION_REWARD":
            transactionType = .missionReward
        default:
            transactionType = .deposit
        }

        // category 문자열을 TransactionCategory enum으로 변환
        let transactionCategory: TransactionCategory?
        if category.uppercased() == "MISSION_REWARD" {
            transactionCategory = nil
        } else {
            transactionCategory = TransactionCategory(rawValue: category)
        }

        // ISO8601 날짜 파싱
        let dateFormatter = ISO8601DateFormatter()
        let date = dateFormatter.date(from: createdAt) ?? Date()

        return Transaction(
            id: String(id),
            type: transactionType,
            category: transactionCategory,
            amount: Int(amount),
            description: description,
            memo: nil,
            balanceAfter: Int(balanceAfter),
            date: date
        )
    }
}
