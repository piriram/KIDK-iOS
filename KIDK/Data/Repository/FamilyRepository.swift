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

            _ = userId // 시그니처 호환용

            // 가이드 기준: /families/me
            self.getMyFamilyRaw()
                .subscribe(onSuccess: { familyResponse in
                    let family = familyResponse.toDomain()
                    self.debugSuccess("Fetched my family from API")
                    single(.success([family]))
                }, onFailure: { error in
                    self.debugError("Failed to fetch my family from API", error: error)
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

            // Family 가입 후 /families/me 재조회
            self.joinFamilyRaw(userId: dto.userId, inviteCode: dto.inviteCode)
                .flatMap { _ -> Single<FamilyResponse> in
                    return self.getMyFamilyRaw()
                }
                .subscribe(onSuccess: { familyResponse in
                    let family = familyResponse.toDomain()
                    self.debugSuccess("Joined family via API: \(family.familyName)")
                    single(.success(family))
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

    func removeFamilyMember(familyMemberId _: String) -> Completable {
        debugWarning("removeFamilyMember API is deferred in MVP. Blocked request.")
        return .error(RepositoryError.deferredInMVP(feature: "가족 구성원 삭제"))
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

    /// 내 가족 조회 API (/families/me)
    private func getMyFamilyRaw() -> Single<FamilyResponse> {
        return Single.create { [weak self] single in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "FamilyRepository", code: -1))))
                return Disposables.create()
            }

            let baseURL = Environment.current.baseURL
            guard let url = URL(string: "\(baseURL)/families/me") else {
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
                    self.debugError("My family request error", error: error)
                    single(.failure(RepositoryError.unknown(error)))
                    return
                }

                guard let data = data else {
                    single(.failure(RepositoryError.unknown(NSError(domain: "FamilyRepository", code: -3))))
                    return
                }

                do {
                    let apiResponse = try JSONDecoder().decode(ApiResponse<FamilyResponse>.self, from: data)
                    if apiResponse.success, let family = apiResponse.data {
                        single(.success(family))
                        return
                    }
                    if let errorInfo = apiResponse.error {
                        self.debugError("My family api error: \(errorInfo.code) - \(errorInfo.message)", error: nil)
                    }
                } catch {
                    self.debugWarning("Failed to decode my family as ApiResponse, trying direct object")
                }

                do {
                    let family = try JSONDecoder().decode(FamilyResponse.self, from: data)
                    single(.success(family))
                } catch {
                    self.debugError("Failed to decode my family response", error: error)
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
