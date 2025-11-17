//
//  AccountCardModel.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/16/25.
//

import UIKit

struct MissionCardData {
    let iconName: String
    let title: String
    let subtitle: String
    let buttonTitle: String
}

struct AccountCardData {
    let iconName: String
    let title: String
    let amount: Int
    let message: String?
    
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formatted = formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
        return "\(formatted)원"
    }
}

struct MonthlyReportCardData {
    let month: Int
    let totalAmount: Int
    let categories: [CategorySpending]
    
    var monthText: String {
        return "\(month)월"
    }
    
    var formattedTotalAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formatted = formatter.string(from: NSNumber(value: totalAmount)) ?? "\(totalAmount)"
        return "총 \(formatted)원"
    }
}
