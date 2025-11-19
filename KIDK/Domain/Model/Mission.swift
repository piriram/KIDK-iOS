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
    let currentAmount: Int
    let rewardAmount: Int
    let targetDate: Date?
    let status: MissionStatus
    let createdAt: Date
    let completedAt: Date?
    let participants: [MissionParticipant]

    /// 진행률 계산 (0~100)
    var progressPercentage: Int {
        guard let target = targetAmount, target > 0 else { return 0 }
        let progress = (Double(currentAmount) / Double(target)) * 100.0
        return min(Int(progress), 100)
    }

    /// 남은 금액
    var remainingAmount: Int {
        guard let target = targetAmount else { return 0 }
        return max(target - currentAmount, 0)
    }

    /// 포맷된 목표 날짜 (예: "6월 7일까지")
    var formattedTargetDate: String? {
        guard let targetDate = targetDate else { return nil }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일"
        return formatter.string(from: targetDate) + "까지"
    }

    /// 포맷된 목표 금액
    var formattedTargetAmount: String? {
        guard let amount = targetAmount else { return nil }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return (formatter.string(from: NSNumber(value: amount)) ?? "0") + "원"
    }

    /// 포맷된 현재 금액
    var formattedCurrentAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return (formatter.string(from: NSNumber(value: currentAmount)) ?? "0") + "원"
    }
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
    let targetAmount: Int?
    let currentAmount: Int?
    let rewardAmount: Int
    let targetDate: Date?
    let participantIds: [String]
    let description: String?
}
