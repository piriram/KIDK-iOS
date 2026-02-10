//
//  RequestInterceptor.swift
//  KIDK
//
//  Created by KIDK on 11/27/25.
//

import Foundation

protocol RequestInterceptor {
    func adapt(_ request: URLRequest) -> URLRequest
}

final class AuthRequestInterceptor: RequestInterceptor {

    private let tokenManager = TokenManager.shared

    func adapt(_ request: URLRequest) -> URLRequest {
        var request = request

        // Content-Type 설정
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Authorization 헤더 추가 (토큰이 있는 경우)
        if let accessToken = tokenManager.accessToken {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
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
