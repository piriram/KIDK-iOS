import Foundation

enum AccountAPI {
    case createAccount(userId: Int, accountType: String, accountName: String, initialBalance: Double)
    case getAccount(accountId: Int, userId: Int)
    case getUserAccounts(userId: Int)
    case getPrimaryAccount(userId: Int)
    case getActiveAccounts(userId: Int)
}

extension AccountAPI: APIEndpoint {
    var path: String {
        switch self {
        case .createAccount:
            return "/accounts"
        case .getAccount(let accountId, _):
            return "/accounts/\(accountId)"
        case .getUserAccounts(let userId):
            return "/accounts/user/\(userId)"
        case .getPrimaryAccount(let userId):
            return "/accounts/user/\(userId)/primary"
        case .getActiveAccounts(let userId):
            return "/accounts/user/\(userId)/active"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .createAccount:
            return .post
        case .getAccount, .getUserAccounts, .getPrimaryAccount, .getActiveAccounts:
            return .get
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .createAccount(let userId, let accountType, let accountName, let initialBalance):
            return [
                "userId": userId,
                "accountType": accountType,
                "accountName": accountName,
                "initialBalance": initialBalance
            ]
        case .getAccount(_, let userId):
            // Query parameter는 별도 처리 필요
            return ["userId": userId]
        default:
            return nil
        }
    }

    var headers: [String: String]? {
        return nil
    }

    var requiresAuth: Bool {
        return true // 모든 Account API는 인증 필요
    }
}
