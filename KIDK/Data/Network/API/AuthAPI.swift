//
//  AuthAPI.swift
//  KIDK
//
//  Created by KIDK on 11/27/25.
//

import Foundation

enum AuthAPI {
    case login(firebaseToken: String, deviceId: String?)
    case logout(refreshToken: String)
}

extension AuthAPI: APIEndpoint {
    var path: String {
        switch self {
        case .login:
            return "/auth/login"
        case .logout:
            return "/auth/logout"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .login, .logout:
            return .post
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .login(let firebaseToken, let deviceId):
            var params: [String: Any] = ["firebaseToken": firebaseToken]
            if let deviceId = deviceId {
                params["deviceId"] = deviceId
            }
            return params
        case .logout:
            return nil
        }
    }

    var headers: [String: String]? {
        switch self {
        case .logout(let refreshToken):
            return ["Refresh-Token": refreshToken]
        default:
            return nil
        }
    }

    var requiresAuth: Bool {
        switch self {
        case .login:
            return false  // 로그인은 인증 불필요
        case .logout:
            return true
        }
    }
}
