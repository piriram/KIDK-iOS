import Foundation
import RxSwift
import RealmSwift

final class MissionRepository: BaseRepository, MissionRepositoryProtocol {

    private let currentUserId: String
    private var mockMissions: [Mission] = []
    private var nextMockId = 1

    init(
        currentUserId: String,
        networkService: NetworkService = .shared,
        tokenManager: TokenManager = .shared
    ) {
        self.currentUserId = currentUserId
        super.init(networkService: networkService, tokenManager: tokenManager)

        // 목업 데이터가 활성화되어 있으면 초기 샘플 미션 생성
        if Environment.current.useMockMissionData {
            createInitialMockMissions()
        }
    }

    // MARK: - Mock Data Helpers

    private func createInitialMockMissions() {
        let calendar = Calendar.current
        let today = Date()

        mockMissions = [
            Mission(
                id: String(nextMockId),
                creatorId: currentUserId,
                ownerId: currentUserId,
                missionType: .savings,
                title: "닌텐도 스위치 모으기",
                description: "친구들과 함께 놀이공원 가기 위해 저축하기",
                targetAmount: 300000,
                currentAmount: 125000,
                rewardAmount: 10000,
                targetDate: calendar.date(byAdding: .month, value: 1, to: today),
                status: .inProgress,
                createdAt: today,
                completedAt: nil,
                participants: []
            ),
            Mission(
                id: String(nextMockId + 1),
                creatorId: currentUserId,
                ownerId: currentUserId,
                missionType: .savings,
                title: "새 자전거 사기",
                description: "학교 갈 때 탈 새 자전거 사기",
                targetAmount: 150000,
                currentAmount: 80000,
                rewardAmount: 5000,
                targetDate: calendar.date(byAdding: .month, value: 1, to: today),
                status: .inProgress,
                createdAt: calendar.date(byAdding: .day, value: -5, to: today) ?? today,
                completedAt: nil,
                participants: []
            ),
            Mission(
                id: String(nextMockId + 2),
                creatorId: currentUserId,
                ownerId: currentUserId,
                missionType: .video,
                title: "공룡 다큐멘터리 보기",
                description: "공룡에 대해 배우기",
                targetAmount: nil,
                currentAmount: 0,
                rewardAmount: 2000,
                targetDate: calendar.date(byAdding: .day, value: 7, to: today),
                status: .inProgress,
                createdAt: calendar.date(byAdding: .day, value: -2, to: today) ?? today,
                completedAt: nil,
                participants: []
            ),
            Mission(
                id: String(nextMockId + 3),
                creatorId: currentUserId,
                ownerId: currentUserId,
                missionType: .study,
                title: "수학 공부 1시간",
                description: "매일 수학 문제 풀기",
                targetAmount: nil,
                currentAmount: 0,
                rewardAmount: 1500,
                targetDate: calendar.date(byAdding: .day, value: 3, to: today),
                status: .inProgress,
                createdAt: calendar.date(byAdding: .day, value: -1, to: today) ?? today,
                completedAt: nil,
                participants: []
            ),
            Mission(
                id: String(nextMockId + 4),
                creatorId: currentUserId,
                ownerId: currentUserId,
                missionType: .savings,
                title: "용돈 모으기",
                description: "첫 저축 목표 달성하기",
                targetAmount: 50000,
                currentAmount: 50000,
                rewardAmount: 3000,
                targetDate: calendar.date(byAdding: .day, value: -7, to: today),
                status: .completed,
                createdAt: calendar.date(byAdding: .month, value: -1, to: today) ?? today,
                completedAt: calendar.date(byAdding: .day, value: -7, to: today),
                participants: []
            )
        ]
        nextMockId += 5
        debugLog("Created \(mockMissions.count) initial mock missions")
    }
    
    func createMission(_ request: MissionCreationRequest) -> Single<Mission> {
        debugLog("Creating mission: \(request.title)")

        // 목업 데이터 사용 시
        if Environment.current.useMockMissionData {
            return createMockMission(request)
        }

        // 실제 API 호출
        debugLog("Mission request details - type: \(request.missionType.rawValue), targetAmount: \(request.targetAmount ?? 0), rewardAmount: \(request.rewardAmount), participantIds: \(request.participantIds)")
        debugLog("Current userId: \(currentUserId)")

        guard let creatorIdInt = Int(currentUserId) else {
            debugError("Failed to convert currentUserId to Int: \(currentUserId)")
            return .error(RepositoryError.invalidParameter)
        }
        debugLog("CreatorId converted: \(creatorIdInt)")

        let ownerIdInt = request.participantIds.compactMap { Int($0) }.first ?? creatorIdInt
        debugLog("OwnerId determined: \(ownerIdInt)")

        let targetDateString: String?
        if let targetDate = request.targetDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            targetDateString = dateFormatter.string(from: targetDate)
            debugLog("Target date converted: \(targetDateString ?? "nil")")
        } else {
            targetDateString = nil
            debugLog("No target date provided")
        }

        debugLog("Calling createMissionRaw...")

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

    private func createMockMission(_ request: MissionCreationRequest) -> Single<Mission> {
        return Single.create { [weak self] single in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "MissionRepository", code: -1))))
                return Disposables.create()
            }

            // 목업 미션 생성
            let newMission = Mission(
                id: String(self.nextMockId),
                creatorId: self.currentUserId,
                ownerId: self.currentUserId,
                missionType: request.missionType,
                title: request.title,
                description: request.description,
                targetAmount: request.targetAmount,
                currentAmount: request.currentAmount ?? 0,
                rewardAmount: request.rewardAmount,
                targetDate: request.targetDate,
                status: .inProgress,
                createdAt: Date(),
                completedAt: nil,
                participants: []
            )

            self.mockMissions.append(newMission)
            self.nextMockId += 1

            self.debugSuccess("Mock mission created: \(newMission.title) (id: \(newMission.id))")
            single(.success(newMission))

            return Disposables.create()
        }
    }
    
    func fetchMission(by id: String) -> Single<Mission?> {
        Single.create { [weak self] single in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "MissionRepository", code: -1))))
                return Disposables.create()
            }

            // 목업 데이터 사용 시
            if Environment.current.useMockMissionData {
                let mission = self.mockMissions.first { $0.id == id }
                self.debugLog("Fetched mock mission: \(id), found: \(mission != nil)")
                single(.success(mission))
                return Disposables.create()
            }

            // Realm 사용
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

            // 목업 데이터 사용 시
            if Environment.current.useMockMissionData {
                self.debugSuccess("Fetched \(self.mockMissions.count) mock missions")
                single(.success(self.mockMissions))
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

            // 목업 데이터 사용 시
            if Environment.current.useMockMissionData {
                let filteredMissions = self.mockMissions.filter { $0.status == status }
                self.debugLog("Fetched \(filteredMissions.count) mock missions with status: \(status.rawValue)")
                single(.success(filteredMissions))
                return Disposables.create()
            }

            // Realm 사용
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

            // 목업 데이터 사용 시
            if Environment.current.useMockMissionData {
                guard let index = self.mockMissions.firstIndex(where: { $0.id == missionId }) else {
                    self.debugError("Mock mission not found: \(missionId)")
                    single(.failure(RepositoryError.notFound))
                    return Disposables.create()
                }

                let oldMission = self.mockMissions[index]
                let updatedMission = Mission(
                    id: oldMission.id,
                    creatorId: oldMission.creatorId,
                    ownerId: oldMission.ownerId,
                    missionType: oldMission.missionType,
                    title: oldMission.title,
                    description: oldMission.description,
                    targetAmount: oldMission.targetAmount,
                    currentAmount: oldMission.currentAmount,
                    rewardAmount: oldMission.rewardAmount,
                    targetDate: oldMission.targetDate,
                    status: status,
                    createdAt: oldMission.createdAt,
                    completedAt: status == .completed ? Date() : oldMission.completedAt,
                    participants: oldMission.participants
                )
                self.mockMissions[index] = updatedMission

                self.debugSuccess("Mock mission status updated: \(missionId) -> \(status.rawValue)")
                single(.success(updatedMission))
                return Disposables.create()
            }

            // Realm 사용
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

            // 목업 데이터 사용 시
            if Environment.current.useMockMissionData {
                if let index = self.mockMissions.firstIndex(where: { $0.id == missionId }) {
                    self.mockMissions.remove(at: index)
                    self.debugSuccess("Mock mission deleted: \(missionId)")
                    completable(.completed)
                } else {
                    self.debugError("Mock mission not found for deletion: \(missionId)")
                    completable(.error(RepositoryError.notFound))
                }
                return Disposables.create()
            }

            // Realm 사용
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

            #if DEBUG
            let hasAuthHeader = request.value(forHTTPHeaderField: "Authorization") != nil
            self.debugLog("Mission create request url: \(url.absoluteString)")
            self.debugLog("Mission create request has auth: \(hasAuthHeader)")
            self.debugLog("Mission create request params: \(params)")
            #endif

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

                #if DEBUG
                if let responseString = String(data: data, encoding: .utf8) {
                    self.debugLog("Mission create response status: \(httpResponse.statusCode)")
                    self.debugLog("Mission create response body: \(responseString)")
                } else {
                    self.debugLog("Mission create response status: \(httpResponse.statusCode)")
                    self.debugLog("Mission create response body: <non-utf8>")
                }
                #endif

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
