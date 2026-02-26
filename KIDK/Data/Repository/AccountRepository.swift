import Foundation
import RxSwift

final class AccountRepository: BaseRepository, AccountRepositoryProtocol {

    static let shared = AccountRepository()

    private override init(
        networkService: NetworkService = .shared,
        tokenManager: TokenManager = .shared
    ) {
        super.init(networkService: networkService, tokenManager: tokenManager)
    }

    private var mockAccounts: [Account] = [
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

    func getAllAccounts() -> Single<[Account]> {
        return Single.create { [weak self] (single: @escaping (SingleEvent<[Account]>) -> Void) -> Disposable in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "AccountRepository", code: -1))))
                return Disposables.create()
            }

            // UserProfileManager에서 현재 사용자 ID 가져오기
            Task {
                guard let user = await UserProfileManager.shared.getCurrentUser(),
                      let userId = Int(user.id) else {
                    // 사용자 정보 없으면 Mock 데이터 반환
                    self.debugWarning("No user found, returning mock accounts")
                    single(.success(self.mockAccounts))
                    return
                }

                // 실제 API 호출
                // ⚠️ 주의: Account API는 공통 응답 포맷을 사용하지 않고 배열을 직접 반환
                self.fetchAccountsRaw(userId: userId)
                    .subscribe(onSuccess: { accountResponses in
                        let accounts = accountResponses.map { $0.toDomain() }

                        // 계좌가 없으면 기본 계좌 자동 생성
                        if accounts.isEmpty {
                            self.debugWarning("No accounts found, creating default accounts")
                            self.createDefaultAccounts()
                                .subscribe(onSuccess: { defaultAccounts in
                                    self.debugSuccess("Created \(defaultAccounts.count) default accounts")
                                    single(.success(defaultAccounts))
                                }, onFailure: { error in
                                    self.debugError("Failed to create default accounts", error: error)
                                    // 기본 계좌 생성 실패해도 Mock 반환
                                    single(.success(self.mockAccounts))
                                })
                                .disposed(by: self.disposeBag)
                        } else {
                            self.debugSuccess("Fetched \(accounts.count) accounts from API")
                            single(.success(accounts))
                        }
                    }, onFailure: { error in
                        self.debugError("Failed to fetch accounts", error: error)
                        // 서버 에러일 경우 계좌가 없을 가능성이 높으므로 자동 생성 시도
                        self.debugWarning("Attempting to create default accounts due to server error")
                        self.createDefaultAccounts()
                            .subscribe(onSuccess: { defaultAccounts in
                                self.debugSuccess("Created \(defaultAccounts.count) default accounts after error")
                                single(.success(defaultAccounts))
                            }, onFailure: { createError in
                                self.debugError("Failed to create default accounts", error: createError)
                                // 계좌 생성도 실패하면 Mock 반환
                                single(.success(self.mockAccounts))
                            })
                            .disposed(by: self.disposeBag)
                    })
                    .disposed(by: self.disposeBag)
            }

            return Disposables.create()
        }
    }

    private func createDefaultAccounts() -> Single<[Account]> {
        return Single.create { [weak self] (single: @escaping (SingleEvent<[Account]>) -> Void) -> Disposable in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "AccountRepository", code: -1))))
                return Disposables.create()
            }

            // 내 지갑 (SPENDING) 생성
            let spendingAccountSingle = self.createAccount(
                type: .spending,
                name: "내 지갑",
                balance: 0,
                isPrimary: true
            )

            // 내 저금통 (SAVINGS) 생성
            let savingsAccountSingle = self.createAccount(
                type: .savings,
                name: "내 저금통",
                balance: 0,
                isPrimary: false
            )

            // 두 계좌를 순차적으로 생성
            spendingAccountSingle
                .flatMap { spendingAccount in
                    savingsAccountSingle.map { savingsAccount in
                        [spendingAccount, savingsAccount]
                    }
                }
                .subscribe(onSuccess: { accounts in
                    single(.success(accounts))
                }, onFailure: { error in
                    single(.failure(error))
                })
                .disposed(by: self.disposeBag)

            return Disposables.create()
        }
    }

    func getAccount(id: String) -> Single<Account?> {
        return Single.create { [weak self] (single: @escaping (SingleEvent<Account?>) -> Void) -> Disposable in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "AccountRepository", code: -1))))
                return Disposables.create()
            }

            let account = self.mockAccounts.first(where: { $0.id == id })
            if let account = account {
                self.debugSuccess("Found account: \(account.name)")
            } else {
                self.debugWarning("Account not found: \(id)")
            }
            single(.success(account))
            return Disposables.create()
        }
    }

    func getPrimaryAccount() -> Single<Account?> {
        return Single.create { [weak self] (single: @escaping (SingleEvent<Account?>) -> Void) -> Disposable in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "AccountRepository", code: -1))))
                return Disposables.create()
            }

            // UserProfileManager에서 현재 사용자 ID 가져오기
            Task {
                guard let user = await UserProfileManager.shared.getCurrentUser(),
                      let userId = Int(user.id) else {
                    // 사용자 정보 없으면 Mock 데이터 반환
                    let primaryAccount = self.mockAccounts.first(where: { $0.isPrimary })
                    self.debugWarning("No user found, returning mock primary account")
                    single(.success(primaryAccount))
                    return
                }

                // 실제 API 호출
                self.networkService.request(AccountAPI.getPrimaryAccount(userId: userId))
                    .subscribe(onNext: { (result: Result<AccountResponse, NetworkError>) in
                        switch result {
                        case .success(let accountResponse):
                            let account = accountResponse.toDomain()
                            self.debugSuccess("Found primary account: \(account.name)")
                            single(.success(account))
                        case .failure(let error):
                            self.debugError("Failed to fetch primary account", error: error)
                            // 에러 시 Mock 데이터 반환
                            let primaryAccount = self.mockAccounts.first(where: { $0.isPrimary })
                            single(.success(primaryAccount))
                        }
                    })
                    .disposed(by: self.disposeBag)
            }

            return Disposables.create()
        }
    }

    func getTotalBalance() -> Single<Int> {
        return Single.create { [weak self] (single: @escaping (SingleEvent<Int>) -> Void) -> Disposable in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "AccountRepository", code: -1))))
                return Disposables.create()
            }

            let totalBalance = self.mockAccounts.reduce(0) { $0 + $1.balance }
            self.debugSuccess("Total balance: \(totalBalance)원")
            single(.success(totalBalance))
            return Disposables.create()
        }
    }

    func updateAccountBalance(accountId: String, newBalance: Int) -> Single<Account> {
        return Single.create { [weak self] (single: @escaping (SingleEvent<Account>) -> Void) -> Disposable in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "AccountRepository", code: -1))))
                return Disposables.create()
            }

            guard let accountIndex = self.mockAccounts.firstIndex(where: { $0.id == accountId }) else {
                single(.failure(RepositoryError.notFound))
                return Disposables.create()
            }

            self.mockAccounts[accountIndex] = Account(
                id: accountId,
                type: self.mockAccounts[accountIndex].type,
                name: self.mockAccounts[accountIndex].name,
                balance: newBalance,
                isPrimary: self.mockAccounts[accountIndex].isPrimary
            )

            self.debugSuccess("Updated account balance: \(self.mockAccounts[accountIndex].name) -> \(newBalance)원")
            single(.success(self.mockAccounts[accountIndex]))
            return Disposables.create()
        }
    }

    func createAccount(type: AccountType, name: String, balance: Int, isPrimary: Bool) -> Single<Account> {
        return Single.create { [weak self] (single: @escaping (SingleEvent<Account>) -> Void) -> Disposable in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "AccountRepository", code: -1))))
                return Disposables.create()
            }

            // UserProfileManager에서 현재 사용자 ID 가져오기
            Task {
                guard let user = await UserProfileManager.shared.getCurrentUser(),
                      let userId = Int(user.id) else {
                    // 사용자 정보 없으면 Mock 계좌만 생성
                    let newAccount = Account(
                        id: UUID().uuidString,
                        type: type,
                        name: name,
                        balance: balance,
                        isPrimary: isPrimary
                    )
                    self.mockAccounts.append(newAccount)
                    self.debugWarning("No user found, created mock account: \(name)")
                    single(.success(newAccount))
                    return
                }

                // 실제 API 호출
                let accountTypeString: String
                switch type {
                case .spending:
                    accountTypeString = "SPENDING"
                case .savings:
                    accountTypeString = "SAVINGS"
                case .goal:
                    accountTypeString = "GOAL"
                }

                self.networkService.request(
                    AccountAPI.createAccount(
                        userId: userId,
                        accountType: accountTypeString,
                        accountName: name,
                        initialBalance: Double(balance)
                    )
                )
                .subscribe(onNext: { (result: Result<AccountResponse, NetworkError>) in
                    switch result {
                    case .success(let accountResponse):
                        let account = accountResponse.toDomain()
                        self.debugSuccess("Created new account via API: \(account.name)")
                        single(.success(account))
                    case .failure(let error):
                        self.debugError("Failed to create account", error: error)
                        // 에러 시 Mock 계좌 생성
                        let newAccount = Account(
                            id: UUID().uuidString,
                            type: type,
                            name: name,
                            balance: balance,
                            isPrimary: isPrimary
                        )
                        self.mockAccounts.append(newAccount)
                        single(.success(newAccount))
                    }
                })
                .disposed(by: self.disposeBag)
            }

            return Disposables.create()
        }
    }

    // MARK: - Raw Array Response Helper

    /// 배열을 직접 반환하는 엔드포인트를 위한 헬퍼 메서드
    /// ⚠️ Account API는 공통 응답 포맷({success, data})을 사용하지 않음
    private func fetchAccountsRaw(userId: Int) -> Single<[AccountResponse]> {
        return Single.create { [weak self] single in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "AccountRepository", code: -1))))
                return Disposables.create()
            }

            let baseURL = Environment.current.baseURL
            guard let url = URL(string: "\(baseURL)/accounts/user/\(userId)") else {
                single(.failure(RepositoryError.unknown(NSError(domain: "AccountRepository", code: -2))))
                return Disposables.create()
            }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            request = self.applyAuthHeader(to: request)

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    self.debugError("Raw fetch error", error: error)
                    single(.failure(RepositoryError.unknown(error)))
                    return
                }

                guard let data = data else {
                    single(.failure(RepositoryError.unknown(NSError(domain: "AccountRepository", code: -3))))
                    return
                }

                do {
                    let accounts = try JSONDecoder().decode([AccountResponse].self, from: data)
                    single(.success(accounts))
                } catch {
                    self.debugError("Failed to decode accounts array", error: error)
                    single(.failure(RepositoryError.decodingError(error)))
                }
            }

            task.resume()
            return Disposables.create { task.cancel() }
        }
    }
}
