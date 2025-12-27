import Foundation

// MARK: - Create Account Request

struct CreateAccountRequest: Encodable {
    let userId: Int
    let accountType: String
    let accountName: String
    let initialBalance: Double
}

// MARK: - Account Response

struct AccountResponse: Decodable {
    let id: Int
    let userId: Int
    let accountType: String
    let accountName: String
    let balance: Double
    let active: Bool
    let primary: Bool
}

// MARK: - DTO to Domain Model

extension AccountResponse {
    func toDomain() -> Account {
        // accountType 문자열을 AccountType enum으로 변환
        let type: AccountType
        switch accountType.uppercased() {
        case "SPENDING":
            type = .spending
        case "SAVINGS":
            type = .savings
        case "GOAL":
            type = .goal
        default:
            type = .spending
        }

        return Account(
            id: String(id),
            type: type,
            name: accountName,
            balance: Int(balance),
            isPrimary: primary
        )
    }
}

// MARK: - API Response Wrappers

typealias ApiResponseAccountResponse = ApiResponse<AccountResponse>
typealias ApiResponseAccountList = ApiResponse<[AccountResponse]>
