import Foundation
import RxSwift

final class MissionVerificationRepository: BaseRepository, MissionVerificationRepositoryProtocol {

    static let shared = MissionVerificationRepository()

    private override init(
        networkService: NetworkService = .shared,
        tokenManager: TokenManager = .shared
    ) {
        super.init(networkService: networkService, tokenManager: tokenManager)
        setupMockData()
    }

    private var mockVerifications: [MissionVerification] = []
    private var nextId: Int = 100

    private func setupMockData() {
        let now = Date()
        let calendar = Calendar.current

        // 1. 사진 인증 - PENDING (방 정리 미션)
        mockVerifications.append(MissionVerification(
            id: "1",
            missionId: "mission_1",
            childId: "child_user_1",
            type: .photo,
            content: nil, // 실제로는 사진 경로가 있어야 하지만 목업에서는 nil
            memo: "방을 깨끗이 정리했어요!",
            submittedDate: calendar.date(byAdding: .hour, value: -2, to: now)!,
            reviewedBy: nil,
            reviewedDate: nil,
            status: .pending,
            rejectReason: nil
        ))

        // 2. 텍스트 인증 - PENDING (독서 미션)
        mockVerifications.append(MissionVerification(
            id: "2",
            missionId: "mission_2",
            childId: "child_user_1",
            type: .text,
            content: "오늘은 '어린왕자'를 30페이지 읽었어요. 주인공이 사막에서 비행기 조종사를 만나는 부분이 정말 재미있었어요. 내일은 장미꽃에 대한 이야기를 읽을 예정이에요.",
            memo: "정말 재미있는 책이에요!",
            submittedDate: calendar.date(byAdding: .hour, value: -5, to: now)!,
            reviewedBy: nil,
            reviewedDate: nil,
            status: .pending,
            rejectReason: nil
        ))

        // 3. 사진 인증 - PENDING (설거지 미션)
        mockVerifications.append(MissionVerification(
            id: "3",
            missionId: "mission_3",
            childId: "child_user_1",
            type: .photo,
            content: nil,
            memo: "설거지를 깨끗하게 했어요",
            submittedDate: calendar.date(byAdding: .minute, value: -30, to: now)!,
            reviewedBy: nil,
            reviewedDate: nil,
            status: .pending,
            rejectReason: nil
        ))

        // 4. 텍스트 인증 - PENDING (영어 공부 미션)
        mockVerifications.append(MissionVerification(
            id: "4",
            missionId: "mission_4",
            childId: "child_user_1",
            type: .text,
            content: "Today I learned 20 new English words. My favorite words are 'butterfly', 'rainbow', and 'adventure'. I practiced writing sentences with each word.",
            memo: nil,
            submittedDate: calendar.date(byAdding: .hour, value: -1, to: now)!,
            reviewedBy: nil,
            reviewedDate: nil,
            status: .pending,
            rejectReason: nil
        ))

        // 5. 승인된 인증 - APPROVED (운동 미션)
        mockVerifications.append(MissionVerification(
            id: "5",
            missionId: "mission_5",
            childId: "child_user_1",
            type: .photo,
            content: nil,
            memo: "줄넘기 100개 했어요!",
            submittedDate: calendar.date(byAdding: .day, value: -1, to: now)!,
            reviewedBy: "parent_user",
            reviewedDate: calendar.date(byAdding: .day, value: -1, to: now)!,
            status: .approved,
            rejectReason: nil
        ))

        // 6. 거절된 인증 - REJECTED (숙제 미션)
        mockVerifications.append(MissionVerification(
            id: "6",
            missionId: "mission_6",
            childId: "child_user_1",
            type: .text,
            content: "숙제 다 했어요",
            memo: nil,
            submittedDate: calendar.date(byAdding: .day, value: -2, to: now)!,
            reviewedBy: "parent_user",
            reviewedDate: calendar.date(byAdding: .day, value: -2, to: now)!,
            status: .rejected,
            rejectReason: "숙제 내용이 자세하지 않아요. 어떤 숙제를 했는지 구체적으로 적어주세요."
        ))

        nextId = 100
        debugLog("Mock verifications initialized with \(mockVerifications.count) items")
    }

    func submitVerification(_ request: MissionVerificationRequest) -> Single<MissionVerification> {
        return Single.create { [weak self] (single: @escaping (SingleEvent<MissionVerification>) -> Void) -> Disposable in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "MissionVerificationRepository", code: -1))))
                return Disposables.create()
            }

            // Get current user as child
            Task {
                guard let user = await UserProfileManager.shared.getCurrentUser() else {
                    self.debugWarning("No user found, using mock submission")
                    self.submitMockVerification(request: request, single: single)
                    return
                }

                // Convert IDs
                guard let missionIdInt = Int(request.missionId),
                      let childIdInt = Int(user.id) else {
                    self.debugWarning("Invalid ID format, using mock submission")
                    self.submitMockVerification(request: request, single: single)
                    return
                }

                // Convert VerificationType to String
                let verificationTypeString: String
                switch request.type {
                case .photo:
                    verificationTypeString = "PHOTO"
                case .text:
                    verificationTypeString = "TEXT"
                case .parentCheck:
                    verificationTypeString = "PARENT_CHECK"
                }

                // Mission Verification API는 객체를 직접 반환 (ApiResponse 래퍼 없음)
                self.submitVerificationRaw(
                    missionId: missionIdInt,
                    childId: childIdInt,
                    verificationType: verificationTypeString,
                    content: request.content.isEmpty ? nil : request.content
                )
                .subscribe(onSuccess: { verificationResponse in
                    let verification = verificationResponse.toDomain()

                    // Add to mockVerifications for sync
                    self.mockVerifications.append(verification)

                    self.debugSuccess("Submitted verification via API: \(verification.id)")

                    single(.success(verification))
                }, onFailure: { error in
                    self.debugError("Failed to submit via API, using mock submission", error: error)
                    self.submitMockVerification(request: request, single: single)
                })
                .disposed(by: self.disposeBag)
            }

            return Disposables.create()
        }
    }

    func getVerifications(missionId: String) -> Single<[MissionVerification]> {
        return Single.create { [weak self] (single: @escaping (SingleEvent<[MissionVerification]>) -> Void) -> Disposable in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "MissionVerificationRepository", code: -1))))
                return Disposables.create()
            }

            // Convert String ID to Int
            guard let missionIdInt = Int(missionId) else {
                self.debugWarning("Invalid mission ID format, using mock verifications")
                let verifications = self.mockVerifications.filter { $0.missionId == missionId }
                single(.success(verifications))
                return Disposables.create()
            }

            // Mission Verification API는 배열을 직접 반환 (ApiResponse 래퍼 없음)
            self.getVerificationsRaw(missionId: missionIdInt)
                .subscribe(onSuccess: { verificationResponses in
                    let verifications = verificationResponses.map { $0.toDomain() }

                    // Sync mockVerifications with API results
                    // Remove old verifications for this mission and add new ones
                    self.mockVerifications.removeAll { $0.missionId == missionId }
                    self.mockVerifications.append(contentsOf: verifications)

                    self.debugSuccess("Fetched \(verifications.count) verifications via API for mission: \(missionId)")
                    single(.success(verifications))
                }, onFailure: { error in
                    self.debugError("Failed to fetch via API, using mock verifications", error: error)
                    let verifications = self.mockVerifications.filter { $0.missionId == missionId }
                    self.debugLog("Fetched \(verifications.count) verifications from Mock")
                    single(.success(verifications))
                })
                .disposed(by: self.disposeBag)

            return Disposables.create()
        }
    }

    func getPendingVerifications() -> Single<[MissionVerification]> {
        return Single.create { [weak self] (single: @escaping (SingleEvent<[MissionVerification]>) -> Void) -> Disposable in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "MissionVerificationRepository", code: -1))))
                return Disposables.create()
            }

            // Mock 데이터로 fallback
            let pending = self.mockVerifications.filter { $0.status == .pending }
            self.debugLog("Fetched \(pending.count) pending verifications from Mock")
            single(.success(pending))
            return Disposables.create()
        }
    }

    func approveVerification(id: String) -> Single<MissionVerification> {
        return Single.create { [weak self] (single: @escaping (SingleEvent<MissionVerification>) -> Void) -> Disposable in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "MissionVerificationRepository", code: -1))))
                return Disposables.create()
            }

            // Mock에서 verification 찾기
            guard let index = self.mockVerifications.firstIndex(where: { $0.id == id }) else {
                single(.failure(RepositoryError.notFound))
                return Disposables.create()
            }

            let oldVerification = self.mockVerifications[index]

            guard oldVerification.status == .pending else {
                self.debugError("Verification is not pending: \(id)")
                single(.failure(RepositoryError.unknown(NSError(domain: "MissionVerificationRepository", code: -2, userInfo: [NSLocalizedDescriptionKey: "이미 처리된 인증입니다"]))))
                return Disposables.create()
            }

            // Get current user as parent
            Task {
                guard let user = await UserProfileManager.shared.getCurrentUser() else {
                    self.debugWarning("No user found, using mock approval")
                    self.approveMockVerification(index: index, oldVerification: oldVerification, single: single)
                    return
                }

                // API 호출 시도
                guard let verificationIdInt = Int(id),
                      let missionIdInt = Int(oldVerification.missionId),
                      let parentIdInt = Int(user.id) else {
                    self.debugWarning("Invalid ID format, using mock approval")
                    self.approveMockVerification(index: index, oldVerification: oldVerification, single: single)
                    return
                }

                // 실제 API 호출
                self.networkService.request(
                    MissionVerificationAPI.approveVerification(
                        missionId: missionIdInt,
                        verificationId: verificationIdInt,
                        parentId: parentIdInt
                    )
                )
                .subscribe(onNext: { (result: Result<MissionVerificationResponse, NetworkError>) in
                    switch result {
                    case .success(let verificationResponse):
                        let approvedVerification = verificationResponse.toDomain()

                        // Mock 데이터도 업데이트
                        self.mockVerifications[index] = approvedVerification

                        self.debugSuccess("Approved verification via API: \(id)")

                        // Post notification for approval
                        NotificationCenter.default.post(
                            name: .verificationApproved,
                            object: approvedVerification
                        )

                        // Update mission progress
                        self.updateMissionProgress(missionId: approvedVerification.missionId)

                        single(.success(approvedVerification))

                    case .failure(let error):
                        self.debugError("Failed to approve via API, using mock approval", error: error)
                        self.approveMockVerification(index: index, oldVerification: oldVerification, single: single)
                    }
                })
                .disposed(by: self.disposeBag)
            }

            return Disposables.create()
        }
    }

    private func approveMockVerification(
        index: Int,
        oldVerification: MissionVerification,
        single: @escaping (SingleEvent<MissionVerification>) -> Void
    ) {
        let approvedVerification = MissionVerification(
            id: oldVerification.id,
            missionId: oldVerification.missionId,
            childId: oldVerification.childId,
            type: oldVerification.type,
            content: oldVerification.content,
            memo: oldVerification.memo,
            submittedDate: oldVerification.submittedDate,
            reviewedBy: "parent_user",
            reviewedDate: Date(),
            status: .approved,
            rejectReason: nil
        )

        self.mockVerifications[index] = approvedVerification

        self.debugSuccess("Approved verification (Mock): \(oldVerification.id)")

        // Post notification for approval
        NotificationCenter.default.post(
            name: .verificationApproved,
            object: approvedVerification
        )

        // Update mission progress
        self.updateMissionProgress(missionId: approvedVerification.missionId)

        single(.success(approvedVerification))
    }

    func rejectVerification(id: String, reason: String) -> Single<MissionVerification> {
        return Single.create { [weak self] (single: @escaping (SingleEvent<MissionVerification>) -> Void) -> Disposable in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "MissionVerificationRepository", code: -1))))
                return Disposables.create()
            }

            guard let index = self.mockVerifications.firstIndex(where: { $0.id == id }) else {
                single(.failure(RepositoryError.notFound))
                return Disposables.create()
            }

            let oldVerification = self.mockVerifications[index]

            guard oldVerification.status == .pending else {
                self.debugError("Verification is not pending: \(id)")
                single(.failure(RepositoryError.unknown(NSError(domain: "MissionVerificationRepository", code: -2, userInfo: [NSLocalizedDescriptionKey: "이미 처리된 인증입니다"]))))
                return Disposables.create()
            }

            // Get current user as parent
            Task {
                guard let user = await UserProfileManager.shared.getCurrentUser() else {
                    self.debugWarning("No user found, using mock rejection")
                    self.rejectMockVerification(index: index, oldVerification: oldVerification, reason: reason, single: single)
                    return
                }

                // API 호출 시도
                guard let verificationIdInt = Int(id),
                      let missionIdInt = Int(oldVerification.missionId),
                      let parentIdInt = Int(user.id) else {
                    self.debugWarning("Invalid ID format, using mock rejection")
                    self.rejectMockVerification(index: index, oldVerification: oldVerification, reason: reason, single: single)
                    return
                }

                // 실제 API 호출
                self.networkService.request(
                    MissionVerificationAPI.rejectVerification(
                        missionId: missionIdInt,
                        verificationId: verificationIdInt,
                        parentId: parentIdInt,
                        reason: reason
                    )
                )
                .subscribe(onNext: { (result: Result<MissionVerificationResponse, NetworkError>) in
                    switch result {
                    case .success(let verificationResponse):
                        let rejectedVerification = verificationResponse.toDomain()

                        // Mock 데이터도 업데이트
                        self.mockVerifications[index] = rejectedVerification

                        self.debugSuccess("Rejected verification via API: \(id)")

                        // Post notification for rejection
                        NotificationCenter.default.post(
                            name: .verificationRejected,
                            object: rejectedVerification
                        )

                        single(.success(rejectedVerification))

                    case .failure(let error):
                        self.debugError("Failed to reject via API, using mock rejection", error: error)
                        self.rejectMockVerification(index: index, oldVerification: oldVerification, reason: reason, single: single)
                    }
                })
                .disposed(by: self.disposeBag)
            }

            return Disposables.create()
        }
    }

    private func rejectMockVerification(
        index: Int,
        oldVerification: MissionVerification,
        reason: String,
        single: @escaping (SingleEvent<MissionVerification>) -> Void
    ) {
        let rejectedVerification = MissionVerification(
            id: oldVerification.id,
            missionId: oldVerification.missionId,
            childId: oldVerification.childId,
            type: oldVerification.type,
            content: oldVerification.content,
            memo: oldVerification.memo,
            submittedDate: oldVerification.submittedDate,
            reviewedBy: "parent_user",
            reviewedDate: Date(),
            status: .rejected,
            rejectReason: reason
        )

        self.mockVerifications[index] = rejectedVerification

        self.debugSuccess("Rejected verification (Mock): \(oldVerification.id)")

        // Post notification for rejection
        NotificationCenter.default.post(
            name: .verificationRejected,
            object: rejectedVerification
        )

        single(.success(rejectedVerification))
    }

    private func submitMockVerification(
        request: MissionVerificationRequest,
        single: @escaping (SingleEvent<MissionVerification>) -> Void
    ) {
        // Create verification with PENDING status
        let verification = MissionVerification(
            id: "\(self.nextId)",
            missionId: request.missionId,
            childId: "current_user",  // Mock user ID
            type: request.type,
            content: request.content,
            memo: request.memo,
            submittedDate: Date(),
            reviewedBy: nil,
            reviewedDate: nil,
            status: .pending,
            rejectReason: nil
        )

        self.nextId += 1
        self.mockVerifications.append(verification)

        self.debugSuccess("Submitted verification (Mock): \(verification.id)")

        // Simulate auto-approval after 3 seconds (Phase 1 demo)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            self?.autoApproveVerification(verification.id)
        }

        single(.success(verification))
    }

    // MARK: - Private Helper Methods

    private func autoApproveVerification(_ verificationId: String) {
        guard let index = mockVerifications.firstIndex(where: { $0.id == verificationId }) else {
            return
        }

        let oldVerification = mockVerifications[index]

        let approvedVerification = MissionVerification(
            id: oldVerification.id,
            missionId: oldVerification.missionId,
            childId: oldVerification.childId,
            type: oldVerification.type,
            content: oldVerification.content,
            memo: oldVerification.memo,
            submittedDate: oldVerification.submittedDate,
            reviewedBy: "parent_user",
            reviewedDate: Date(),
            status: .approved,
            rejectReason: nil
        )

        mockVerifications[index] = approvedVerification

        debugSuccess("Auto-approved verification: \(verificationId)")

        // Post notification for auto-approval
        NotificationCenter.default.post(
            name: .verificationApproved,
            object: approvedVerification
        )

        // Update mission progress (mock)
        updateMissionProgress(missionId: approvedVerification.missionId)
    }

    private func updateMissionProgress(missionId: String) {
        // This is a mock implementation
        // In production, this would update the mission's currentAmount
        debugLog("Mock: Updated mission progress for mission: \(missionId)")

        // Post notification to update mission list
        NotificationCenter.default.post(
            name: .missionProgressUpdated,
            object: missionId
        )
    }

    // MARK: - Raw API Helpers

    private func submitVerificationRaw(
        missionId: Int,
        childId: Int,
        verificationType: String,
        content: String?
    ) -> Single<MissionVerificationResponse> {
        return Single.create { [weak self] single in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "MissionVerificationRepository", code: -1))))
                return Disposables.create()
            }

            let baseURL = Environment.current.baseURL
            guard let url = URL(string: "\(baseURL)/missions/\(missionId)/verifications") else {
                single(.failure(RepositoryError.unknown(NSError(domain: "MissionVerificationRepository", code: -2))))
                return Disposables.create()
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            if let accessToken = self.tokenManager.accessToken {
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }

            var params: [String: Any] = [
                "childId": childId,
                "verificationType": verificationType
            ]
            if let text = content {
                params["content"] = text
            }

            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: params)
            } catch {
                single(.failure(RepositoryError.unknown(error)))
                return Disposables.create()
            }

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    self.debugError("Verification submission error", error: error)
                    single(.failure(RepositoryError.unknown(error)))
                    return
                }

                guard let data = data else {
                    single(.failure(RepositoryError.unknown(NSError(domain: "MissionVerificationRepository", code: -3))))
                    return
                }

                do {
                    let verification = try JSONDecoder().decode(MissionVerificationResponse.self, from: data)
                    single(.success(verification))
                } catch {
                    self.debugError("Failed to decode verification response", error: error)
                    single(.failure(RepositoryError.decodingError(error)))
                }
            }

            task.resume()
            return Disposables.create { task.cancel() }
        }
    }

    private func getVerificationsRaw(missionId: Int) -> Single<[MissionVerificationResponse]> {
        return Single.create { [weak self] single in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "MissionVerificationRepository", code: -1))))
                return Disposables.create()
            }

            let baseURL = Environment.current.baseURL
            guard let url = URL(string: "\(baseURL)/missions/\(missionId)/verifications") else {
                single(.failure(RepositoryError.unknown(NSError(domain: "MissionVerificationRepository", code: -2))))
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
                    self.debugError("Verifications fetch error", error: error)
                    single(.failure(RepositoryError.unknown(error)))
                    return
                }

                guard let data = data else {
                    single(.failure(RepositoryError.unknown(NSError(domain: "MissionVerificationRepository", code: -3))))
                    return
                }

                do {
                    let verifications = try JSONDecoder().decode([MissionVerificationResponse].self, from: data)
                    single(.success(verifications))
                } catch {
                    self.debugError("Failed to decode verifications array", error: error)
                    single(.failure(RepositoryError.decodingError(error)))
                }
            }

            task.resume()
            return Disposables.create { task.cancel() }
        }
    }
}

