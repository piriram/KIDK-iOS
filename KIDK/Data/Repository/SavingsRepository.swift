//
//  SavingsRepository.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/19/25.
//

import Foundation
import RxSwift

final class SavingsRepository: BaseRepository, SavingsRepositoryProtocol {

    static let shared = SavingsRepository()

    private override init(
        networkService: NetworkService = .shared,
        tokenManager: TokenManager = .shared
    ) {
        super.init(networkService: networkService, tokenManager: tokenManager)
    }

    func fetchSavingsGoals() -> Single<[SavingsGoal]> {
        return Single.create { [weak self] (single: @escaping (SingleEvent<[SavingsGoal]>) -> Void) -> Disposable in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "SavingsRepository", code: -1))))
                return Disposables.create()
            }

            // UserProfileManager에서 현재 사용자 ID 가져오기
            Task {
                guard let user = await UserProfileManager.shared.getCurrentUser() else {
                    self.debugWarning("No user found, returning mock savings goals")
                    single(.success(MockSavingsDataSource.getSavingsGoals()))
                    return
                }

                self.fetchSavingsGoals(for: user.id)
                    .subscribe(onSuccess: { goals in
                        single(.success(goals))
                    }, onFailure: { error in
                        single(.failure(error))
                    })
                    .disposed(by: self.disposeBag)
            }

            return Disposables.create()
        }
    }

    func fetchSavingsGoals(for userId: String) -> Single<[SavingsGoal]> {
        return Single.create { [weak self] (single: @escaping (SingleEvent<[SavingsGoal]>) -> Void) -> Disposable in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "SavingsRepository", code: -1))))
                return Disposables.create()
            }

            guard let userIdInt = Int(userId) else {
                self.debugWarning("Invalid userId, returning mock savings goals")
                single(.success(MockSavingsDataSource.getSavingsGoals()))
                return Disposables.create()
            }

            // 실제 API 호출
            self.networkService.request(SavingsAPI.getSavingsByUser(userId: userIdInt))
                .subscribe(onNext: { (result: Result<[SavingsResponse], NetworkError>) in
                    switch result {
                    case .success(let savingsResponses):
                        let goals = savingsResponses.map { $0.toDomain() }
                        self.debugSuccess("Fetched \(goals.count) savings goals from API")
                        single(.success(goals))

                    case .failure(let error):
                        self.debugError("Failed to fetch savings goals from API", error: error)
                        // API 실패 시 Mock 데이터로 fallback
                        single(.success(MockSavingsDataSource.getSavingsGoals()))
                    }
                })
                .disposed(by: self.disposeBag)

            return Disposables.create()
        }
    }

    func createSavingsGoal(_ goal: SavingsGoal) -> Single<SavingsGoal> {
        return Single.create { [weak self] (single: @escaping (SingleEvent<SavingsGoal>) -> Void) -> Disposable in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "SavingsRepository", code: -1))))
                return Disposables.create()
            }

            guard let request = goal.toCreationRequest() else {
                single(.failure(RepositoryError.invalidParameter))
                return Disposables.create()
            }

            let simpleDateFormatter = DateFormatter()
            simpleDateFormatter.dateFormat = "yyyy-MM-dd"
            let targetDateString = goal.targetDate.map { simpleDateFormatter.string(from: $0) }

            // 실제 API 호출
            self.networkService.request(
                SavingsAPI.createSavings(
                    userId: request.userId,
                    name: request.name,
                    targetAmount: request.targetAmount,
                    startDate: request.startDate,
                    targetDate: targetDateString,
                    status: request.status
                )
            )
            .subscribe(onNext: { (result: Result<ApiResponseSavings, NetworkError>) in
                switch result {
                case .success(let apiResponse):
                    if let savingsResponse = apiResponse.data {
                        let createdGoal = savingsResponse.toDomain()
                        self.debugSuccess("Savings goal created via API: \(createdGoal.name)")
                        single(.success(createdGoal))
                    } else {
                        self.debugWarning("API returned success but no data, returning original goal")
                        single(.success(goal))
                    }

                case .failure(let error):
                    self.debugError("Failed to create savings goal via API", error: error)
                    // API 실패 시에도 원본 goal 반환 (Mock으로 동작)
                    single(.success(goal))
                }
            })
            .disposed(by: self.disposeBag)

            return Disposables.create()
        }
    }

    func deposit(savingsId: String, amount: Int, accountId: String) -> Single<SavingsGoal> {
        return Single.create { [weak self] (single: @escaping (SingleEvent<SavingsGoal>) -> Void) -> Disposable in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "SavingsRepository", code: -1))))
                return Disposables.create()
            }

            guard let savingsIdInt = Int(savingsId), let accountIdInt = Int(accountId) else {
                single(.failure(RepositoryError.invalidParameter))
                return Disposables.create()
            }

            // 실제 API 호출
            self.networkService.request(
                SavingsAPI.deposit(
                    savingsId: savingsIdInt,
                    amount: Double(amount),
                    accountId: accountIdInt
                )
            )
            .subscribe(onNext: { (result: Result<ApiResponseSavings, NetworkError>) in
                switch result {
                case .success(let apiResponse):
                    if let savingsResponse = apiResponse.data {
                        let updatedGoal = savingsResponse.toDomain()
                        self.debugSuccess("Deposited \(amount)원 to savings goal via API")
                        single(.success(updatedGoal))
                    } else {
                        self.debugWarning("API returned success but no data")
                        single(.failure(RepositoryError.unknown(NSError(domain: "SavingsRepository", code: -2))))
                    }

                case .failure(let error):
                    self.debugError("Failed to deposit to savings goal via API", error: error)
                    single(.failure(RepositoryError.networkError(error)))
                }
            })
            .disposed(by: self.disposeBag)

            return Disposables.create()
        }
    }

    func withdraw(savingsId: String, amount: Int, accountId: String) -> Single<SavingsGoal> {
        return Single.create { [weak self] (single: @escaping (SingleEvent<SavingsGoal>) -> Void) -> Disposable in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "SavingsRepository", code: -1))))
                return Disposables.create()
            }

            guard let savingsIdInt = Int(savingsId), let accountIdInt = Int(accountId) else {
                single(.failure(RepositoryError.invalidParameter))
                return Disposables.create()
            }

            // 실제 API 호출
            self.networkService.request(
                SavingsAPI.withdraw(
                    savingsId: savingsIdInt,
                    amount: Double(amount),
                    accountId: accountIdInt
                )
            )
            .subscribe(onNext: { (result: Result<ApiResponseSavings, NetworkError>) in
                switch result {
                case .success(let apiResponse):
                    if let savingsResponse = apiResponse.data {
                        let updatedGoal = savingsResponse.toDomain()
                        self.debugSuccess("Withdrew \(amount)원 from savings goal via API")
                        single(.success(updatedGoal))
                    } else {
                        self.debugWarning("API returned success but no data")
                        single(.failure(RepositoryError.unknown(NSError(domain: "SavingsRepository", code: -2))))
                    }

                case .failure(let error):
                    self.debugError("Failed to withdraw from savings goal via API", error: error)
                    single(.failure(RepositoryError.networkError(error)))
                }
            })
            .disposed(by: self.disposeBag)

            return Disposables.create()
        }
    }

    func fetchTotalSavings() -> Single<Int> {
        return Single.create { single in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) {
                let total = MockSavingsDataSource.getTotalSavings()
                self.debugLog("Total savings: \(total)")
                single(.success(total))
            }
            return Disposables.create()
        }
    }

    func fetchMonthlyContribution() -> Single<Int> {
        return Single.create { single in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) {
                let monthly = MockSavingsDataSource.getMonthlyGoalContribution()
                self.debugLog("Monthly contribution: \(monthly)")
                single(.success(monthly))
            }
            return Disposables.create()
        }
    }

    func fetchSavingsRate() -> Single<Double> {
        return Single.create { single in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) {
                let rate = MockSavingsDataSource.getSavingsRate()
                self.debugLog("Savings rate: \(rate)%")
                single(.success(rate))
            }
            return Disposables.create()
        }
    }
}
