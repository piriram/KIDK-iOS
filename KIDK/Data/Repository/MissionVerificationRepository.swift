//
//  MissionVerificationRepository.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/19/25.
//

import Foundation
import RxSwift

final class MissionVerificationRepository: BaseRepository, MissionVerificationRepositoryProtocol {

    static let shared = MissionVerificationRepository()

    private override init() {
        super.init()
    }

    private var mockVerifications: [MissionVerification] = []
    private var nextId: Int = 1

    func submitVerification(_ request: MissionVerificationRequest) -> Single<MissionVerification> {
        return Single.create { [weak self] (single: @escaping (SingleEvent<MissionVerification>) -> Void) -> Disposable in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "MissionVerificationRepository", code: -1))))
                return Disposables.create()
            }

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

            self.debugSuccess("Verification submitted: \(verification.id) for mission: \(request.missionId)")

            // Simulate auto-approval after 3 seconds (Phase 1 demo)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
                self?.autoApproveVerification(verification.id)
            }

            single(.success(verification))
            return Disposables.create()
        }
    }

    func getVerifications(missionId: String) -> Single<[MissionVerification]> {
        return Single.create { [weak self] (single: @escaping (SingleEvent<[MissionVerification]>) -> Void) -> Disposable in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "MissionVerificationRepository", code: -1))))
                return Disposables.create()
            }

            let verifications = self.mockVerifications.filter { $0.missionId == missionId }
            self.debugLog("Fetched \(verifications.count) verifications for mission: \(missionId)")
            single(.success(verifications))
            return Disposables.create()
        }
    }

    func getPendingVerifications() -> Single<[MissionVerification]> {
        return Single.create { [weak self] (single: @escaping (SingleEvent<[MissionVerification]>) -> Disposable in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "MissionVerificationRepository", code: -1))))
                return Disposables.create()
            }

            let pending = self.mockVerifications.filter { $0.status == .pending }
            self.debugLog("Fetched \(pending.count) pending verifications")
            single(.success(pending))
            return Disposables.create()
        }
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
}
