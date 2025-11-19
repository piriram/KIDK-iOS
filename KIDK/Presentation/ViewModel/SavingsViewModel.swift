//
//  SavingsViewModel.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/19/25.
//

import Foundation
import RxSwift
import RxCocoa

final class SavingsViewModel: BaseViewModel {

    struct Input {
        let viewDidLoad: Observable<Void>
        let refreshTriggered: Observable<Void>
        let filterSelected: Observable<SavingsFilter>
        let createGoalTapped: Observable<Void>
    }

    struct Output {
        let savingsGoals: Driver<[SavingsGoal]>
        let totalSavings: Driver<Int>
        let monthlyContribution: Driver<Int>
        let savingsRate: Driver<Double>
        let isEmpty: Driver<Bool>
        let isLoading: Driver<Bool>
    }

    enum SavingsFilter {
        case all
        case inProgress
        case completed
    }

    private let savingsRepository: SavingsRepositoryProtocol

    private let savingsGoalsRelay = BehaviorRelay<[SavingsGoal]>(value: [])
    private let totalSavingsRelay = BehaviorRelay<Int>(value: 0)
    private let monthlyContributionRelay = BehaviorRelay<Int>(value: 0)
    private let savingsRateRelay = BehaviorRelay<Double>(value: 0)
    private let currentFilter = BehaviorRelay<SavingsFilter>(value: .all)

    init(savingsRepository: SavingsRepositoryProtocol) {
        self.savingsRepository = savingsRepository
        super.init()
    }

    func transform(input: Input) -> Output {
        let loadTrigger = Observable.merge(
            input.viewDidLoad,
            input.refreshTriggered
        )

        loadTrigger
            .do(onNext: { [weak self] in
                self?.isLoading.accept(true)
            })
            .flatMapLatest { [weak self] _ -> Observable<[SavingsGoal]> in
                guard let self = self else { return .empty() }
                return self.savingsRepository.fetchSavingsGoals()
                    .asObservable()
                    .catch { error in
                        self.debugError("Failed to fetch savings goals", error: error)
                        self.error.onNext(error)
                        return .just([])
                    }
            }
            .do(onNext: { [weak self] _ in
                self?.isLoading.accept(false)
            })
            .bind(to: savingsGoalsRelay)
            .disposed(by: disposeBag)

        loadTrigger
            .flatMapLatest { [weak self] _ -> Observable<Int> in
                guard let self = self else { return .empty() }
                return self.savingsRepository.fetchTotalSavings()
                    .asObservable()
                    .catch { _ in .just(0) }
            }
            .bind(to: totalSavingsRelay)
            .disposed(by: disposeBag)

        loadTrigger
            .flatMapLatest { [weak self] _ -> Observable<Int> in
                guard let self = self else { return .empty() }
                return self.savingsRepository.fetchMonthlyContribution()
                    .asObservable()
                    .catch { _ in .just(0) }
            }
            .bind(to: monthlyContributionRelay)
            .disposed(by: disposeBag)

        loadTrigger
            .flatMapLatest { [weak self] _ -> Observable<Double> in
                guard let self = self else { return .empty() }
                return self.savingsRepository.fetchSavingsRate()
                    .asObservable()
                    .catch { _ in .just(0) }
            }
            .bind(to: savingsRateRelay)
            .disposed(by: disposeBag)

        input.filterSelected
            .bind(to: currentFilter)
            .disposed(by: disposeBag)

        let filteredGoals = Observable.combineLatest(
            savingsGoalsRelay.asObservable(),
            currentFilter.asObservable()
        )
        .map { goals, filter -> [SavingsGoal] in
            switch filter {
            case .all:
                return goals
            case .inProgress:
                return goals.filter { $0.progressPercentage < 100 }
            case .completed:
                return goals.filter { $0.progressPercentage >= 100 }
            }
        }

        let isEmpty = filteredGoals
            .map { $0.isEmpty }

        return Output(
            savingsGoals: filteredGoals.asDriver(onErrorJustReturn: []),
            totalSavings: totalSavingsRelay.asDriver(),
            monthlyContribution: monthlyContributionRelay.asDriver(),
            savingsRate: savingsRateRelay.asDriver(),
            isEmpty: isEmpty.asDriver(onErrorJustReturn: true),
            isLoading: isLoading.asDriver()
        )
    }
}
