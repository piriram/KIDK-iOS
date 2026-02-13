import Foundation

enum AuthAPI {
    case login(firebaseToken: String, deviceId: String?)
    case devLogin
    case logout
    case refreshToken
}

extension AuthAPI: APIEndpoint {
    var path: String {
        switch self {
        case .login:
            return "/auth/login"
        case .devLogin:
            return "/auth/dev/login"
        case .logout:
            return "/auth/logout"
        case .refreshToken:
            return "/auth/refresh"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .login, .devLogin, .logout, .refreshToken:
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
        case .devLogin, .logout, .refreshToken:
            return nil
        }
    }

    var requiresAuth: Bool {
        switch self {
        case .login, .devLogin:
            return false  // 로그인은 인증 불필요
        case .logout, .refreshToken:
            return true   // Refresh Token 필요
        }
    }

    var usesRefreshToken: Bool {
        switch self {
        case .logout, .refreshToken:
            return true   // Refresh-Token 헤더 사용
        case .login, .devLogin:
            return false
        }
    }
}
