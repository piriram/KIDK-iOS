//
//  FriendRepository.swift
//  KIDK
//
//  Created by KIDK on 12/02/24.
//

import Foundation
import RxSwift

final class FriendRepository: BaseRepository, FriendRepositoryProtocol {

    static let shared = FriendRepository()

    private override init(
        networkService: NetworkService = .shared,
        tokenManager: TokenManager = .shared
    ) {
        super.init(networkService: networkService, tokenManager: tokenManager)
    }

    func sendFriendRequest(_ request: FriendRequest) -> Single<Friend> {
        return Single.create { [weak self] (single: @escaping (SingleEvent<Friend>) -> Void) -> Disposable in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "FriendRepository", code: -1))))
                return Disposables.create()
            }

            guard let dto = request.toDTO() else {
                single(.failure(RepositoryError.invalidParameter))
                return Disposables.create()
            }

            // 실제 API 호출
            self.networkService.request(
                FriendAPI.sendFriendRequest(
                    requesterId: dto.requesterId,
                    addresseeId: dto.addresseeId
                )
            )
            .subscribe(onNext: { (result: Result<ApiResponseFriend, NetworkError>) in
                switch result {
                case .success(let apiResponse):
                    if let friendResponse = apiResponse.data {
                        let friend = friendResponse.toDomain()
                        self.debugSuccess("Friend request sent via API")
                        single(.success(friend))
                    } else {
                        self.debugWarning("API returned success but no data")
                        single(.failure(RepositoryError.unknown(NSError(domain: "FriendRepository", code: -2))))
                    }

                case .failure(let error):
                    self.debugError("Failed to send friend request via API", error: error)
                    single(.failure(RepositoryError.networkError(error)))
                }
            })
            .disposed(by: self.disposeBag)

            return Disposables.create()
        }
    }

    func getFriends(for userId: String) -> Single<[Friend]> {
        return Single.create { [weak self] (single: @escaping (SingleEvent<[Friend]>) -> Void) -> Disposable in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "FriendRepository", code: -1))))
                return Disposables.create()
            }

            guard let userIdInt = Int(userId) else {
                self.debugWarning("Invalid userId, returning empty friends")
                single(.success([]))
                return Disposables.create()
            }

            // 실제 API 호출
            self.networkService.request(FriendAPI.getFriends(userId: userIdInt))
                .subscribe(onNext: { (result: Result<[FriendResponse], NetworkError>) in
                    switch result {
                    case .success(let friendResponses):
                        let friends = friendResponses.map { $0.toDomain() }
                        self.debugSuccess("Fetched \(friends.count) friends from API")
                        single(.success(friends))

                    case .failure(let error):
                        self.debugError("Failed to fetch friends from API", error: error)
                        // API 실패 시 빈 배열 반환
                        single(.success([]))
                    }
                })
                .disposed(by: self.disposeBag)

            return Disposables.create()
        }
    }

    func deleteFriend(friendId: String) -> Completable {
        return Completable.create { [weak self] completable in
            guard let self = self else {
                completable(.error(RepositoryError.unknown(NSError(domain: "FriendRepository", code: -1))))
                return Disposables.create()
            }

            guard let friendIdInt = Int(friendId) else {
                completable(.error(RepositoryError.invalidParameter))
                return Disposables.create()
            }

            // 실제 API 호출
            self.networkService.request(FriendAPI.deleteFriend(friendId: friendIdInt))
                .subscribe(onNext: { (result: Result<ApiResponse<EmptyResponse>, NetworkError>) in
                    switch result {
                    case .success:
                        self.debugSuccess("Friend deleted via API")
                        completable(.completed)

                    case .failure(let error):
                        self.debugError("Failed to delete friend via API", error: error)
                        completable(.error(RepositoryError.networkError(error)))
                    }
                })
                .disposed(by: self.disposeBag)

            return Disposables.create()
        }
    }
}
