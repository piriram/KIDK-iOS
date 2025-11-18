//
//  Card.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/19/25.
//

import Foundation

enum CardStatus: String {
    case active = "ACTIVE"
    case suspended = "SUSPENDED"
    case expired = "EXPIRED"

    var displayName: String {
        switch self {
        case .active:
            return "활성"
        case .suspended:
            return "정지"
        case .expired:
            return "만료"
        }
    }
}

struct Card {
    let id: String
    let characterImageName: String
    let isPhysicalCard: Bool
    let status: CardStatus
    let lastFourDigits: String?

    var statusDescription: String {
        return "카드 상태: \(status.displayName)"
    }
}
