//
//  Notification+Names.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/19/25.
//

import Foundation

extension Notification.Name {
    /// 거래가 생성되었을 때 발송되는 알림
    static let transactionCreated = Notification.Name("transactionCreated")

    /// 계좌 잔액이 변경되었을 때 발송되는 알림
    static let accountBalanceUpdated = Notification.Name("accountBalanceUpdated")

    /// 저축 목표가 변경되었을 때 발송되는 알림
    static let savingsGoalUpdated = Notification.Name("savingsGoalUpdated")
}
