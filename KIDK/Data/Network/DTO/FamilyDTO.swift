//
//  FamilyDTO.swift
//  KIDK
//
//  Created by KIDK on 12/02/24.
//

import Foundation

// MARK: - Family Response

struct FamilyResponse: Decodable {
    let createdAt: String
    let updatedAt: String
    let id: Int
    let familyName: String
    let inviteCode: String
}

// MARK: - Family Creation Request

struct FamilyCreationRequestDTO: Encodable {
    let familyName: String
    let creatorId: Int
    let creatorRole: String
}

// MARK: - Family Join Request

struct FamilyJoinRequestDTO: Encodable {
    let userId: Int
    let inviteCode: String
    let role: String
}

// MARK: - API Response Wrappers

typealias ApiResponseFamily = ApiResponse<FamilyResponse>
typealias ApiResponseFamilyList = ApiResponse<[FamilyResponse]>

// MARK: - DTO to Domain Model

extension FamilyResponse {
    func toDomain() -> Family {
        // ISO8601 날짜 파싱
        let dateFormatter = ISO8601DateFormatter()
        let createdDate = dateFormatter.date(from: createdAt) ?? Date()
        let updatedDate = dateFormatter.date(from: updatedAt) ?? Date()

        return Family(
            id: String(id),
            familyName: familyName,
            inviteCode: inviteCode,
            createdAt: createdDate,
            updatedAt: updatedDate
        )
    }
}

// MARK: - Domain to DTO

extension FamilyCreationRequest {
    func toDTO() -> FamilyCreationRequestDTO? {
        guard let creatorIdInt = Int(creatorId) else { return nil }

        return FamilyCreationRequestDTO(
            familyName: familyName,
            creatorId: creatorIdInt,
            creatorRole: creatorRole.rawValue
        )
    }
}

extension FamilyJoinRequest {
    func toDTO() -> FamilyJoinRequestDTO? {
        guard let userIdInt = Int(userId) else { return nil }

        return FamilyJoinRequestDTO(
            userId: userIdInt,
            inviteCode: inviteCode,
            role: role.rawValue
        )
    }
}
