//
//  AuthDTO.swift
//  KIDK
//
//  Created by KIDK on 11/27/25.
//

import Foundation

// MARK: - API Response Wrapper

/// 백엔드 공통 응답 포맷
struct ApiResponse<T: Decodable>: Decodable {
    let success: Bool
    let data: T?
    let error: APIErrorResponse?
}

/// 에러 응답 구조
struct APIErrorResponse: Decodable {
    let code: String
    let message: String
}

/// Data가 없는 성공 응답을 위한 타입
struct EmptyData: Decodable {}

// MARK: - Login Request

struct LoginRequest: Encodable {
    let firebaseToken: String
    let deviceId: String?
}

// MARK: - Login Response Data

struct LoginResponseData: Decodable {
    let accessToken: String
    let refreshToken: String
    let userId: Int
    let name: String
    let userType: String
}

// MARK: - User Response

struct UserResponse: Decodable {
    let id: Int
    let firebaseUid: String
    let email: String?
    let socialProvider: String?
    let socialProviderId: String?
    let userType: String
    let name: String
    let profileImageUrl: String?
    let birthDate: String?
    let phone: String?
    let status: String
    let statusChangedAt: String?
    let lastLoginAt: String?
}

// MARK: - DTO to Domain Model

extension LoginResponseData {
    func toDomain(firebaseUID: String) -> User {
        return User(
            id: String(userId),
            firebaseUID: firebaseUID,
            userType: UserType(rawValue: userType.lowercased()) ?? .child,
            name: name,
            nickname: nil,
            profileImageURL: nil,
            birthdate: nil,
            status: .active,
            createdAt: Date(),
            lastLoginAt: Date()
        )
    }
}

extension UserResponse {
    func toDomain() -> User {
        let dateFormatter = ISO8601DateFormatter()

        return User(
            id: String(id),
            firebaseUID: firebaseUid,
            userType: UserType(rawValue: userType.lowercased()) ?? .child,
            name: name,
            nickname: nil,
            profileImageURL: profileImageUrl,
            birthdate: birthDate.flatMap { dateFormatter.date(from: $0) },
            status: UserStatus(rawValue: status.lowercased()) ?? .active,
            createdAt: Date(),
            lastLoginAt: lastLoginAt.flatMap { dateFormatter.date(from: $0) }
        )
    }
}
