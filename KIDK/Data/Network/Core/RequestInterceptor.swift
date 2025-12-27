import Foundation

protocol RequestInterceptor {
    func adapt(_ request: URLRequest, endpoint: APIEndpoint) -> URLRequest
}

final class AuthRequestInterceptor: RequestInterceptor {

    private let tokenManager = TokenManager.shared

    func adapt(_ request: URLRequest, endpoint: APIEndpoint) -> URLRequest {
        var request = request

        // Content-Type 설정
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // 인증이 필요한 경우 토큰 헤더 추가
        if endpoint.requiresAuth {
            if endpoint.usesRefreshToken {
                // Refresh Token 사용 (로그아웃/재발급 등)
                if let refreshToken = tokenManager.refreshToken {
                    request.setValue(refreshToken, forHTTPHeaderField: "Refresh-Token")
                }
            } else {
                // Access Token 사용 (일반 API)
                if let accessToken = tokenManager.accessToken {
                    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                }
            }
        }

        #if DEBUG
        print("📡 [Request] \(request.httpMethod ?? "UNKNOWN") \(request.url?.absoluteString ?? "UNKNOWN")")
        if let headers = request.allHTTPHeaderFields {
            print("📦 [Headers] \(headers)")
        }
        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            print("📤 [Body] \(bodyString)")
        }
        #endif

        return request
    }
}
