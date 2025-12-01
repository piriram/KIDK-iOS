//
//  MissionVerificationAPI.swift
//  KIDK
//
//  Created by KIDK on 12/02/24.
//

import Foundation

enum MissionVerificationAPI {
    case getVerifications(missionId: Int)
    case submitVerification(missionId: Int, childId: Int, verificationType: String, content: String?)
    case approveVerification(missionId: Int, verificationId: Int, parentId: Int)
    case rejectVerification(missionId: Int, verificationId: Int, parentId: Int, reason: String)
}

extension MissionVerificationAPI: APIEndpoint {
    var path: String {
        switch self {
        case .getVerifications(let missionId):
            return "/missions/\(missionId)/verifications"
        case .submitVerification(let missionId, _, _, _):
            return "/missions/\(missionId)/verifications"
        case .approveVerification(let missionId, let verificationId, _):
            return "/missions/\(missionId)/verifications/\(verificationId)/approve"
        case .rejectVerification(let missionId, let verificationId, _, _):
            return "/missions/\(missionId)/verifications/\(verificationId)/reject"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getVerifications:
            return .get
        case .submitVerification:
            return .post
        case .approveVerification, .rejectVerification:
            return .patch
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .submitVerification(_, let childId, let verificationType, let content):
            var params: [String: Any] = [
                "childId": childId,
                "verificationType": verificationType
            ]
            if let text = content {
                params["content"] = text
            }
            return params

        case .approveVerification(_, _, let parentId):
            return ["parentId": parentId]

        case .rejectVerification(_, _, let parentId, let reason):
            return [
                "parentId": parentId,
                "reason": reason
            ]

        default:
            return nil
        }
    }

    var headers: [String: String]? {
        return nil
    }

    var requiresAuth: Bool {
        return true
    }
}
