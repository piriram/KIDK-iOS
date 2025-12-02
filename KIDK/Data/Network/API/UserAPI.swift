//
//  UserAPI.swift
//  KIDK
//
//  Created by KIDK on 12/02/24.
//

import Foundation

enum UserAPI {
    case getMyProfile
    case updateProfile(name: String, birthDate: String?, phone: String?, userType: String?)
    case uploadProfileImage(imageData: Data)
    case deleteAccount
    case updateStatus(status: String)
    case getUserProfile(userId: Int)
}

extension UserAPI: APIEndpoint {
    var path: String {
        switch self {
        case .getMyProfile:
            return "/users/me"
        case .updateProfile:
            return "/users/me"
        case .uploadProfileImage:
            return "/users/me/profile-image"
        case .deleteAccount:
            return "/users/me"
        case .updateStatus:
            return "/users/me/status"
        case .getUserProfile(let userId):
            return "/users/\(userId)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getMyProfile, .getUserProfile:
            return .get
        case .updateProfile:
            return .put
        case .uploadProfileImage:
            return .post
        case .deleteAccount:
            return .delete
        case .updateStatus:
            return .patch
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .updateProfile(let name, let birthDate, let phone, let userType):
            var params: [String: Any] = ["name": name]
            if let birthDate = birthDate {
                params["birthDate"] = birthDate
            }
            if let phone = phone {
                params["phone"] = phone
            }
            if let userType = userType {
                params["userType"] = userType
            }
            return params

        case .updateStatus(let status):
            return ["status": status]

        default:
            return nil
        }
    }

    var headers: [String: String]? {
        switch self {
        case .uploadProfileImage:
            return ["Content-Type": "multipart/form-data"]
        default:
            return nil
        }
    }

    var requiresAuth: Bool {
        return true // 모든 User API는 인증 필요
    }
}
