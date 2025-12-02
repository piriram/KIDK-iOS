//
//  FamilyMemberAPI.swift
//  KIDK
//
//  Created by KIDK on 12/02/24.
//

import Foundation

enum FamilyMemberAPI {
    case getFamilyMembers(familyId: Int)
    case removeFamilyMember(familyMemberId: Int)
}

extension FamilyMemberAPI: APIEndpoint {
    var path: String {
        switch self {
        case .getFamilyMembers(let familyId):
            return "/family-members/family/\(familyId)"
        case .removeFamilyMember(let familyMemberId):
            return "/family-members/\(familyMemberId)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getFamilyMembers:
            return .get
        case .removeFamilyMember:
            return .delete
        }
    }

    var parameters: [String: Any]? {
        return nil
    }

    var headers: [String: String]? {
        return nil
    }

    var requiresAuth: Bool {
        return true
    }
}
