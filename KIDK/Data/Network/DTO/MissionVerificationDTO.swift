//
//  MissionVerificationDTO.swift
//  KIDK
//
//  Created by KIDK on 12/02/24.
//

import Foundation

// MARK: - Mission Verification Response

struct MissionVerificationResponse: Decodable {
    let id: Int
    let mission: MissionVerificationMissionInfo
    let child: UserInfo
    let verificationType: String
    let content: String?
    let submittedAt: String
    let reviewedBy: UserInfo?
    let reviewedAt: String?
    let status: String
    let rejectReason: String?
}

struct MissionVerificationMissionInfo: Decodable {
    let id: Int
    let title: String?
}

// MARK: - API Response Wrappers

typealias ApiResponseMissionVerification = ApiResponse<MissionVerificationResponse>
typealias ApiResponseMissionVerificationList = ApiResponse<[MissionVerificationResponse]>

// MARK: - DTO to Domain Model

extension MissionVerificationResponse {
    func toDomain() -> MissionVerification {
        // verificationType 변환
        let type: VerificationType
        switch verificationType.uppercased() {
        case "PHOTO":
            type = .photo
        case "TEXT":
            type = .text
        case "PARENT_CHECK":
            type = .parentCheck
        default:
            type = .text
        }

        // status 변환
        let verificationStatus: VerificationStatus
        switch status.uppercased() {
        case "PENDING":
            verificationStatus = .pending
        case "APPROVED":
            verificationStatus = .approved
        case "REJECTED":
            verificationStatus = .rejected
        default:
            verificationStatus = .pending
        }

        // ISO8601 날짜 파싱
        let dateFormatter = ISO8601DateFormatter()
        let submittedDate = dateFormatter.date(from: submittedAt) ?? Date()
        let reviewedDate = reviewedAt.flatMap { dateFormatter.date(from: $0) }

        return MissionVerification(
            id: String(id),
            missionId: String(mission.id),
            childId: String(child.id),
            type: type,
            content: content,
            memo: nil,
            submittedDate: submittedDate,
            reviewedBy: reviewedBy.map { String($0.id) },
            reviewedDate: reviewedDate,
            status: verificationStatus,
            rejectReason: rejectReason
        )
    }
}
