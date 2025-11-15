//
//  MissionRepository.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/16/25.
//

import Foundation
import RxSwift
import RealmSwift

final class MissionRepository: BaseRepository, MissionRepositoryProtocol {
    
    private let currentUserId: String
    
    init(currentUserId: String) {
        self.currentUserId = currentUserId
        super.init()
    }
    
    func createMission(_ request: MissionCreationRequest) -> Single<Mission> {
        Single.create { [weak self] single in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "MissionRepository", code: -1))))
                return Disposables.create()
            }
            
            do {
                let realm = try Realm()
                let missionEntity = MissionEntity(
                    from: request,
                    creatorId: self.currentUserId,
                    ownerId: self.currentUserId
                )
                
                let leaderParticipant = MissionParticipantEntity(
                    missionId: missionEntity.id,
                    userId: self.currentUserId,
                    role: .leader
                )
                missionEntity.participants.append(leaderParticipant)
                
                for participantId in request.participantIds {
                    let participant = MissionParticipantEntity(
                        missionId: missionEntity.id,
                        userId: participantId,
                        role: .member
                    )
                    missionEntity.participants.append(participant)
                }
                
                try realm.write {
                    realm.add(missionEntity)
                }
                
                self.debugSuccess("Mission created: \(missionEntity.id)")
                single(.success(missionEntity.toDomain()))
            } catch {
                self.debugError("Failed to create mission", error: error)
                single(.failure(RepositoryError.unknown(error)))
            }
            
            return Disposables.create()
        }
    }
    
    func fetchMission(by id: String) -> Single<Mission?> {
        Single.create { [weak self] single in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "MissionRepository", code: -1))))
                return Disposables.create()
            }
            
            do {
                let realm = try Realm()
                let missionEntity = realm.object(ofType: MissionEntity.self, forPrimaryKey: id)
                let mission = missionEntity?.toDomain()
                
                self.debugLog("Fetched mission: \(id), found: \(mission != nil)")
                single(.success(mission))
            } catch {
                self.debugError("Failed to fetch mission", error: error)
                single(.failure(RepositoryError.unknown(error)))
            }
            
            return Disposables.create()
        }
    }
    
    func fetchMissions(for userId: String) -> Single<[Mission]> {
        Single.create { [weak self] single in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "MissionRepository", code: -1))))
                return Disposables.create()
            }
            
            do {
                let realm = try Realm()
                let missions = realm.objects(MissionEntity.self)
                    .filter("ownerId == %@ OR creatorId == %@", userId, userId)
                    .sorted(byKeyPath: "createdAt", ascending: false)
                    .map { $0.toDomain() }
                
                self.debugLog("Fetched \(missions.count) missions for user: \(userId)")
                single(.success(Array(missions)))
            } catch {
                self.debugError("Failed to fetch missions", error: error)
                single(.failure(RepositoryError.unknown(error)))
            }
            
            return Disposables.create()
        }
    }
    
    func fetchMissionsByStatus(_ status: MissionStatus, for userId: String) -> Single<[Mission]> {
        Single.create { [weak self] single in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "MissionRepository", code: -1))))
                return Disposables.create()
            }
            
            do {
                let realm = try Realm()
                let missions = realm.objects(MissionEntity.self)
                    .filter("(ownerId == %@ OR creatorId == %@) AND status == %@", userId, userId, status.rawValue)
                    .sorted(byKeyPath: "createdAt", ascending: false)
                    .map { $0.toDomain() }
                
                self.debugLog("Fetched \(missions.count) missions with status: \(status.rawValue)")
                single(.success(Array(missions)))
            } catch {
                self.debugError("Failed to fetch missions by status", error: error)
                single(.failure(RepositoryError.unknown(error)))
            }
            
            return Disposables.create()
        }
    }
    
    func updateMissionStatus(_ missionId: String, status: MissionStatus) -> Single<Mission> {
        Single.create { [weak self] single in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "MissionRepository", code: -1))))
                return Disposables.create()
            }
            
            do {
                let realm = try Realm()
                guard let missionEntity = realm.object(ofType: MissionEntity.self, forPrimaryKey: missionId) else {
                    self.debugError("Mission not found: \(missionId)")
                    single(.failure(RepositoryError.notFound))
                    return Disposables.create()
                }
                
                try realm.write {
                    missionEntity.status = status.rawValue
                    if status == .completed {
                        missionEntity.completedAt = Date()
                    }
                }
                
                self.debugSuccess("Mission status updated: \(missionId) -> \(status.rawValue)")
                single(.success(missionEntity.toDomain()))
            } catch {
                self.debugError("Failed to update mission status", error: error)
                single(.failure(RepositoryError.unknown(error)))
            }
            
            return Disposables.create()
        }
    }
    
    func deleteMission(_ missionId: String) -> Completable {
        Completable.create { [weak self] completable in
            guard let self = self else {
                completable(.error(RepositoryError.unknown(NSError(domain: "MissionRepository", code: -1))))
                return Disposables.create()
            }
            
            do {
                let realm = try Realm()
                guard let missionEntity = realm.object(ofType: MissionEntity.self, forPrimaryKey: missionId) else {
                    self.debugError("Mission not found for deletion: \(missionId)")
                    completable(.error(RepositoryError.notFound))
                    return Disposables.create()
                }
                
                try realm.write {
                    realm.delete(missionEntity.participants)
                    realm.delete(missionEntity)
                }
                
                self.debugSuccess("Mission deleted: \(missionId)")
                completable(.completed)
            } catch {
                self.debugError("Failed to delete mission", error: error)
                completable(.error(RepositoryError.unknown(error)))
            }
            
            return Disposables.create()
        }
    }
}
