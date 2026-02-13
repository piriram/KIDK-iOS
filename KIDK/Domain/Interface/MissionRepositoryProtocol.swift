import Foundation
import RxSwift

protocol MissionRepositoryProtocol {
    func createMission(_ request: MissionCreationRequest) -> Single<Mission>
    func fetchMission(by id: String) -> Single<Mission?>
    func fetchMissions(for userId: String) -> Single<[Mission]>
    func fetchMissionsByStatus(_ status: MissionStatus, for userId: String) -> Single<[Mission]>
    func updateMissionStatus(_ missionId: String, status: MissionStatus) -> Single<Mission>
    func deleteMission(_ missionId: String) -> Completable
}
