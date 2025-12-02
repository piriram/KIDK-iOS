//
//  FriendAPI.swift
//  KIDK
//
//  Created by KIDK on 12/02/24.
//

import Foundation

enum FriendAPI {
    case sendFriendRequest(requesterId: Int, addresseeId: Int)
    case getFriends(userId: Int)
    case deleteFriend(friendId: Int)
}

extension FriendAPI: APIEndpoint {
    var path: String {
        switch self {
        case .sendFriendRequest:
            return "/friends"
        case .getFriends(let userId):
            return "/friends/user/\(userId)"
        case .deleteFriend(let friendId):
            return "/friends/\(friendId)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .sendFriendRequest:
            return .post
        case .getFriends:
            return .get
        case .deleteFriend:
            return .delete
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .sendFriendRequest(let requesterId, let addresseeId):
            return [
                "requesterId": requesterId,
                "addresseeId": addresseeId
            ]

        default:
            return nil
        }
    }

    var headers: [String: String]? {
        return nil
    }

    var requiresAuth: Bool {
        return true
    }
}
