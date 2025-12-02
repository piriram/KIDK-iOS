//
//  FamilyMemberDTO.swift
//  KIDK
//
//  Created by KIDK on 12/02/24.
//

import Foundation

// MARK: - Family Member Response

struct FamilyMemberResponse: Decodable {
    let createdAt: String
    let updatedAt: String
    let id: Int
    let family: FamilyInfo
    let user: UserInfo
    let role: String
}

struct FamilyInfo: Decodable {
    let id: Int
    let familyName: String
}

// MARK: - API Response Wrappers

typealias ApiResponseFamilyMember = ApiResponse<FamilyMemberResponse>
typealias ApiResponseFamilyMemberList = ApiResponse<[FamilyMemberResponse]>

// MARK: - DTO to Domain Model

extension FamilyMemberResponse {
    func toDomain() -> FamilyMember {
        // role 변환
        let memberRole: FamilyRole
        switch role.uppercased() {
        case "PARENT":
            memberRole = .parent
        case "CHILD":
            memberRole = .child
        default:
            memberRole = .child
        }

        // ISO8601 날짜 파싱 (joinedAt은 createdAt 사용)
        let dateFormatter = ISO8601DateFormatter()
        let joinedDate = dateFormatter.date(from: createdAt) ?? Date()

        return FamilyMember(
            id: String(id),
            familyId: String(family.id),
            userId: String(user.id),
            userName: user.name,
            role: memberRole,
            joinedAt: joinedDate
        )
    }
}
