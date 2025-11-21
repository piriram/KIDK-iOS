//
//  MissionVerification.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/19/25.
//

import Foundation
import UIKit

// MARK: - Enums

enum VerificationType: String, Codable {
    case photo = "PHOTO"
    case text = "TEXT"
    case parentCheck = "PARENT_CHECK"

    var icon: String {
        switch self {
        case .photo: return "📷"
        case .text: return "✏️"
        case .parentCheck: return "👨‍👩‍👧"
        }
    }

    var displayName: String {
        switch self {
        case .photo: return "사진으로 인증"
        case .text: return "글로 인증"
        case .parentCheck: return "부모님 확인"
        }
    }
}

enum VerificationStatus: String, Codable {
    case pending = "PENDING"
    case approved = "APPROVED"
    case rejected = "REJECTED"

    var displayName: String {
        switch self {
        case .pending: return "승인 대기 중"
        case .approved: return "승인됨"
        case .rejected: return "거절됨"
        }
    }

    var color: UIColor {
        switch self {
        case .pending: return .kidkGray
        case .approved: return .kidkGreen
        case .rejected: return .systemRed
        }
    }
}

// MARK: - Models

struct MissionVerification {
    let id: String
    let missionId: String
    let childId: String
    let type: VerificationType
    let content: String?
    let memo: String?
    let submittedDate: Date
    let reviewedBy: String?
    let reviewedDate: Date?
    let status: VerificationStatus
    let rejectReason: String?

    /// 포맷된 제출 날짜
    var formattedSubmittedDate: String {
        return submittedDate.formattedDateTime
    }
}

struct MissionVerificationRequest {
    let missionId: String
    let type: VerificationType
    let content: String
    let memo: String?
}
