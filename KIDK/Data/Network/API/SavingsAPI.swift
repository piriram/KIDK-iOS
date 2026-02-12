//
//  SavingsAPI.swift
//  KIDK
//
//  Created by KIDK on 12/02/24.
//

import Foundation

enum SavingsAPI {
    case createSavings(userId: Int, goalName: String, targetAmount: Double, targetDate: String?)
    case getSavingsByUser(userId: Int)
    case getSavingsGoal(goalId: Int)
    case deposit(savingsId: Int, amount: Double, accountId: Int)
    case withdraw(savingsId: Int, amount: Double, accountId: Int)
}

extension SavingsAPI: APIEndpoint {
    var path: String {
        switch self {
        case .createSavings:
            return "/savings-goals"
        case .getSavingsByUser(let userId):
            return "/savings-goals/user/\(userId)"
        case .getSavingsGoal(let goalId):
            return "/savings-goals/\(goalId)"
        case .deposit(let savingsId, _, _):
            return "/savings-goals/\(savingsId)/deposit"
        case .withdraw(let savingsId, _, _):
            return "/savings-goals/\(savingsId)/withdraw"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .createSavings, .deposit, .withdraw:
            return .post
        case .getSavingsByUser, .getSavingsGoal:
            return .get
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .createSavings(let userId, let goalName, let targetAmount, let targetDate):
            var params: [String: Any] = [
                "userId": userId,
                "goalName": goalName,
                "targetAmount": targetAmount
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
