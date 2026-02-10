//
//  AccountRepositoryProtocol.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/19/25.
//

import Foundation
import RxSwift

protocol AccountRepositoryProtocol {
    /// 모든 계좌 목록 조회
    func getAllAccounts() -> Single<[Account]>

    /// 특정 계좌 조회
    func getAccount(id: String) -> Single<Account?>

    /// 주 계좌 조회
    func getPrimaryAccount() -> Single<Account?>

    /// 전체 잔액 조회
    func getTotalBalance() -> Single<Int>

    /// 계좌 잔액 업데이트
    func updateAccountBalance(accountId: String, newBalance: Int) -> Single<Account>

    /// 계좌 생성
    func createAccount(type: AccountType, name: String, balance: Int, isPrimary: Bool) -> Single<Account>
}
