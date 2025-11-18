//
//  WalletViewModel.swift
//  KIDK
//
//  Created by Claude on 11/18/25.
//

import Foundation
import RxSwift
import RxCocoa

final class WalletViewModel {

    // MARK: - Inputs

    // MARK: - Outputs
    let accounts: BehaviorRelay<[Account]>
    let transactions: BehaviorRelay<[Transaction]>
    let savingsGoals: BehaviorRelay<[SavingsGoal]>
    let card: BehaviorRelay<Card?>
    let userLevel: BehaviorRelay<Int>
    let userExperience: BehaviorRelay<Int>
    let dailySpendingLimit: BehaviorRelay<Int>

    private let disposeBag = DisposeBag()

    init() {
        // Mock 데이터 초기화
        let mockAccounts = [
            Account(
                id: "1",
                type: .spending,
                name: "내 용돈 통장",
                balance: 12450,
                isPrimary: true
            ),
            Account(
                id: "2",
                type: .savings,
                name: "내 저축 통장",
                balance: 50000,
                isPrimary: false
            ),
            Account(
                id: "3",
                type: .goal,
                name: "놀이공원 가기",
                balance: 30000,
                isPrimary: false
            )
        ]

        let mockTransactions = [
            Transaction(
                id: "1",
                type: .missionReward,
                category: nil,
                amount: 1000,
                description: "책 30분 읽기 미션 완료",
                memo: nil,
                balanceAfter: 12450,
                date: Date().addingTimeInterval(-3600)
            ),
            Transaction(
                id: "2",
                type: .withdrawal,
                category: .food,
                amount: 3500,
                description: "편의점 간식",
                memo: "초코바, 우유",
                balanceAfter: 11450,
                date: Date().addingTimeInterval(-7200)
            ),
            Transaction(
                id: "3",
                type: .deposit,
                category: nil,
                amount: 5000,
                description: "용돈",
                memo: "엄마가 주신 용돈",
                balanceAfter: 14950,
                date: Date().addingTimeInterval(-86400)
            ),
            Transaction(
                id: "4",
                type: .withdrawal,
                category: .shopping,
                amount: 15000,
                description: "문구점",
                memo: "노트, 필통",
                balanceAfter: 9950,
                date: Date().addingTimeInterval(-172800)
            ),
            Transaction(
                id: "5",
                type: .transfer,
                category: nil,
                amount: 10000,
                description: "저축 통장으로 이체",
                memo: nil,
                balanceAfter: 24950,
                date: Date().addingTimeInterval(-259200)
            )
        ]

        let mockSavingsGoals = [
            SavingsGoal(
                id: "1",
                name: "놀이공원 가기",
                targetAmount: 50000,
                currentAmount: 30000,
                targetDate: Calendar.current.date(byAdding: .day, value: 30, to: Date()),
                linkedMissionIds: ["mission1", "mission2"]
            ),
            SavingsGoal(
                id: "2",
                name: "새 자전거 사기",
                targetAmount: 200000,
                currentAmount: 45000,
                targetDate: Calendar.current.date(byAdding: .day, value: 90, to: Date()),
                linkedMissionIds: []
            )
        ]

        let mockCard = Card(
            id: "1",
            characterImageName: "kidk_profile_one",
            isPhysicalCard: true,
            status: .active,
            lastFourDigits: "1234"
        )

        self.accounts = BehaviorRelay(value: mockAccounts)
        self.transactions = BehaviorRelay(value: mockTransactions)
        self.savingsGoals = BehaviorRelay(value: mockSavingsGoals)
        self.card = BehaviorRelay(value: mockCard)
        self.userLevel = BehaviorRelay(value: 5)
        self.userExperience = BehaviorRelay(value: 650)
        self.dailySpendingLimit = BehaviorRelay(value: 10000)
    }

    // MARK: - Methods
    func refreshData() {
        // TODO: API 호출로 실제 데이터 가져오기
        // 현재는 mock 데이터 사용
    }

    func getPrimaryAccount() -> Account? {
        return accounts.value.first { $0.isPrimary }
    }

    func getTotalBalance() -> Int {
        return accounts.value.reduce(0) { $0 + $1.balance }
    }

    func getTransactionsByDate() -> [String: [Transaction]] {
        let calendar = Calendar.current
        var groupedTransactions: [String: [Transaction]] = [:]

        for transaction in transactions.value {
            let dateString = transaction.formattedDateWithDay
            if groupedTransactions[dateString] == nil {
                groupedTransactions[dateString] = []
            }
            groupedTransactions[dateString]?.append(transaction)
        }

        return groupedTransactions
    }

    func filterTransactions(by type: TransactionType?) -> [Transaction] {
        guard let type = type else {
            return transactions.value
        }
        return transactions.value.filter { $0.type == type }
    }

    func filterTransactions(by category: TransactionCategory?) -> [Transaction] {
        guard let category = category else {
            return transactions.value
        }
        return transactions.value.filter { $0.category == category }
    }
}
