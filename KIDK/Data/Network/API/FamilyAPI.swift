import Foundation

enum FamilyAPI {
    case createFamily(userId: Int, familyName: String)
    case getFamilies
    case getFamilyById(familyId: Int)
    case joinFamily(userId: Int, inviteCode: String)
}

extension FamilyAPI: APIEndpoint {
    var path: String {
        switch self {
        case .createFamily:
            return "/families"
        case .getFamilies:
            return "/families"
        case .getFamilyById(let familyId):
            return "/families/\(familyId)"
        case .joinFamily:
            return "/families/join"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .createFamily, .joinFamily:
            return .post
        case .getFamilies, .getFamilyById:
            return .get
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .createFamily(let userId, let familyName):
            return [
                "userId": userId,
                "familyName": familyName
            ]

        case .joinFamily(let userId, let inviteCode):
            return [
                "userId": userId,
                "inviteCode": inviteCode
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
