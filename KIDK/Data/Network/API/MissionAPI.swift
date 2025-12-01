//
//  MissionAPI.swift
//  KIDK
//
//  Created by KIDK on 12/02/24.
//

import Foundation

enum MissionAPI {
    case createMission(creatorId: Int, ownerId: Int, missionType: String, title: String, description: String?, targetAmount: Double?, rewardAmount: Double, status: String, targetDate: String?)
    case completeMission(missionId: Int)
    case getMissionsByOwner(ownerId: Int)
    case getMissionsByCreator(creatorId: Int)
    case getMissionProgress(missionId: Int)
    case getMissionProgressByUser(userId: Int)
    case updateMissionProgress(missionId: Int, userId: Int, progressAmount: Double?, progressPercentage: Double?)
}

extension MissionAPI: APIEndpoint {
    var path: String {
        switch self {
        case .createMission:
            return "/missions"
        case .completeMission(let missionId):
            return "/missions/\(missionId)/complete"
        case .getMissionsByOwner(let ownerId):
            return "/missions/owner/\(ownerId)"
        case .getMissionsByCreator(let creatorId):
            return "/missions/creator/\(creatorId)"
        case .getMissionProgress(let missionId):
            return "/mission-progress/\(missionId)"
        case .getMissionProgressByUser(let userId):
            return "/mission-progress/user/\(userId)"
        case .updateMissionProgress(let missionId, _, _, _):
            return "/mission-progress/\(missionId)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .createMission:
            return .post
        case .completeMission:
            return .put
        case .getMissionsByOwner, .getMissionsByCreator, .getMissionProgress, .getMissionProgressByUser:
            return .get
        case .updateMissionProgress:
            return .post
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .createMission(let creatorId, let ownerId, let missionType, let title, let description, let targetAmount, let rewardAmount, let status, let targetDate):
            var params: [String: Any] = [
                "creatorId": creatorId,
                "ownerId": ownerId,
                "missionType": missionType,
                "title": title,
                "rewardAmount": rewardAmount,
                "status": status
            ]
            if let desc = description {
                params["description"] = desc
            }
            if let target = targetAmount {
                params["targetAmount"] = target
            }
            if let date = targetDate {
                params["targetDate"] = date
            }
            return params

        case .updateMissionProgress(_, let userId, let progressAmount, let progressPercentage):
            var params: [String: Any] = [
                "userId": userId
            ]
            if let amount = progressAmount {
                params["progressAmount"] = amount
            }
            if let percentage = progressPercentage {
                params["progressPercentage"] = percentage
            }
            return params

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
