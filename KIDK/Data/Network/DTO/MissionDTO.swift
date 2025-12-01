//
//  MissionDTO.swift
//  KIDK
//
//  Created by KIDK on 12/02/24.
//

import Foundation

// MARK: - Create Mission Request

struct CreateMissionRequest: Encodable {
    let creatorId: Int
    let ownerId: Int
    let missionType: String      // "SAVING", "STUDY", "QUIZ", "VIDEO", "CUSTOM"
    let title: String
    let description: String?
    let targetAmount: Double?
    let rewardAmount: Double
    let status: String           // "ACTIVE", "COMPLETED", "CANCELLED"
    let targetDate: String?      // "yyyy-MM-dd" format
}

// MARK: - User Info (nested in response)

struct UserInfo: Decodable {
    let id: Int
    let name: String
}

// MARK: - Mission Response

struct MissionResponse: Decodable {
    let createdAt: String
    let updatedAt: String
    let id: Int
    let creator: UserInfo
    let owner: UserInfo
    let missionType: String
    let title: String
    let description: String?
    let targetAmount: Double?
    let rewardAmount: Double
    let targetDate: String?      // "yyyy-MM-dd" format
    let status: String
    let completedAt: String?
}

// MARK: - Mission Progress Response

struct MissionProgressResponse: Decodable {
    let id: Int
    let mission: MissionProgressMissionInfo
    let user: UserInfo
    let progressAmount: Double?
    let progressPercentage: Double?
    let lastActivityAt: String
}

struct MissionProgressMissionInfo: Decodable {
    let id: Int
}

// MARK: - API Response Wrappers

typealias ApiResponseMission = ApiResponse<MissionResponse>
typealias ApiResponseMissionList = ApiResponse<[MissionResponse]>
typealias ApiResponseMissionProgress = ApiResponse<MissionProgressResponse>
typealias ApiResponseMissionProgressList = ApiResponse<[MissionProgressResponse]>

// MARK: - DTO to Domain Model

extension MissionResponse {
    func toDomain() -> Mission {
        // missionType 변환
        let type: MissionType
        switch missionType.uppercased() {
        case "SAVING", "SAVINGS":
            type = .savings
        case "STUDY":
            type = .study
        case "QUIZ":
            type = .quiz
        case "VIDEO":
            type = .video
        case "CUSTOM":
            type = .custom
        default:
            type = .custom
        }

        // status 변환
        let missionStatus: MissionStatus
        switch status.uppercased() {
        case "ACTIVE", "IN_PROGRESS":
            missionStatus = .inProgress
        case "COMPLETED":
            missionStatus = .completed
        case "CANCELLED":
            missionStatus = .cancelled
        default:
            missionStatus = .inProgress
        }

        // ISO8601 날짜 파싱
        let dateFormatter = ISO8601DateFormatter()
        let createdDate = dateFormatter.date(from: createdAt) ?? Date()
        let completedDate = completedAt.flatMap { dateFormatter.date(from: $0) }

        // targetDate는 "yyyy-MM-dd" 형식
        let targetDateObject: Date?
        if let targetDateString = targetDate {
            let simpleDateFormatter = DateFormatter()
            simpleDateFormatter.dateFormat = "yyyy-MM-dd"
            targetDateObject = simpleDateFormatter.date(from: targetDateString)
        } else {
            targetDateObject = nil
        }

        return Mission(
            id: String(id),
            creatorId: String(creator.id),
            ownerId: String(owner.id),
            missionType: type,
            title: title,
            description: description,
            targetAmount: targetAmount.map { Int($0) },
            currentAmount: 0,  // 현재 금액은 MissionProgress에서 가져와야 함
            rewardAmount: Int(rewardAmount),
            targetDate: targetDateObject,
            status: missionStatus,
            createdAt: createdDate,
            completedAt: completedDate,
            participants: []  // 참가자 정보는 별도 API에서 가져와야 함
        )
    }
}
