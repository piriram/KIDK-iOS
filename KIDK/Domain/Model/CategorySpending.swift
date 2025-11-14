//
//  CategorySpending.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/15/25.
//

import Foundation
import UIKit

struct CategorySpending {
    let category: String
    let amount: Int
    let percentage: Double
    let color: UIColor
    
    init(category: String, amount: Int, totalAmount: Int, color: UIColor) {
        self.category = category
        self.amount = amount
        self.percentage = totalAmount > 0 ? Double(amount) / Double(totalAmount) : 0
        self.color = color
    }
}
