//
//  MissionParticipantEntity.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/16/25.
//

import Foundation
import RealmSwift

final class MissionParticipantEntity: Object {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var missionId: String = ""
    @Persisted var userId: String = ""
    @Persisted var role: String = MissionParticipantRole.member.rawValue
    @Persisted var joinedAt: Date = Date()
    
    @Persisted(originProperty: "participants") var mission: LinkingObjects<MissionEntity>
    
    convenience init(missionId: String, userId: String, role: MissionParticipantRole) {
        self.init()
        self.missionId = missionId
        self.userId = userId
        self.role = role.rawValue
        self.joinedAt = Date()
    }
    
    func toDomain() -> MissionParticipant {
        MissionParticipant(
            id: id,
            missionId: missionId,
            userId: userId,
            role: MissionParticipantRole(rawValue: role) ?? .member,
            joinedAt: joinedAt
        )
    }
}
