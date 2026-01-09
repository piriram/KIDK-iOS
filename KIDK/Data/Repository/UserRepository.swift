import Foundation
import RxSwift

final class UserRepository: BaseRepository, UserRepositoryProtocol {

    static let shared = UserRepository()

    private override init(
        networkService: NetworkService = .shared,
        tokenManager: TokenManager = .shared
    ) {
        super.init(networkService: networkService, tokenManager: tokenManager)
    }

    // MARK: - API Methods with Mock Fallback

    func getMyProfile() -> Single<User> {
        return Single.create { [weak self] single in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "UserRepository", code: -1))))
                return Disposables.create()
            }

            // Try API first
            self.networkService.request(UserAPI.getMyProfile)
                .subscribe(onNext: { (result: Result<UserResponse, NetworkError>) in
                    switch result {
                    case .success(let userResponse):
                        let user = userResponse.toDomain()

                        // Sync with UserProfileManager
                        Task {
                            await UserProfileManager.shared.saveProfile(user)
                        }

                        self.debugSuccess("Fetched user profile via API: \(user.id)")
                        single(.success(user))

                    case .failure(let error):
                        self.debugError("Failed to fetch user profile via API, using UserProfileManager", error: error)
                        // Fallback to UserProfileManager
                        self.getUserFromProfileManager(single: single)
                    }
                })
                .disposed(by: self.disposeBag)

            return Disposables.create()
        }
    }

    func getUserProfile(userId: String) -> Single<User> {
        return Single.create { [weak self] single in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "UserRepository", code: -1))))
                return Disposables.create()
            }

            // Convert String ID to Int
            guard let userIdInt = Int(userId) else {
                self.debugError("Invalid user ID format: \(userId)")
                single(.failure(RepositoryError.invalidParameter))
                return Disposables.create()
            }

            // Try API first
            self.networkService.request(UserAPI.getUserProfile(userId: userIdInt))
                .subscribe(onNext: { (result: Result<UserResponse, NetworkError>) in
                    switch result {
                    case .success(let userResponse):
                        let user = userResponse.toDomain()
                        self.debugSuccess("Fetched user profile via API: \(user.id)")
                        single(.success(user))

                    case .failure(let error):
                        self.debugError("Failed to fetch user profile via API", error: error)
                        single(.failure(RepositoryError.networkError(error)))
                    }
                })
                .disposed(by: self.disposeBag)

            return Disposables.create()
        }
    }

    func updateProfile(name: String, birthDate: Date?, phone: String?) -> Single<User> {
        return Single.create { [weak self] single in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "UserRepository", code: -1))))
                return Disposables.create()
            }

            // Convert Date to yyyy-MM-dd String
            let birthDateString: String?
            if let date = birthDate {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                birthDateString = dateFormatter.string(from: date)
            } else {
                birthDateString = nil
            }

            // Try API first
            self.networkService.request(
                UserAPI.updateProfile(
                    name: name,
                    birthDate: birthDateString,
                    phone: phone,
                    userType: nil
                )
            )
            .subscribe(onNext: { (result: Result<UserResponse, NetworkError>) in
                switch result {
                case .success(let userResponse):
                    let user = userResponse.toDomain()

                    // Sync with UserProfileManager
                    Task {
                        await UserProfileManager.shared.saveProfile(user)
                    }

                    self.debugSuccess("Updated user profile via API: \(user.id)")
                    single(.success(user))

                case .failure(let error):
                    self.debugError("Failed to update user profile via API, updating locally", error: error)
                    self.updateProfileMock(name: name, birthDate: birthDate, single: single)
                }
            })
            .disposed(by: self.disposeBag)

            return Disposables.create()
        }
    }

    func updateStatus(status: UserStatus) -> Single<User> {
        return Single.create { [weak self] single in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "UserRepository", code: -1))))
                return Disposables.create()
            }

            // Try API first
            self.networkService.request(UserAPI.updateStatus(status: status.rawValue))
                .subscribe(onNext: { (result: Result<UserResponse, NetworkError>) in
                    switch result {
                    case .success(let userResponse):
                        let user = userResponse.toDomain()

                        // Sync with UserProfileManager
                        Task {
                            await UserProfileManager.shared.saveProfile(user)
                        }

                        self.debugSuccess("Updated user status via API: \(status.rawValue)")
                        single(.success(user))

                    case .failure(let error):
                        self.debugError("Failed to update status via API", error: error)
                        single(.failure(RepositoryError.networkError(error)))
                    }
                })
                .disposed(by: self.disposeBag)

            return Disposables.create()
        }
    }

    // MARK: - Mock Fallback Helpers

    private func getUserFromProfileManager(single: @escaping (SingleEvent<User>) -> Void) {
        Task {
            guard let user = await UserProfileManager.shared.getCurrentUser() else {
                self.debugError("No user in UserProfileManager")
                single(.failure(RepositoryError.notFound))
                return
            }

            self.debugSuccess("Using user from UserProfileManager (Mock)")
            single(.success(user))
        }
    }

    private func updateProfileMock(name: String, birthDate: Date?, single: @escaping (SingleEvent<User>) -> Void) {
        Task {
            guard var user = await UserProfileManager.shared.getCurrentUser() else {
                self.debugError("No user in UserProfileManager")
                single(.failure(RepositoryError.notFound))
                return
            }

            // Update user locally
            user.name = name
            user.birthdate = birthDate

            await UserProfileManager.shared.saveProfile(user)

            self.debugSuccess("Updated user profile (Mock)")
            single(.success(user))
        }
    }
}
