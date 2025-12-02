//
//  FamilyAPI.swift
//  KIDK
//
//  Created by KIDK on 12/02/24.
//

import Foundation

enum FamilyAPI {
    case createFamily(familyName: String, creatorId: Int, creatorRole: String)
    case getFamiliesByUser(userId: Int)
    case joinFamily(userId: Int, inviteCode: String, role: String)
}

extension FamilyAPI: APIEndpoint {
    var path: String {
        switch self {
        case .createFamily:
            return "/families"
        case .getFamiliesByUser(let userId):
            return "/families/user/\(userId)"
        case .joinFamily:
            return "/families/join"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .createFamily, .joinFamily:
            return .post
        case .getFamiliesByUser:
            return .get
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .createFamily(let familyName, let creatorId, let creatorRole):
            return [
                "familyName": familyName,
                "creatorId": creatorId,
                "creatorRole": creatorRole
            ]

        case .joinFamily(let userId, let inviteCode, let role):
            return [
                "userId": userId,
                "inviteCode": inviteCode,
                "role": role
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
