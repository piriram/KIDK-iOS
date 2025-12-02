//
//  SavingsAPI.swift
//  KIDK
//
//  Created by KIDK on 12/02/24.
//

import Foundation

enum SavingsAPI {
    case createSavings(userId: Int, name: String, targetAmount: Double, startDate: String, targetDate: String?, status: String)
    case getSavingsByUser(userId: Int)
    case deposit(savingsId: Int, amount: Double, accountId: Int)
    case withdraw(savingsId: Int, amount: Double, accountId: Int)
}

extension SavingsAPI: APIEndpoint {
    var path: String {
        switch self {
        case .createSavings:
            return "/savings"
        case .getSavingsByUser(let userId):
            return "/savings/user/\(userId)"
        case .deposit(let savingsId, _, _):
            return "/savings/\(savingsId)/deposit"
        case .withdraw(let savingsId, _, _):
            return "/savings/\(savingsId)/withdraw"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .createSavings, .deposit, .withdraw:
            return .post
        case .getSavingsByUser:
            return .get
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .createSavings(let userId, let name, let targetAmount, let startDate, let targetDate, let status):
            var params: [String: Any] = [
                "userId": userId,
                "name": name,
                "targetAmount": targetAmount,
                "startDate": startDate,
                "status": status
            ]
            if let date = targetDate {
                params["targetDate"] = date
            }
            return params

        case .deposit(_, let amount, let accountId), .withdraw(_, let amount, let accountId):
            return [
                "amount": amount,
                "accountId": accountId
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
