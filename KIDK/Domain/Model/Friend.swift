import Foundation

// MARK: - Friend Status

enum FriendStatus: String, Codable {
    case pending = "PENDING"
    case accepted = "ACCEPTED"
    case rejected = "REJECTED"
}

// MARK: - Friend

struct Friend: Codable {
    let id: String
    let requesterId: String
    let requesterName: String?
    let addresseeId: String
    let addresseeName: String?
    let status: FriendStatus
    let createdAt: Date
    let updatedAt: Date

    var isPending: Bool {
        return status == .pending
    }

    var isAccepted: Bool {
        return status == .accepted
    }

    var formattedCreatedDate: String {
        return createdAt.formattedFullDate
    }
}

// MARK: - Friend Request

struct FriendRequest {
    let requesterId: String
    let addresseeId: String
}
