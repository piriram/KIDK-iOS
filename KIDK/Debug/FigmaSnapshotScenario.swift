#if DEBUG
import UIKit
import RxSwift

/// Figma 시안 비교용 스냅샷 진입 시나리오
/// launch 예시: xcrun simctl launch booted com.kidk.KIDK --figma-snapshot mission-before
enum FigmaSnapshotScenario: String {
    case missionBefore = "mission-before"
    case missionAfter = "mission-after"
    case missionInProgress = "mission-in-progress"
    case missionCompleted = "mission-completed"
    case cityBase = "city-base"
    case cityBuildingDetail = "city-building-detail"
    case missionSelection = "mission-selection"
    case missionCreation = "mission-creation"

    static func fromLaunchArguments(_ args: [String] = ProcessInfo.processInfo.arguments) -> FigmaSnapshotScenario? {
        guard let flagIndex = args.firstIndex(of: "--figma-snapshot"), args.indices.contains(flagIndex + 1) else {
            return nil
        }
        return FigmaSnapshotScenario(rawValue: args[flagIndex + 1])
    }
}

enum FigmaSnapshotBuilder {
    static func makeRootViewController(for scenario: FigmaSnapshotScenario) -> UIViewController {
        let user = makeSnapshotUser()

        Task {
            await UserProfileManager.shared.saveProfile(user)
        }

        switch scenario {
        case .missionBefore:
            return missionRootController(user: user, missions: [])

        case .missionAfter:
            return missionRootController(user: user, missions: [makeMissionAfterCreated(userId: user.id)])

        case .missionInProgress:
            let vc = KIDKCityViewController(viewModel: KIDKCityViewModel(user: user), user: user)
            vc.setDebugSnapshotAction(.none)
            return UINavigationController(rootViewController: vc)

        case .missionCompleted:
            let vc = KIDKCityViewController(viewModel: KIDKCityViewModel(user: user), user: user)
            vc.setDebugSnapshotAction(.showMissionCompletedPopup)
            return UINavigationController(rootViewController: vc)

        case .cityBase:
            let vc = KIDKCityViewController(viewModel: KIDKCityViewModel(user: user), user: user)
            vc.setDebugSnapshotAction(.none)
            return UINavigationController(rootViewController: vc)

        case .cityBuildingDetail:
            let vc = KIDKCityViewController(viewModel: KIDKCityViewModel(user: user), user: user)
            vc.setDebugSnapshotAction(.showBuildingDetail)
            return UINavigationController(rootViewController: vc)

        case .missionSelection:
            let vc = KIDKCityViewController(viewModel: KIDKCityViewModel(user: user), user: user)
            vc.setDebugSnapshotAction(.showMissionSelection)
            return UINavigationController(rootViewController: vc)

        case .missionCreation:
            let vc = KIDKCityViewController(viewModel: KIDKCityViewModel(user: user), user: user)
            vc.setDebugSnapshotAction(.showMissionCreation)
            return UINavigationController(rootViewController: vc)
        }
    }

    private static func missionRootController(user: User, missions: [Mission]) -> UIViewController {
        let repository = SnapshotMissionRepository(initialMissions: missions)
        let viewModel = MissionViewModel(user: user, missionRepository: repository)
        let vc = MissionViewController(viewModel: viewModel)
        return UINavigationController(rootViewController: vc)
    }

    private static func makeSnapshotUser() -> User {
        User(
            id: "1001",
            firebaseUID: "SNAPSHOT_USER",
            userType: .child,
            name: "김시아"
        )
    }

    private static func makeParticipants(missionId: String) -> [MissionParticipant] {
        [
            MissionParticipant(id: "p1", missionId: missionId, userId: "2001", role: .member, joinedAt: Date()),
            MissionParticipant(id: "p2", missionId: missionId, userId: "2002", role: .member, joinedAt: Date()),
            MissionParticipant(id: "p3", missionId: missionId, userId: "2003", role: .member, joinedAt: Date())
        ]
    }

    private static func makeMissionAfterCreated(userId: String) -> Mission {
        let targetDate = Calendar.current.date(byAdding: .day, value: 30, to: Date())
        return Mission(
            id: "m-after",
            creatorId: userId,
            ownerId: userId,
            missionType: .savings,
            title: "여름방학 놀이공원 가기",
            description: "[저축의 즐거움] 영상 시청 후 퀴즈 풀기",
            targetAmount: 50000,
            currentAmount: 0,
            rewardAmount: 1000,
            targetDate: targetDate,
            status: .inProgress,
            createdAt: Date(),
            completedAt: nil,
            participants: makeParticipants(missionId: "m-after")
        )
    }

    private static func makeMissionInProgress(userId: String) -> Mission {
        let targetDate = Calendar.current.date(byAdding: .day, value: 30, to: Date())
        return Mission(
            id: "m-progress",
            creatorId: userId,
            ownerId: userId,
            missionType: .savings,
            title: "여름방학 놀이공원 가기",
            description: "[저축의 즐거움] 영상 시청 후 퀴즈 풀기",
            targetAmount: 50000,
            currentAmount: 12000,
            rewardAmount: 1000,
            targetDate: targetDate,
            status: .inProgress,
            createdAt: Date(),
            completedAt: nil,
            participants: makeParticipants(missionId: "m-progress")
        )
    }

    private static func makeMissionCompleted(userId: String) -> Mission {
        let targetDate = Calendar.current.date(byAdding: .day, value: -2, to: Date())
        return Mission(
            id: "m-completed",
            creatorId: userId,
            ownerId: userId,
            missionType: .savings,
            title: "여름방학 놀이공원 가기",
            description: "[저축의 즐거움] 영상 시청 후 퀴즈 풀기",
            targetAmount: 50000,
            currentAmount: 50000,
            rewardAmount: 1000,
            targetDate: targetDate,
            status: .completed,
            createdAt: Date(),
            completedAt: Date(),
            participants: makeParticipants(missionId: "m-completed")
        )
    }
}

final class SnapshotMissionRepository: MissionRepositoryProtocol {
    private var missions: [Mission]

    init(initialMissions: [Mission]) {
        self.missions = initialMissions
    }

    func createMission(_ request: MissionCreationRequest) -> Single<Mission> {
        let newMission = Mission(
            id: UUID().uuidString,
            creatorId: "1001",
            ownerId: "1001",
            missionType: request.missionType,
            title: request.title,
            description: request.description,
            targetAmount: request.targetAmount,
            currentAmount: request.currentAmount ?? 0,
            rewardAmount: request.rewardAmount,
            targetDate: request.targetDate,
            status: .inProgress,
            createdAt: Date(),
            completedAt: nil,
            participants: []
        )
        missions.append(newMission)
        return .just(newMission)
    }

    func fetchMission(by id: String) -> Single<Mission?> {
        .just(missions.first(where: { $0.id == id }))
    }

    func fetchMissions(for userId: String) -> Single<[Mission]> {
        .just(missions.filter { $0.ownerId == userId || $0.creatorId == userId })
    }

    func fetchMissionsByStatus(_ status: MissionStatus, for userId: String) -> Single<[Mission]> {
        .just(missions.filter { ($0.ownerId == userId || $0.creatorId == userId) && $0.status == status })
    }

    func updateMissionStatus(_ missionId: String, status: MissionStatus) -> Single<Mission> {
        guard let index = missions.firstIndex(where: { $0.id == missionId }) else {
            return .error(RepositoryError.notFound)
        }

        let old = missions[index]
        let updated = Mission(
            id: old.id,
            creatorId: old.creatorId,
            ownerId: old.ownerId,
            missionType: old.missionType,
            title: old.title,
            description: old.description,
            targetAmount: old.targetAmount,
            currentAmount: old.currentAmount,
            rewardAmount: old.rewardAmount,
            targetDate: old.targetDate,
            status: status,
            createdAt: old.createdAt,
            completedAt: status == .completed ? Date() : old.completedAt,
            participants: old.participants
        )
        missions[index] = updated
        return .just(updated)
    }

    func deleteMission(_ missionId: String) -> Completable {
        missions.removeAll { $0.id == missionId }
        return .empty()
    }

    func getMissionProgress(missionId: String) -> Single<MissionProgress?> {
        .just(nil)
    }

    func getMissionProgressByUser(userId: String) -> Single<[MissionProgress]> {
        .just([])
    }

    func updateMissionProgress(
        missionId: String,
        userId: String,
        progressAmount: Double?,
        progressPercentage: Double?
    ) -> Single<MissionProgress> {
        .just(
            MissionProgress(
                id: UUID().uuidString,
                missionId: missionId,
                userId: userId,
                progressAmount: progressAmount,
                progressPercentage: progressPercentage,
                lastActivityAt: Date()
            )
        )
    }
}
#endif
