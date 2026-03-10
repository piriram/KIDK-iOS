import Foundation

enum MissionRewardType: String, Codable {
    case missionApproved
    case streakBonus
    case goalAmountAchieved
}

struct MissionRewardCompletedEvent: Codable {
    let missionId: String
    let rewardAmount: Int
    let rewardType: MissionRewardType
    let childId: String
    let timestamp: Date
    let idempotencyKey: String
}

struct CityProgress: Codable {
    let currentLevel: Int
    let exp: Int
    let unlockedZones: [String]
    let lastRewardedMissionId: String?
    let updatedAt: Date

    static let initial = CityProgress(
        currentLevel: 1,
        exp: 0,
        unlockedZones: [KIDKCityLocationType.home.rawValue, KIDKCityLocationType.school.rawValue],
        lastRewardedMissionId: nil,
        updatedAt: Date()
    )
}
