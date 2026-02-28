import Foundation

enum MissionVerificationAPI {
    case getVerifications(missionId: Int)
    case submitVerification(missionId: Int, verificationType: String, content: String?)
    case approveVerification(missionId: Int, verificationId: Int)
    case rejectVerification(missionId: Int, verificationId: Int, reason: String)
}

extension MissionVerificationAPI: APIEndpoint {
    var path: String {
        switch self {
        case .getVerifications(let missionId):
            return "/missions/\(missionId)/verifications"
        case .submitVerification(let missionId, _, _):
            return "/missions/\(missionId)/verifications"
        case .approveVerification(let missionId, let verificationId):
            return "/missions/\(missionId)/verifications/\(verificationId)/approve"
        case .rejectVerification(let missionId, let verificationId, _):
            return "/missions/\(missionId)/verifications/\(verificationId)/reject"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getVerifications:
            return .get
        case .submitVerification:
            return .post
        case .approveVerification, .rejectVerification:
            return .patch
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .submitVerification(_, let verificationType, let content):
            var params: [String: Any] = [
                "verificationType": verificationType
            ]
            if let text = content {
                params["content"] = text
            }
            return params

        case .approveVerification:
            return nil

        case .rejectVerification(_, _, let reason):
            return [
                "reason": reason
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

    var parameterEncoding: ParameterEncoding {
        switch self {
        case .submitVerification, .approveVerification, .rejectVerification:
            return .query
        default:
            return .methodDependent
        }
    }
}
