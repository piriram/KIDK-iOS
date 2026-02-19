import Foundation

enum FriendAPI {
    case sendFriendRequest(addresseeId: Int)
    case getFriends
    case deleteFriend(friendId: Int)
}

extension FriendAPI: APIEndpoint {
    var path: String {
        switch self {
        case .sendFriendRequest:
            return "/friends/request"
        case .getFriends:
            return "/friends/me"
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
        case .sendFriendRequest(let addresseeId):
            return [
                "friendUserId": addresseeId
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
