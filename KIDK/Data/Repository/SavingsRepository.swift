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

            // 실제 API 호출 - 공통 응답 포맷 사용
            self.fetchSavingsGoalsRaw(userId: userIdInt)
                .subscribe(onSuccess: { savingsResponses in
                    let goals = savingsResponses.map { $0.toDomain() }
                    self.debugSuccess("Fetched \(goals.count) savings goals from API")
                    single(.success(goals))
                }, onFailure: { error in
                    self.debugError("Failed to fetch savings goals from API", error: error)
                    // API 실패 시 Mock 데이터로 fallback
                    single(.success(MockSavingsDataSource.getSavingsGoals()))
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
            simpleDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            let targetDateString = goal.targetDate.map { simpleDateFormatter.string(from: $0) }

            // 실제 API 호출
            self.networkService.request(
                SavingsAPI.createSavings(
                    userId: request.userId,
                    goalName: request.name,
                    targetAmount: request.targetAmount,
                    targetDate: targetDateString
                )
            )
            .subscribe(onNext: { (result: Result<SavingsResponse, NetworkError>) in
                switch result {
                case .success(let savingsResponse):
                    let createdGoal = savingsResponse.toDomain()
                    self.debugSuccess("Savings goal created via API: \(createdGoal.name)")
                    single(.success(createdGoal))

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
            .subscribe(onNext: { (result: Result<SavingsResponse, NetworkError>) in
                switch result {
                case .success(let savingsResponse):
                    let updatedGoal = savingsResponse.toDomain()
                    self.debugSuccess("Deposited \(amount)원 to savings goal via API")
                    single(.success(updatedGoal))

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
            .subscribe(onNext: { (result: Result<SavingsResponse, NetworkError>) in
                switch result {
                case .success(let savingsResponse):
                    let updatedGoal = savingsResponse.toDomain()
                    self.debugSuccess("Withdrew \(amount)원 from savings goal via API")
                    single(.success(updatedGoal))

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
        return Single.create { [weak self] single in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) {
                let total = MockSavingsDataSource.getTotalSavings()
                self?.debugLog("Total savings: \(total)")
                single(.success(total))
            }
            return Disposables.create()
        }
    }

    func fetchMonthlyContribution() -> Single<Int> {
        return Single.create { [weak self] single in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) {
                let monthly = MockSavingsDataSource.getMonthlyGoalContribution()
                self?.debugLog("Monthly contribution: \(monthly)")
                single(.success(monthly))
            }
            return Disposables.create()
        }
    }

    func fetchSavingsRate() -> Single<Double> {
        return Single.create { [weak self] single in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) {
                let rate = MockSavingsDataSource.getSavingsRate()
                self?.debugLog("Savings rate: \(rate)%")
                single(.success(rate))
            }
            return Disposables.create()
        }
    }

    // MARK: - Raw Array Response Helper

    /// Savings API가 배열을 직접 반환하는지, 공통 응답 포맷을 사용하는지에 따라 분기 처리
    /// 먼저 공통 응답 포맷을 시도하고, 실패하면 직접 배열 파싱 시도
    private func fetchSavingsGoalsRaw(userId: Int) -> Single<[SavingsResponse]> {
        return Single.create { [weak self] single in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "SavingsRepository", code: -1))))
                return Disposables.create()
            }

            let baseURL = Environment.current.baseURL
            guard let url = URL(string: "\(baseURL)/savings-goals/user/\(userId)") else {
                single(.failure(RepositoryError.unknown(NSError(domain: "SavingsRepository", code: -2))))
                return Disposables.create()
            }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            if let accessToken = self.tokenManager.accessToken {
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    self.debugError("Raw fetch error", error: error)
                    single(.failure(RepositoryError.unknown(error)))
                    return
                }

                guard let data = data else {
                    single(.failure(RepositoryError.unknown(NSError(domain: "SavingsRepository", code: -3))))
                    return
                }

                // 1차 시도: 공통 응답 포맷 파싱
                do {
                    let apiResponse = try JSONDecoder().decode(ApiResponse<[SavingsResponse]>.self, from: data)
                    if apiResponse.success, let savingsData = apiResponse.data {
                        single(.success(savingsData))
                        return
                    } else {
                        self.debugError("API returned success=false", error: nil)
                        single(.failure(RepositoryError.unknown(NSError(domain: "SavingsRepository", code: -4))))
                        return
                    }
                } catch {
                    self.debugWarning("Failed to decode as ApiResponse, trying direct array parsing")
                }

                // 2차 시도: 직접 배열 파싱 (Account API처럼)
                do {
                    let savingsArray = try JSONDecoder().decode([SavingsResponse].self, from: data)
                    single(.success(savingsArray))
                } catch {
                    self.debugError("Failed to decode savings goals array", error: error)
                    single(.failure(RepositoryError.decodingError(error)))
                }
            }

            task.resume()
            return Disposables.create { task.cancel() }
        }
    }
}
