//
//  Transaction.swift
//  KIDK
//
//  Created by Claude on 11/18/25.
//

import Foundation
import UIKit

enum TransactionType: String {
    case deposit = "DEPOSIT"           // 입금
    case withdrawal = "WITHDRAWAL"     // 출금
    case transfer = "TRANSFER"         // 이체
    case missionReward = "MISSION_REWARD" // 미션 보상

    var displayName: String {
        switch self {
        case .deposit:
            return "입금"
        case .withdrawal:
            return "출금"
        case .transfer:
            return "이체"
        case .missionReward:
            return "미션 보상"
        }
    }

    var sign: String {
        switch self {
        case .deposit, .missionReward:
            return "+"
        case .withdrawal, .transfer:
            return "-"
        }
    }
}

enum TransactionCategory: String {
    case food = "음식"
    case shopping = "쇼핑"
    case transport = "교통"
    case school = "학용품"
    case toy = "장난감"
    case game = "게임"
    case book = "책"
    case etc = "기타"

    var iconName: String {
        switch self {
        case .food:
            return "kidk_category_food"
        case .shopping:
            return "kidk_category_shopping"
        case .transport:
            return "kidk_category_transport"
        case .school:
            return "kidk_icon_pencil"
        case .toy, .game:
            return "kidk_icon_bowl"
        case .book:
            return "kidk_icon_home"
        case .etc:
            return "kidk_icon_exclamation"
        }
    }

    var color: UIColor {
        switch self {
        case .food:
            return .kidkPink
        case .shopping:
            return .kidkGreen
        case .transport:
            return .kidkBlue
        default:
            return .kidkGray
        }
    }
}

struct Transaction {
    let id: String
    let type: TransactionType
    let category: TransactionCategory?
    let amount: Int
    let description: String
    let memo: String?
    let balanceAfter: Int
    let date: Date

    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formatted = formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
        return "\(type.sign)\(formatted)원"
    }

    var formattedBalanceAfter: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formatted = formatter.string(from: NSNumber(value: balanceAfter)) ?? "\(balanceAfter)"
        return "\(formatted)원"
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    var formattedDateWithDay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일"
        return formatter.string(from: date)
    }
}
