import Foundation

// MARK: - Family Response

struct FamilyResponse: Decodable {
    let id: Int
    let familyName: String
    let inviteCode: String
    let onCreate: String  // API 응답 필드명과 일치

    enum CodingKeys: String, CodingKey {
        case id
        case familyName
        case inviteCode
        case onCreate
    }
}

// MARK: - Family Creation Request

struct FamilyCreationRequestDTO: Encodable {
    let userId: Int
    let familyName: String
}

// MARK: - Family Join Request

struct FamilyJoinRequestDTO: Encodable {
    let userId: Int
    let inviteCode: String
}

// MARK: - API Response Wrappers

typealias ApiResponseFamily = ApiResponse<FamilyResponse>
typealias ApiResponseFamilyList = ApiResponse<[FamilyResponse]>

// MARK: - DTO to Domain Model

extension FamilyResponse {
    func toDomain() -> Family {
        // ISO8601 날짜 파싱
        let dateFormatter = ISO8601DateFormatter()
        let createdDate = dateFormatter.date(from: onCreate) ?? Date()

        return Family(
            id: String(id),
            familyName: familyName,
            inviteCode: inviteCode,
            createdAt: createdDate,
            updatedAt: createdDate  // onCreate만 있으므로 같은 값 사용
        )
    }
}

// MARK: - Domain to DTO

extension FamilyCreationRequest {
    func toDTO() -> FamilyCreationRequestDTO? {
        guard let creatorIdInt = Int(creatorId) else { return nil }

        return FamilyCreationRequestDTO(
            userId: creatorIdInt,
            familyName: familyName
        )
    }
}

extension FamilyJoinRequest {
    func toDTO() -> FamilyJoinRequestDTO? {
        guard let userIdInt = Int(userId) else { return nil }

        return FamilyJoinRequestDTO(
            userId: userIdInt,
            inviteCode: inviteCode
        )
    }
}
