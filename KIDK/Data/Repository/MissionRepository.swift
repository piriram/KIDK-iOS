import Foundation
import RxSwift
import RealmSwift

final class MissionRepository: BaseRepository, MissionRepositoryProtocol {

    private let currentUserId: String

    init(
        currentUserId: String,
        networkService: NetworkService = .shared,
        tokenManager: TokenManager = .shared
    ) {
        self.currentUserId = currentUserId
        super.init(networkService: networkService, tokenManager: tokenManager)
    }
    
    func createMission(_ request: MissionCreationRequest) -> Single<Mission> {
        debugLog("Creating mission via API: \(request.title)")

        // creatorId와 ownerId는 currentUserId를 Int로 변환
        guard let creatorIdInt = Int(currentUserId) else {
            return .error(RepositoryError.invalidParameter)
        }

        // ownerId는 participantIds의 첫 번째 값, 없으면 creatorId
        let ownerIdInt = request.participantIds.compactMap { Int($0) }.first ?? creatorIdInt

        // targetDate를 "yyyy-MM-dd" 형식으로 변환
        let targetDateString: String?
        if let targetDate = request.targetDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            targetDateString = dateFormatter.string(from: targetDate)
        } else {
            targetDateString = nil
        }

        // API 호출 - Mission 생성은 공통 응답 포맷을 사용하지 않고 직접 MissionResponse 반환
        return createMissionRaw(
            creatorId: creatorIdInt,
            ownerId: ownerIdInt,
            missionType: request.missionType.rawValue.uppercased(),
            title: request.title,
            description: request.description,
            targetAmount: request.targetAmount,
            rewardAmount: request.rewardAmount,
            targetDate: targetDateString
        )
        .do(onSuccess: { [weak self] missionResponse in
            self?.debugSuccess("Mission created via API: \(missionResponse.id)")
        }, onError: { [weak self] error in
            self?.debugError("Failed to create mission via API", error: error)
        })
        .map { $0.toDomain() }
    }
    
    func fetchMission(by id: String) -> Single<Mission?> {
        Single.create { [weak self] single in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "MissionRepository", code: -1))))
                return Disposables.create()
            }
            
            do {
                let realm = try Realm()
                let missionEntity = realm.object(ofType: MissionEntity.self, forPrimaryKey: id)
                let mission = missionEntity?.toDomain()
                
                self.debugLog("Fetched mission: \(id), found: \(mission != nil)")
                single(.success(mission))
            } catch {
                self.debugError("Failed to fetch mission", error: error)
                single(.failure(RepositoryError.unknown(error)))
            }
            
            return Disposables.create()
        }
    }
    
    func fetchMissions(for userId: String) -> Single<[Mission]> {
        Single.create { [weak self] (single: @escaping (SingleEvent<[Mission]>) -> Void) -> Disposable in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "MissionRepository", code: -1))))
                return Disposables.create()
            }

            guard let userIdInt = Int(userId) else {
                // userId가 숫자가 아니면 Realm에서 가져옴
                return self.fetchMissionsFromRealm(for: userId, single: single)
            }

            // 실제 API 호출 (owner 기준) - 공통 응답 포맷 사용
            self.fetchMissionsRaw(ownerId: userIdInt)
                .subscribe(onSuccess: { missionResponses in
                    let missions = missionResponses.map { $0.toDomain() }
                    self.debugSuccess("Fetched \(missions.count) missions from API")
                    single(.success(missions))
                }, onFailure: { error in
                    self.debugError("Failed to fetch missions from API", error: error)
                    // API 실패 시 Realm에서 가져옴
                    _ = self.fetchMissionsFromRealm(for: userId, single: single)
                })
                .disposed(by: self.disposeBag)

            return Disposables.create()
        }
    }

    private func fetchMissionsFromRealm(for userId: String, single: @escaping (SingleEvent<[Mission]>) -> Void) -> Disposable {
        do {
            let realm = try Realm()
            let missions = realm.objects(MissionEntity.self)
                .filter("ownerId == %@ OR creatorId == %@", userId, userId)
                .sorted(byKeyPath: "createdAt", ascending: false)
                .map { $0.toDomain() }

            self.debugLog("Fetched \(missions.count) missions from Realm")
            single(.success(Array(missions)))
        } catch {
            self.debugError("Failed to fetch missions from Realm", error: error)
            single(.failure(RepositoryError.unknown(error)))
        }

        return Disposables.create()
    }
    
    func fetchMissionsByStatus(_ status: MissionStatus, for userId: String) -> Single<[Mission]> {
        Single.create { [weak self] single in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "MissionRepository", code: -1))))
                return Disposables.create()
            }
            
            do {
                let realm = try Realm()
                let missions = realm.objects(MissionEntity.self)
                    .filter("(ownerId == %@ OR creatorId == %@) AND status == %@", userId, userId, status.rawValue)
                    .sorted(byKeyPath: "createdAt", ascending: false)
                    .map { $0.toDomain() }
                
                self.debugLog("Fetched \(missions.count) missions with status: \(status.rawValue)")
                single(.success(Array(missions)))
            } catch {
                self.debugError("Failed to fetch missions by status", error: error)
                single(.failure(RepositoryError.unknown(error)))
            }
            
            return Disposables.create()
        }
    }
    
    func updateMissionStatus(_ missionId: String, status: MissionStatus) -> Single<Mission> {
        Single.create { [weak self] single in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "MissionRepository", code: -1))))
                return Disposables.create()
            }
            
            do {
                let realm = try Realm()
                guard let missionEntity = realm.object(ofType: MissionEntity.self, forPrimaryKey: missionId) else {
                    self.debugError("Mission not found: \(missionId)")
                    single(.failure(RepositoryError.notFound))
                    return Disposables.create()
                }
                
                try realm.write {
                    missionEntity.status = status.rawValue
                    if status == .completed {
                        missionEntity.completedAt = Date()
                    }
                }
                
                self.debugSuccess("Mission status updated: \(missionId) -> \(status.rawValue)")
                single(.success(missionEntity.toDomain()))
            } catch {
                self.debugError("Failed to update mission status", error: error)
                single(.failure(RepositoryError.unknown(error)))
            }
            
            return Disposables.create()
        }
    }
    
    func deleteMission(_ missionId: String) -> Completable {
        Completable.create { [weak self] completable in
            guard let self = self else {
                completable(.error(RepositoryError.unknown(NSError(domain: "MissionRepository", code: -1))))
                return Disposables.create()
            }
            
            do {
                let realm = try Realm()
                guard let missionEntity = realm.object(ofType: MissionEntity.self, forPrimaryKey: missionId) else {
                    self.debugError("Mission not found for deletion: \(missionId)")
                    completable(.error(RepositoryError.notFound))
                    return Disposables.create()
                }
                
                try realm.write {
                    realm.delete(missionEntity.participants)
                    realm.delete(missionEntity)
                }
                
                self.debugSuccess("Mission deleted: \(missionId)")
                completable(.completed)
            } catch {
                self.debugError("Failed to delete mission", error: error)
                completable(.error(RepositoryError.unknown(error)))
            }
            
            return Disposables.create()
        }
    }

    // MARK: - Raw Response Helpers

    /// Mission 생성 API는 공통 응답 포맷을 사용하지 않고 MissionResponse 객체를 직접 반환
    private func createMissionRaw(
        creatorId: Int,
        ownerId: Int,
        missionType: String,
        title: String,
        description: String?,
        targetAmount: Int?,
        rewardAmount: Int,
        targetDate: String?
    ) -> Single<MissionResponse> {
        return Single.create { [weak self] single in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "MissionRepository", code: -1))))
                return Disposables.create()
            }

            let baseURL = Environment.current.baseURL
            guard let url = URL(string: "\(baseURL)/missions") else {
                single(.failure(RepositoryError.unknown(NSError(domain: "MissionRepository", code: -2))))
                return Disposables.create()
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            if let accessToken = self.tokenManager.accessToken {
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }

            // Request Body 생성
            var params: [String: Any] = [
                "creatorId": creatorId,
                "ownerId": ownerId,
                "missionType": missionType,
                "title": title,
                "rewardAmount": Double(rewardAmount),  // Double로 변환
                "status": "ACTIVE"
            ]

            if let desc = description {
                params["description"] = desc
            }
            if let target = targetAmount {
                params["targetAmount"] = Double(target)  // Double로 변환
            }
            if let date = targetDate {
                params["targetDate"] = date
            }

            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: params)
            } catch {
                single(.failure(RepositoryError.unknown(error)))
                return Disposables.create()
            }

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    self.debugError("Mission creation request error", error: error)
                    single(.failure(RepositoryError.unknown(error)))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    single(.failure(RepositoryError.unknown(NSError(domain: "MissionRepository", code: -3))))
                    return
                }

                guard let data = data else {
                    single(.failure(RepositoryError.unknown(NSError(domain: "MissionRepository", code: -4))))
                    return
                }

                // 500 에러 등 서버 에러 처리
                if httpResponse.statusCode >= 400 {
                    self.debugError("Mission creation failed with status \(httpResponse.statusCode)", error: nil)
                    if let responseString = String(data: data, encoding: .utf8) {
                        self.debugError("Response body: \(responseString)", error: nil)
                    }
                    single(.failure(RepositoryError.unknown(NSError(
                        domain: "MissionRepository",
                        code: httpResponse.statusCode,
                        userInfo: [NSLocalizedDescriptionKey: "Server returned error \(httpResponse.statusCode)"]
                    ))))
                    return
                }

                // MissionResponse 직접 파싱
                do {
                    let missionResponse = try JSONDecoder().decode(MissionResponse.self, from: data)
                    single(.success(missionResponse))
                } catch {
                    self.debugError("Failed to decode MissionResponse", error: error)
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

    /// Mission API가 배열을 직접 반환하는지, 공통 응답 포맷을 사용하는지에 따라 분기 처리
    /// 먼저 공통 응답 포맷을 시도하고, 실패하면 직접 배열 파싱 시도
    private func fetchMissionsRaw(ownerId: Int) -> Single<[MissionResponse]> {
        return Single.create { [weak self] single in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "MissionRepository", code: -1))))
                return Disposables.create()
            }

            let baseURL = Environment.current.baseURL
            guard let url = URL(string: "\(baseURL)/missions/owner/\(ownerId)") else {
                single(.failure(RepositoryError.unknown(NSError(domain: "MissionRepository", code: -2))))
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
                    single(.failure(RepositoryError.unknown(NSError(domain: "MissionRepository", code: -3))))
                    return
                }

                // 1차 시도: 공통 응답 포맷 파싱
                do {
                    let apiResponse = try JSONDecoder().decode(ApiResponse<[MissionResponse]>.self, from: data)
                    if apiResponse.success, let missionData = apiResponse.data {
                        single(.success(missionData))
                        return
                    } else {
                        self.debugError("API returned success=false", error: nil)
                        single(.failure(RepositoryError.unknown(NSError(domain: "MissionRepository", code: -4))))
                        return
                    }
                } catch {
                    self.debugWarning("Failed to decode as ApiResponse, trying direct array parsing")
                }

                // 2차 시도: 직접 배열 파싱 (Account API처럼)
                do {
                    let missionArray = try JSONDecoder().decode([MissionResponse].self, from: data)
                    single(.success(missionArray))
                } catch {
                    self.debugError("Failed to decode missions array", error: error)
                    single(.failure(RepositoryError.decodingError(error)))
                }
            }

            task.resume()
            return Disposables.create { task.cancel() }
        }
    }

    // MARK: - Mission Progress Methods

    func getMissionProgress(missionId: String) -> Single<MissionProgress?> {
        return Single.create { [weak self] single in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "MissionRepository", code: -1))))
                return Disposables.create()
            }

            guard let missionIdInt = Int(missionId) else {
                self.debugWarning("Invalid mission ID format, returning nil")
                single(.success(nil))
                return Disposables.create()
            }

            // Mission Progress API는 배열을 직접 반환 (ApiResponse 래퍼 없음)
            self.getMissionProgressRaw(missionId: missionIdInt)
                .subscribe(onSuccess: { progressResponses in
                    // Return first progress (there should be only one per mission)
                    if let firstProgress = progressResponses.first {
                        let progress = firstProgress.toDomain()
                        self.debugSuccess("Fetched mission progress via API: \(progress.id)")
                        single(.success(progress))
                    } else {
                        self.debugWarning("No progress found for mission")
                        single(.success(nil))
                    }
                }, onFailure: { error in
                    self.debugError("Failed to fetch mission progress via API", error: error)
                    // Fallback to nil (no Mock data for progress)
                    single(.success(nil))
                })
                .disposed(by: self.disposeBag)

            return Disposables.create()
        }
    }

    func getMissionProgressByUser(userId: String) -> Single<[MissionProgress]> {
        return Single.create { [weak self] single in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "MissionRepository", code: -1))))
                return Disposables.create()
            }

            guard let userIdInt = Int(userId) else {
                self.debugWarning("Invalid user ID format, returning empty array")
                single(.success([]))
                return Disposables.create()
            }

            // Mission Progress API는 배열을 직접 반환 (ApiResponse 래퍼 없음)
            self.getMissionProgressByUserRaw(userId: userIdInt)
                .subscribe(onSuccess: { progressResponses in
                    let progressList = progressResponses.map { $0.toDomain() }
                    self.debugSuccess("Fetched \(progressList.count) progress items via API")
                    single(.success(progressList))
                }, onFailure: { error in
                    self.debugError("Failed to fetch mission progress via API", error: error)
                    // Fallback to empty array
                    single(.success([]))
                })
                .disposed(by: self.disposeBag)

            return Disposables.create()
        }
    }

    func updateMissionProgress(
        missionId: String,
        userId: String,
        progressAmount: Double?,
        progressPercentage: Double?
    ) -> Single<MissionProgress> {
        return Single.create { [weak self] single in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "MissionRepository", code: -1))))
                return Disposables.create()
            }

            guard let missionIdInt = Int(missionId),
                  let userIdInt = Int(userId) else {
                self.debugError("Invalid ID format")
                single(.failure(RepositoryError.invalidParameter))
                return Disposables.create()
            }

            // Mission Progress API는 객체를 직접 반환 (ApiResponse 래퍼 없음)
            self.updateMissionProgressRaw(
                missionId: missionIdInt,
                userId: userIdInt,
                progressAmount: progressAmount,
                progressPercentage: progressPercentage
            )
            .subscribe(onSuccess: { progressResponse in
                let progress = progressResponse.toDomain()

                self.debugSuccess("Updated mission progress via API: \(progress.id)")

                // Post notification for UI updates
                NotificationCenter.default.post(
                    name: .missionProgressUpdated,
                    object: missionId
                )

                single(.success(progress))
            }, onFailure: { error in
                self.debugError("Failed to update mission progress via API", error: error)
                single(.failure(RepositoryError.networkError(NetworkError.unknown(error))))
            })
            .disposed(by: self.disposeBag)

            return Disposables.create()
        }
    }

    // MARK: - Mission Progress Raw Helpers

    private func getMissionProgressRaw(missionId: Int) -> Single<[MissionProgressResponse]> {
        return Single.create { [weak self] single in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "MissionRepository", code: -1))))
                return Disposables.create()
            }

            let baseURL = Environment.current.baseURL
            guard let url = URL(string: "\(baseURL)/mission-progress/\(missionId)") else {
                single(.failure(RepositoryError.unknown(NSError(domain: "MissionRepository", code: -2))))
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
                    self.debugError("Mission progress fetch error", error: error)
                    single(.failure(RepositoryError.unknown(error)))
                    return
                }

                guard let data = data else {
                    single(.failure(RepositoryError.unknown(NSError(domain: "MissionRepository", code: -3))))
                    return
                }

                do {
                    let progressList = try JSONDecoder().decode([MissionProgressResponse].self, from: data)
                    single(.success(progressList))
                } catch {
                    self.debugError("Failed to decode mission progress array", error: error)
                    single(.failure(RepositoryError.decodingError(error)))
                }
            }

            task.resume()
            return Disposables.create { task.cancel() }
        }
    }

    private func getMissionProgressByUserRaw(userId: Int) -> Single<[MissionProgressResponse]> {
        return Single.create { [weak self] single in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "MissionRepository", code: -1))))
                return Disposables.create()
            }

            let baseURL = Environment.current.baseURL
            guard let url = URL(string: "\(baseURL)/mission-progress/user/\(userId)") else {
                single(.failure(RepositoryError.unknown(NSError(domain: "MissionRepository", code: -2))))
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
                    self.debugError("User mission progress fetch error", error: error)
                    single(.failure(RepositoryError.unknown(error)))
                    return
                }

                guard let data = data else {
                    single(.failure(RepositoryError.unknown(NSError(domain: "MissionRepository", code: -3))))
                    return
                }

                do {
                    let progressList = try JSONDecoder().decode([MissionProgressResponse].self, from: data)
                    single(.success(progressList))
                } catch {
                    self.debugError("Failed to decode user mission progress array", error: error)
                    single(.failure(RepositoryError.decodingError(error)))
                }
            }

            task.resume()
            return Disposables.create { task.cancel() }
        }
    }

    private func updateMissionProgressRaw(
        missionId: Int,
        userId: Int,
        progressAmount: Double?,
        progressPercentage: Double?
    ) -> Single<MissionProgressResponse> {
        return Single.create { [weak self] single in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "MissionRepository", code: -1))))
                return Disposables.create()
            }

            let baseURL = Environment.current.baseURL
            guard let url = URL(string: "\(baseURL)/mission-progress/\(missionId)") else {
                single(.failure(RepositoryError.unknown(NSError(domain: "MissionRepository", code: -2))))
                return Disposables.create()
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            if let accessToken = self.tokenManager.accessToken {
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }

            var params: [String: Any] = ["userId": userId]
            if let amount = progressAmount {
                params["progressAmount"] = amount
            }
            if let percentage = progressPercentage {
                params["progressPercentage"] = percentage
            }

            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: params)
            } catch {
                single(.failure(RepositoryError.unknown(error)))
                return Disposables.create()
            }

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    self.debugError("Mission progress update error", error: error)
                    single(.failure(RepositoryError.unknown(error)))
                    return
                }

                guard let data = data else {
                    single(.failure(RepositoryError.unknown(NSError(domain: "MissionRepository", code: -3))))
                    return
                }

                do {
                    let progress = try JSONDecoder().decode(MissionProgressResponse.self, from: data)
                    single(.success(progress))
                } catch {
                    self.debugError("Failed to decode mission progress response", error: error)
                    single(.failure(RepositoryError.decodingError(error)))
                }
            }

            task.resume()
            return Disposables.create { task.cancel() }
        }
    }
}
}
