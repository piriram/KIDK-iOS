import Foundation

enum TransactionAPI {
    case createTransaction(accountId: Int, type: String, amount: Double, category: String, description: String, relatedMissionId: Int?)
    case getAccountTransactions(accountId: Int)
    case transfer(fromAccountId: Int, toAccountId: Int, amount: Double, description: String)
}

extension TransactionAPI: APIEndpoint {
    var path: String {
        switch self {
        case .createTransaction:
            return "/transactions"
        case .getAccountTransactions(let accountId):
            return "/transactions/account/\(accountId)"
        case .transfer:
            return "/transactions/transfer"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .createTransaction, .transfer:
            return .post
        case .getAccountTransactions:
            return .get
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .createTransaction(let accountId, let type, let amount, let category, let description, let relatedMissionId):
            var params: [String: Any] = [
                "accountId": accountId,
                "type": type,
                "amount": amount,
                "category": category,
                "description": description
            ]
            if let missionId = relatedMissionId {
                params["relatedMissionId"] = missionId
            }
            return params

        case .transfer(let fromAccountId, let toAccountId, let amount, let description):
            return [
                "fromAccountId": fromAccountId,
                "toAccountId": toAccountId,
                "amount": amount,
                "description": description
            ]

        default:
            return nil
        }
    }

    var headers: [String: String]? {
        return nil
    }

    var requiresAuth: Bool {
        return true
    }
}
