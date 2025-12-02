//
//  FamilyRepository.swift
//  KIDK
//
//  Created by KIDK on 12/02/24.
//

import Foundation
import RxSwift

final class FamilyRepository: BaseRepository, FamilyRepositoryProtocol {

    static let shared = FamilyRepository()

    private override init(
        networkService: NetworkService = .shared,
        tokenManager: TokenManager = .shared
    ) {
        super.init(networkService: networkService, tokenManager: tokenManager)
    }

    // MARK: - Family

    func createFamily(_ request: FamilyCreationRequest) -> Single<Family> {
        return Single.create { [weak self] (single: @escaping (SingleEvent<Family>) -> Void) -> Disposable in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "FamilyRepository", code: -1))))
                return Disposables.create()
            }

            guard let dto = request.toDTO() else {
                single(.failure(RepositoryError.invalidParameter))
                return Disposables.create()
            }

            // 실제 API 호출
            self.networkService.request(
                FamilyAPI.createFamily(
                    familyName: dto.familyName,
                    creatorId: dto.creatorId,
                    creatorRole: dto.creatorRole
                )
            )
            .subscribe(onNext: { (result: Result<ApiResponseFamily, NetworkError>) in
                switch result {
                case .success(let apiResponse):
                    if let familyResponse = apiResponse.data {
                        let family = familyResponse.toDomain()
                        self.debugSuccess("Family created via API: \(family.familyName)")
                        single(.success(family))
                    } else {
                        self.debugWarning("API returned success but no data")
                        single(.failure(RepositoryError.unknown(NSError(domain: "FamilyRepository", code: -2))))
                    }

                case .failure(let error):
                    self.debugError("Failed to create family via API", error: error)
                    single(.failure(RepositoryError.networkError(error)))
                }
            })
            .disposed(by: self.disposeBag)

            return Disposables.create()
        }
    }

    func getFamilies(for userId: String) -> Single<[Family]> {
        return Single.create { [weak self] (single: @escaping (SingleEvent<[Family]>) -> Void) -> Disposable in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "FamilyRepository", code: -1))))
                return Disposables.create()
            }

            guard let userIdInt = Int(userId) else {
                self.debugWarning("Invalid userId, returning empty families")
                single(.success([]))
                return Disposables.create()
            }

            // 실제 API 호출
            self.networkService.request(FamilyAPI.getFamiliesByUser(userId: userIdInt))
                .subscribe(onNext: { (result: Result<[FamilyResponse], NetworkError>) in
                    switch result {
                    case .success(let familyResponses):
                        let families = familyResponses.map { $0.toDomain() }
                        self.debugSuccess("Fetched \(families.count) families from API")
                        single(.success(families))

                    case .failure(let error):
                        self.debugError("Failed to fetch families from API", error: error)
                        // API 실패 시 빈 배열 반환
                        single(.success([]))
                    }
                })
                .disposed(by: self.disposeBag)

            return Disposables.create()
        }
    }

    func joinFamily(_ request: FamilyJoinRequest) -> Single<Family> {
        return Single.create { [weak self] (single: @escaping (SingleEvent<Family>) -> Void) -> Disposable in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "FamilyRepository", code: -1))))
                return Disposables.create()
            }

            guard let dto = request.toDTO() else {
                single(.failure(RepositoryError.invalidParameter))
                return Disposables.create()
            }

            // 실제 API 호출
            self.networkService.request(
                FamilyAPI.joinFamily(
                    userId: dto.userId,
                    inviteCode: dto.inviteCode,
                    role: dto.role
                )
            )
            .subscribe(onNext: { (result: Result<ApiResponseFamily, NetworkError>) in
                switch result {
                case .success(let apiResponse):
                    if let familyResponse = apiResponse.data {
                        let family = familyResponse.toDomain()
                        self.debugSuccess("Joined family via API: \(family.familyName)")
                        single(.success(family))
                    } else {
                        self.debugWarning("API returned success but no data")
                        single(.failure(RepositoryError.unknown(NSError(domain: "FamilyRepository", code: -2))))
                    }

                case .failure(let error):
                    self.debugError("Failed to join family via API", error: error)
                    single(.failure(RepositoryError.networkError(error)))
                }
            })
            .disposed(by: self.disposeBag)

            return Disposables.create()
        }
    }

    // MARK: - Family Member

    func getFamilyMembers(familyId: String) -> Single<[FamilyMember]> {
        return Single.create { [weak self] (single: @escaping (SingleEvent<[FamilyMember]>) -> Void) -> Disposable in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "FamilyRepository", code: -1))))
                return Disposables.create()
            }

            guard let familyIdInt = Int(familyId) else {
                self.debugWarning("Invalid familyId, returning empty members")
                single(.success([]))
                return Disposables.create()
            }

            // 실제 API 호출
            self.networkService.request(FamilyMemberAPI.getFamilyMembers(familyId: familyIdInt))
                .subscribe(onNext: { (result: Result<[FamilyMemberResponse], NetworkError>) in
                    switch result {
                    case .success(let memberResponses):
                        let members = memberResponses.map { $0.toDomain() }
                        self.debugSuccess("Fetched \(members.count) family members from API")
                        single(.success(members))

                    case .failure(let error):
                        self.debugError("Failed to fetch family members from API", error: error)
                        // API 실패 시 빈 배열 반환
                        single(.success([]))
                    }
                })
                .disposed(by: self.disposeBag)

            return Disposables.create()
        }
    }

    func removeFamilyMember(familyMemberId: String) -> Completable {
        return Completable.create { [weak self] completable in
            guard let self = self else {
                completable(.error(RepositoryError.unknown(NSError(domain: "FamilyRepository", code: -1))))
                return Disposables.create()
            }

            guard let familyMemberIdInt = Int(familyMemberId) else {
                completable(.error(RepositoryError.invalidParameter))
                return Disposables.create()
            }

            // 실제 API 호출
            self.networkService.request(FamilyMemberAPI.removeFamilyMember(familyMemberId: familyMemberIdInt))
                .subscribe(onNext: { (result: Result<ApiResponse<EmptyResponse>, NetworkError>) in
                    switch result {
                    case .success:
                        self.debugSuccess("Family member removed via API")
                        completable(.completed)

                    case .failure(let error):
                        self.debugError("Failed to remove family member via API", error: error)
                        completable(.error(RepositoryError.networkError(error)))
                    }
                })
                .disposed(by: self.disposeBag)

            return Disposables.create()
        }
    }
}
