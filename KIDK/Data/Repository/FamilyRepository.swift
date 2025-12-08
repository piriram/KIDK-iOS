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

            // Family 생성 API는 공통 응답 포맷을 사용하지 않고 직접 FamilyResponse 반환
            self.createFamilyRaw(userId: dto.userId, familyName: dto.familyName)
                .subscribe(onSuccess: { familyResponse in
                    let family = familyResponse.toDomain()
                    self.debugSuccess("Family created via API: \(family.familyName)")
                    single(.success(family))
                }, onFailure: { error in
                    self.debugError("Failed to create family via API", error: error)
                    single(.failure(RepositoryError.networkError(error as? NetworkError ?? NetworkError.unknown(error))))
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

            // Family 목록 조회 API는 공통 응답 포맷을 사용하지 않고 직접 배열 반환
            self.getFamiliesRaw()
                .subscribe(onSuccess: { familyResponses in
                    let families = familyResponses.map { $0.toDomain() }
                    self.debugSuccess("Fetched \(families.count) families from API")
                    single(.success(families))
                }, onFailure: { error in
                    self.debugError("Failed to fetch families from API", error: error)
                    // API 실패 시 빈 배열 반환
                    single(.success([]))
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

            // Family 가입 API는 FamilyMember 객체를 직접 반환
            // 하지만 도메인 모델은 Family를 기대하므로, 가입 후 가족 목록을 다시 조회
            self.joinFamilyRaw(userId: dto.userId, inviteCode: dto.inviteCode)
                .flatMap { _ -> Single<[FamilyResponse]> in
                    // 가입 성공 후 가족 목록 조회
                    return self.getFamiliesRaw()
                }
                .subscribe(onSuccess: { familyResponses in
                    // 가장 최근에 가입한 가족 (마지막 항목)
                    if let lastFamily = familyResponses.last {
                        let family = lastFamily.toDomain()
                        self.debugSuccess("Joined family via API: \(family.familyName)")
                        single(.success(family))
                    } else {
                        single(.failure(RepositoryError.notFound))
                    }
                }, onFailure: { error in
                    self.debugError("Failed to join family via API", error: error)
                    single(.failure(RepositoryError.networkError(error as? NetworkError ?? NetworkError.unknown(error))))
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
                .subscribe(onNext: { (result: Result<EmptyData, NetworkError>) in
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

    // MARK: - Raw Response Helpers

    /// Family 생성 API는 공통 응답 포맷을 사용하지 않고 FamilyResponse 객체를 직접 반환
    private func createFamilyRaw(userId: Int, familyName: String) -> Single<FamilyResponse> {
        return Single.create { [weak self] single in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "FamilyRepository", code: -1))))
                return Disposables.create()
            }

            let baseURL = Environment.current.baseURL
            guard let url = URL(string: "\(baseURL)/families") else {
                single(.failure(RepositoryError.unknown(NSError(domain: "FamilyRepository", code: -2))))
                return Disposables.create()
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            if let accessToken = self.tokenManager.accessToken {
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }

            let params: [String: Any] = [
                "userId": userId,
                "familyName": familyName
            ]

            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: params)
            } catch {
                single(.failure(RepositoryError.unknown(error)))
                return Disposables.create()
            }

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    self.debugError("Family creation request error", error: error)
                    single(.failure(RepositoryError.unknown(error)))
                    return
                }

                guard let data = data else {
                    single(.failure(RepositoryError.unknown(NSError(domain: "FamilyRepository", code: -3))))
                    return
                }

                do {
                    let familyResponse = try JSONDecoder().decode(FamilyResponse.self, from: data)
                    single(.success(familyResponse))
                } catch {
                    self.debugError("Failed to decode FamilyResponse", error: error)
                    if let responseString = String(data: data, encoding: .utf8) {
                        self.debugError("Response body: \(responseString)", error: nil)
                    }
                    single(.failure(RepositoryError.decodingError(error)))
                }
            }

            task.resume()
            return Disposables.create { task.cancel() }
        }
    }

    /// Family 목록 조회 API는 공통 응답 포맷을 사용하지 않고 배열을 직접 반환
    private func getFamiliesRaw() -> Single<[FamilyResponse]> {
        return Single.create { [weak self] single in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "FamilyRepository", code: -1))))
                return Disposables.create()
            }

            let baseURL = Environment.current.baseURL
            guard let url = URL(string: "\(baseURL)/families") else {
                single(.failure(RepositoryError.unknown(NSError(domain: "FamilyRepository", code: -2))))
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
                    self.debugError("Family list request error", error: error)
                    single(.failure(RepositoryError.unknown(error)))
                    return
                }

                guard let data = data else {
                    single(.failure(RepositoryError.unknown(NSError(domain: "FamilyRepository", code: -3))))
                    return
                }

                do {
                    let families = try JSONDecoder().decode([FamilyResponse].self, from: data)
                    single(.success(families))
                } catch {
                    self.debugError("Failed to decode families array", error: error)
                    single(.failure(RepositoryError.decodingError(error)))
                }
            }

            task.resume()
            return Disposables.create { task.cancel() }
        }
    }

    /// Family 가입 API는 FamilyMember 객체를 직접 반환
    private func joinFamilyRaw(userId: Int, inviteCode: String) -> Single<Void> {
        return Single.create { [weak self] single in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "FamilyRepository", code: -1))))
                return Disposables.create()
            }

            let baseURL = Environment.current.baseURL
            guard let url = URL(string: "\(baseURL)/families/join") else {
                single(.failure(RepositoryError.unknown(NSError(domain: "FamilyRepository", code: -2))))
                return Disposables.create()
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            if let accessToken = self.tokenManager.accessToken {
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }

            let params: [String: Any] = [
                "userId": userId,
                "inviteCode": inviteCode
            ]

            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: params)
            } catch {
                single(.failure(RepositoryError.unknown(error)))
                return Disposables.create()
            }

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    self.debugError("Family join request error", error: error)
                    single(.failure(RepositoryError.unknown(error)))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    self.debugError("No HTTP response", error: nil)
                    single(.failure(RepositoryError.unknown(NSError(domain: "FamilyRepository", code: -3))))
                    return
                }

                // 응답 로그 출력
                self.debugLog("Family join response status: \(httpResponse.statusCode)")
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    self.debugLog("Family join response body: \(responseString)")
                }

                guard httpResponse.statusCode == 200 else {
                    self.debugError("Family join failed with status \(httpResponse.statusCode)", error: nil)
                    single(.failure(RepositoryError.unknown(NSError(
                        domain: "FamilyRepository",
                        code: httpResponse.statusCode,
                        userInfo: [NSLocalizedDescriptionKey: "Server returned error \(httpResponse.statusCode)"]
                    ))))
                    return
                }

                // FamilyMember 객체가 반환되지만, 여기서는 성공 여부만 확인
                self.debugSuccess("Family join successful")
                single(.success(()))
            }

            task.resume()
            return Disposables.create { task.cancel() }
        }
    }
}
