//
//  Mission.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/16/25.
//

import Foundation

enum MissionType: String, Codable {
    case savings = "SAVINGS"
    case study = "STUDY"
    case quiz = "QUIZ"
    case video = "VIDEO"
    case custom = "CUSTOM"
}

enum MissionStatus: String, Codable {
    case inProgress = "IN_PROGRESS"
    case completed = "COMPLETED"
    case cancelled = "CANCELLED"
}

enum MissionParticipantRole: String, Codable {
    case leader = "LEADER"
    case member = "MEMBER"
}

struct Mission {
    let id: String
    let creatorId: String
    let ownerId: String
    let missionType: MissionType
    let title: String
    let description: String?
    let targetAmount: Int?
    let rewardAmount: Int
    let targetDate: Date?
    let status: MissionStatus
    let createdAt: Date
    let completedAt: Date?
    let participants: [MissionParticipant]
}

struct MissionParticipant {
    let id: String
    let missionId: String
    let userId: String
    let role: MissionParticipantRole
    let joinedAt: Date
}

struct MissionCreationRequest {
    let title: String
    let missionType: MissionType
    let rewardAmount: Int
    let targetDate: Date?
    let participantIds: [String]
    let description: String?
}
