//
//  SavingsViewModel.swift
//  KIDK
//
//  Created by Claude on 11/18/25.
//

import Foundation
import RxSwift
import RxCocoa

final class SavingsViewModel: BaseViewModel {

    struct Input {
        let viewDidLoad: Observable<Void>
        let goalSelected: Observable<SavingsGoal>
        let refreshTrigger: Observable<Void>
    }

    struct Output {
        let isLoading: Driver<Bool>
        let stats: Driver<SavingsStats>
        let inProgressGoals: Driver<[SavingsGoal]>
        let completedGoals: Driver<[SavingsGoal]>
        let error: Driver<String>
    }

    private let user: User
    private let statsRelay = BehaviorRelay<SavingsStats>(value: SavingsViewModel.createMockStats())
    private let inProgressGoalsRelay = BehaviorRelay<[SavingsGoal]>(value: SavingsViewModel.createMockInProgressGoals())
    private let completedGoalsRelay = BehaviorRelay<[SavingsGoal]>(value: SavingsViewModel.createMockCompletedGoals())
    private let errorRelay = PublishRelay<String>()

    init(user: User) {
        self.user = user
        super.init()
        debugLog("SavingsViewModel initialized with user: \(user.name)")
    }

    func transform(input: Input) -> Output {
        input.viewDidLoad
            .subscribe(onNext: { [weak self] in
                self?.loadSavingsData()
            })
            .disposed(by: disposeBag)

        input.refreshTrigger
            .subscribe(onNext: { [weak self] in
                self?.loadSavingsData()
            })
            .disposed(by: disposeBag)

        input.goalSelected
            .subscribe(onNext: { [weak self] goal in
                self?.debugLog("Goal selected: \(goal.name)")
            })
            .disposed(by: disposeBag)

        return Output(
            isLoading: isLoading.asDriver(),
            stats: statsRelay.asDriver(),
            inProgressGoals: inProgressGoalsRelay.asDriver(),
            completedGoals: completedGoalsRelay.asDriver(),
            error: errorRelay.asDriver(onErrorJustReturn: "알 수 없는 오류가 발생했습니다.")
        )
    }

    private func loadSavingsData() {
        isLoading.accept(true)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isLoading.accept(false)
        }
    }

    // MARK: - Mock Data
    private static func createMockStats() -> SavingsStats {
        return SavingsStats(
            totalSavings: 50000,
            thisMonthSavings: 15000,
            savingsRate: 35.5,
            totalAllowance: 42000,
            currentStreak: 7,
            completedGoalsCount: 2,
            averageWeeklySavings: 3500,
            averageMonthlySavings: 14000
        )
    }

    private static func createMockInProgressGoals() -> [SavingsGoal] {
        return [
            SavingsGoal(
                id: "goal1",
                userId: "user1",
                name: "새 자전거 사기",
                targetAmount: 150000,
                currentAmount: 50000,
                imageName: "bicycle",
                imageData: nil,
                startDate: Date().addingTimeInterval(-30 * 24 * 60 * 60),
                targetDate: Date().addingTimeInterval(60 * 24 * 60 * 60),
                status: .inProgress,
                createdAt: Date().addingTimeInterval(-30 * 24 * 60 * 60),
                completedAt: nil,
                linkedMissionIds: ["mission1"]
            ),
            SavingsGoal(
                id: "goal2",
                userId: "user1",
                name: "레고 세트",
                targetAmount: 80000,
                currentAmount: 65000,
                imageName: "toy",
                imageData: nil,
                startDate: Date().addingTimeInterval(-20 * 24 * 60 * 60),
                targetDate: Date().addingTimeInterval(30 * 24 * 60 * 60),
                status: .inProgress,
                createdAt: Date().addingTimeInterval(-20 * 24 * 60 * 60),
                completedAt: nil,
                linkedMissionIds: []
            ),
            SavingsGoal(
                id: "goal3",
                userId: "user1",
                name: "놀이공원 가기",
                targetAmount: 50000,
                currentAmount: 35000,
                imageName: "amusement",
                imageData: nil,
                startDate: Date().addingTimeInterval(-15 * 24 * 60 * 60),
                targetDate: Date().addingTimeInterval(45 * 24 * 60 * 60),
                status: .inProgress,
                createdAt: Date().addingTimeInterval(-15 * 24 * 60 * 60),
                completedAt: nil,
                linkedMissionIds: ["mission2", "mission3"]
            )
        ]
    }

    private static func createMockCompletedGoals() -> [SavingsGoal] {
        return [
            SavingsGoal(
                id: "goal_completed1",
                userId: "user1",
                name: "책가방",
                targetAmount: 40000,
                currentAmount: 40000,
                imageName: "bag",
                imageData: nil,
                startDate: Date().addingTimeInterval(-90 * 24 * 60 * 60),
                targetDate: Date().addingTimeInterval(-5 * 24 * 60 * 60),
                status: .completed,
                createdAt: Date().addingTimeInterval(-90 * 24 * 60 * 60),
                completedAt: Date().addingTimeInterval(-5 * 24 * 60 * 60),
                linkedMissionIds: []
            ),
            SavingsGoal(
                id: "goal_completed2",
                userId: "user1",
                name: "게임기",
                targetAmount: 200000,
                currentAmount: 200000,
                imageName: "game",
                imageData: nil,
                startDate: Date().addingTimeInterval(-180 * 24 * 60 * 60),
                targetDate: Date().addingTimeInterval(-30 * 24 * 60 * 60),
                status: .completed,
                createdAt: Date().addingTimeInterval(-180 * 24 * 60 * 60),
                completedAt: Date().addingTimeInterval(-30 * 24 * 60 * 60),
                linkedMissionIds: ["mission4"]
            )
        ]
    }
}
