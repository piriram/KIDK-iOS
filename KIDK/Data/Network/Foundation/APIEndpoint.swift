import Foundation

protocol APIEndpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: [String: Any]? { get }
    var headers: [String: String]? { get }
    var requiresAuth: Bool { get }
    var usesRefreshToken: Bool { get }  // Refresh Token 사용 여부 (로그아웃/재발급 API용)
}

extension APIEndpoint {
    var headers: [String: String]? {
        return nil
    }

    var requiresAuth: Bool {
        return true
    }

    var usesRefreshToken: Bool {
        return false  // 기본값: Access Token 사용
    }
}
