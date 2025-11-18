//
//  Account.swift
//  KIDK
//
//  Created by Claude on 11/18/25.
//

import Foundation

enum AccountType: String {
    case spending = "SPENDING"
    case savings = "SAVINGS"
    case goal = "GOAL"

    var displayName: String {
        switch self {
        case .spending:
            return "용돈 통장"
        case .savings:
            return "저축 통장"
        case .goal:
            return "목표 저축"
        }
    }
}

struct Account {
    let id: String
    let type: AccountType
    let name: String // 사용자 지정 별칭
    let balance: Int
    let isPrimary: Bool

    var formattedBalance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formatted = formatter.string(from: NSNumber(value: balance)) ?? "\(balance)"
        return "\(formatted)원"
    }
}
