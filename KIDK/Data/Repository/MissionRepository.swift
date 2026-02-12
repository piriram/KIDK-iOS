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

    init(
        currentUserId: String,
        networkService: NetworkService = .shared,
        tokenManager: TokenManager = .shared
    ) {
        self.currentUserId = currentUserId
        super.init(networkService: networkService, tokenManager: tokenManager)
    }
    
    func createMission(_ request: MissionCreationRequest) -> Single<Mission> {
        debugLog("Creating mission via API: \(request.title)")

        // creatorId와 ownerId는 currentUserId를 Int로 변환
        guard let creatorIdInt = Int(currentUserId) else {
            return .error(RepositoryError.invalidParameter)
        }

        // ownerId는 participantIds의 첫 번째 값, 없으면 creatorId
        let ownerIdInt = request.participantIds.compactMap { Int($0) }.first ?? creatorIdInt

        // targetDate를 "yyyy-MM-dd" 형식으로 변환
        let targetDateString: String?
        if let targetDate = request.targetDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            targetDateString = dateFormatter.string(from: targetDate)
        } else {
            targetDateString = nil
        }

        // API 호출
        return networkService.request(
            MissionAPI.createMission(
                creatorId: creatorIdInt,
                ownerId: ownerIdInt,
                missionType: request.missionType.rawValue.uppercased(),
                title: request.title,
                description: request.description,
                targetAmount: request.targetAmount.map { Double($0) },
                rewardAmount: Double(request.rewardAmount),
                status: "ACTIVE",
                targetDate: targetDateString
            )
        )
        .do(onNext: { [weak self] (result: Result<ApiResponseMission, NetworkError>) in
            guard let self = self else { return }

            switch result {
            case .success(let apiResponse):
                if let missionResponse = apiResponse.data {
                    self.debugSuccess("Mission created via API: \(missionResponse.id)")
                }
            case .failure(let error):
                self.debugError("Failed to create mission via API", error: error)
            }
        })
        .map { (result: Result<ApiResponseMission, NetworkError>) -> Mission in
            switch result {
            case .success(let apiResponse):
                guard let missionResponse = apiResponse.data else {
                    throw RepositoryError.unknown(NSError(domain: "MissionRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mission data is nil"]))
                }
                return missionResponse.toDomain()
            case .failure(let error):
                throw error
            }
        }
        .asSingle()
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
        Single.create { [weak self] (single: @escaping (SingleEvent<[Mission]>) -> Void) -> Disposable in
            guard let self = self else {
                single(.failure(RepositoryError.unknown(NSError(domain: "MissionRepository", code: -1))))
                return Disposables.create()
            }

            guard let userIdInt = Int(userId) else {
                // userId가 숫자가 아니면 Realm에서 가져옴
                return self.fetchMissionsFromRealm(for: userId, single: single)
            }

            // 실제 API 호출 (owner 기준)
            self.networkService.request(MissionAPI.getMissionsByOwner(ownerId: userIdInt))
                .subscribe(onNext: { (result: Result<ApiResponseMissionList, NetworkError>) in
                    switch result {
                    case .success(let apiResponse):
                        guard let missionResponses = apiResponse.data else {
                            self.debugLog("No missions found from API")
                            single(.success([]))
                            return
                        }
                        let missions = missionResponses.map { $0.toDomain() }
                        self.debugSuccess("Fetched \(missions.count) missions from API")
                        single(.success(missions))

                    case .failure(let error):
                        self.debugError("Failed to fetch missions from API", error: error)
                        // API 실패 시 Realm에서 가져옴
                        _ = self.fetchMissionsFromRealm(for: userId, single: single)
                    }
                })
                .disposed(by: self.disposeBag)

            return Disposables.create()
        }
    }

    private func fetchMissionsFromRealm(for userId: String, single: @escaping (SingleEvent<[Mission]>) -> Void) -> Disposable {
        do {
            let realm = try Realm()
            let missions = realm.objects(MissionEntity.self)
                .filter("ownerId == %@ OR creatorId == %@", userId, userId)
                .sorted(byKeyPath: "createdAt", ascending: false)
                .map { $0.toDomain() }

            self.debugLog("Fetched \(missions.count) missions from Realm")
            single(.success(Array(missions)))
        } catch {
            self.debugError("Failed to fetch missions from Realm", error: error)
            single(.failure(RepositoryError.unknown(error)))
        }

        return Disposables.create()
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
