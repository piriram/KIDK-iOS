//
//  FriendDTO.swift
//  KIDK
//
//  Created by KIDK on 12/02/24.
//

import Foundation

// MARK: - Friend Response

struct FriendResponse: Decodable {
    let createdAt: String
    let updatedAt: String
    let id: Int
    let requester: UserInfo
    let addressee: UserInfo
    let status: String
}

// MARK: - Friend Request DTO

struct FriendRequestDTO: Encodable {
    let requesterId: Int
    let addresseeId: Int
}

// MARK: - API Response Wrappers

typealias ApiResponseFriend = ApiResponse<FriendResponse>
typealias ApiResponseFriendList = ApiResponse<[FriendResponse]>

// MARK: - DTO to Domain Model

extension FriendResponse {
    func toDomain() -> Friend {
        // status 변환
        let friendStatus: FriendStatus
        switch status.uppercased() {
        case "PENDING":
            friendStatus = .pending
        case "ACCEPTED":
            friendStatus = .accepted
        case "REJECTED":
            friendStatus = .rejected
        default:
            friendStatus = .pending
        }

        // ISO8601 날짜 파싱
        let dateFormatter = ISO8601DateFormatter()
        let createdDate = dateFormatter.date(from: createdAt) ?? Date()
        let updatedDate = dateFormatter.date(from: updatedAt) ?? Date()

        return Friend(
            id: String(id),
            requesterId: String(requester.id),
            requesterName: requester.name,
            addresseeId: String(addressee.id),
            addresseeName: addressee.name,
            status: friendStatus,
            createdAt: createdDate,
            updatedAt: updatedDate
        )
    }
}

// MARK: - Domain to DTO

extension FriendRequest {
    func toDTO() -> FriendRequestDTO? {
        guard let requesterIdInt = Int(requesterId),
              let addresseeIdInt = Int(addresseeId) else {
            return nil
        }

        return FriendRequestDTO(
            requesterId: requesterIdInt,
            addresseeId: addresseeIdInt
        )
    }
}
