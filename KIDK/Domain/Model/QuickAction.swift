//
//  QuickAction.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/19/25.
//

import Foundation
import UIKit

enum QuickActionType {
    case deposit      // 입금하기
    case withdraw     // 출금하기
    case transfer     // 송금하기
    case scanReceipt  // 영수증 스캔

    var title: String {
        switch self {
        case .deposit:
            return "입금하기"
        case .withdraw:
            return "출금하기"
        case .transfer:
            return "송금하기"
        case .scanReceipt:
            return "영수증 스캔"
        }
    }

    var iconName: String {
        switch self {
        case .deposit:
            return "plus.circle.fill"
        case .withdraw:
            return "minus.circle.fill"
        case .transfer:
            return "arrow.left.arrow.right.circle.fill"
        case .scanReceipt:
            return "doc.text.viewfinder"
        }
    }

    var iconColor: UIColor {
        switch self {
        case .deposit:
            return .kidkGreen
        case .withdraw:
            return .kidkPink
        case .transfer:
            return .kidkBlue
        case .scanReceipt:
            return .systemOrange
        }
    }
}

struct QuickAction {
    let type: QuickActionType
}
