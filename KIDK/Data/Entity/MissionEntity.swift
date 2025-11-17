//
//  MissionEntity.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/16/25.
//

import Foundation
import RealmSwift

final class MissionEntity: Object {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var creatorId: String = ""
    @Persisted var ownerId: String = ""
    @Persisted var missionType: String = MissionType.custom.rawValue
    @Persisted var title: String = ""
    @Persisted var missionDescription: String?
    @Persisted var targetAmount: Int?
    @Persisted var rewardAmount: Int = 0
    @Persisted var targetDate: Date?
    @Persisted var status: String = MissionStatus.inProgress.rawValue
    @Persisted var createdAt: Date = Date()
    @Persisted var completedAt: Date?
    @Persisted var participants: List<MissionParticipantEntity>
    
    convenience init(from request: MissionCreationRequest, creatorId: String, ownerId: String) {
        self.init()
        self.creatorId = creatorId
        self.ownerId = ownerId
        self.missionType = request.missionType.rawValue
        self.title = request.title
        self.missionDescription = request.description
        self.rewardAmount = request.rewardAmount
        self.targetDate = request.targetDate
        self.status = MissionStatus.inProgress.rawValue
        self.createdAt = Date()
    }
    
    func toDomain() -> Mission {
        Mission(
            id: id,
            creatorId: creatorId,
            ownerId: ownerId,
            missionType: MissionType(rawValue: missionType) ?? .custom,
            title: title,
            description: missionDescription,
            targetAmount: targetAmount,
            rewardAmount: rewardAmount,
            targetDate: targetDate,
            status: MissionStatus(rawValue: status) ?? .inProgress,
            createdAt: createdAt,
            completedAt: completedAt,
            participants: participants.map { $0.toDomain() }
        )
    }
}
