import Foundation
import RxSwift
import RxCocoa

final class MissionViewModel: BaseViewModel {

    struct Input {
        let goToKIDKCityTapped: Observable<Void>
        let missionInfoTapped: Observable<Void>
        let collapseButtonTapped: Observable<Int>
    }

    struct Output {
        let missions: Driver<[Mission]>
        let expandedIndex: Driver<Int?>
        let isLoading: Driver<Bool>
    }

    let navigateToKIDKCity: PublishSubject<Void> = PublishSubject()

    private let user: User
    private let missionRepository: MissionRepositoryProtocol

    private let missionsRelay = BehaviorRelay<[Mission]>(value: [])
    private let expandedIndexRelay = BehaviorRelay<Int?>(value: nil)
    private var hasSampleMissionsCreated = false

    init(user: User, missionRepository: MissionRepositoryProtocol) {
        self.user = user
        self.missionRepository = missionRepository
        super.init()
        debugLog("MissionViewModel initialized")
        fetchMissions()
    }

    func transform(input: Input) -> Output {
        input.goToKIDKCityTapped
            .subscribe(onNext: { [weak self] in
                self?.debugLog("Navigate to KIDK City")
                self?.navigateToKIDKCity.onNext(())
            })
            .disposed(by: disposeBag)

        input.collapseButtonTapped
            .subscribe(onNext: { [weak self] index in
                self?.setExpandedIndex(at: index)
            })
            .disposed(by: disposeBag)

        return Output(
            missions: missionsRelay.asDriver(),
            expandedIndex: expandedIndexRelay.asDriver(),
            isLoading: isLoading.asDriver()
        )
    }

    private func fetchMissions() {
        isLoading.accept(true)

        if PortfolioCaptureMock.enabled {
            createSampleMissionsOnce()
        }

        missionRepository.fetchMissions(for: user.id)
            .subscribe(onSuccess: { [weak self] missions in
                guard let self = self else { return }
                self.debugLog("Fetched \(missions.count) missions")

                // Check if we have enough savings missions
                let savingsMissions = missions.filter { $0.missionType == .savings }
                self.debugLog("Found \(savingsMissions.count) savings missions")

                // Only create sample missions if NO missions exist at all AND not using mock data
                // (avoiding duplicate creation when API returns empty but Realm has data)
                if missions.isEmpty && !Environment.current.useMockMissionData {
                    self.debugLog("No missions found, creating sample missions")
                    self.createSampleMissionsOnce()
                } else {
                let savingsMissions = missions.filter { mission in
                    mission.missionType == .savings && (mission.status == .inProgress || mission.status == .completed)
                }

                let sortedMissions = savingsMissions.sorted { lhs, rhs in
                    if lhs.status != rhs.status {
                        return lhs.status == .inProgress
                    }
                    return lhs.createdAt > rhs.createdAt
                }

                self.missionsRelay.accept(sortedMissions)

                self.expandedIndexRelay.accept(sortedMissions.isEmpty ? nil : 0)

                    self.isLoading.accept(false)
                }
            }, onFailure: { [weak self] error in
                guard let self = self else { return }
                self.debugError("Failed to fetch missions", error: error)
                self.error.onNext(error)
                self.isLoading.accept(false)
            })
            .disposed(by: disposeBag)
    }

    private func createSampleMissionsOnce() {
        // Prevent duplicate creation
        guard !hasSampleMissionsCreated else {
            debugLog("Sample missions already created, skipping")
            return
        }
        hasSampleMissionsCreated = true
        createSampleMissions()
    }

    private func createSampleMissions() {
        debugLog("Creating sample missions for testing")

        // Create first sample mission - 닌텐도 스위치 모으기 (65% 진행)
        let mission1 = MissionCreationRequest(
            title: PortfolioCaptureMock.primaryMissionTitle,
            missionType: .savings,
            targetAmount: PortfolioCaptureMock.primaryMissionTargetAmount,
            currentAmount: PortfolioCaptureMock.primaryMissionCurrentAmount,
            rewardAmount: PortfolioCaptureMock.primaryMissionRewardAmount,
            targetDate: Calendar.current.date(byAdding: .day, value: 30, to: Date()),
            participantIds: [],
            description: "포트폴리오 핵심 미션: 목표 금액 모으기"
        )

        // Create second sample mission - 새 자전거 사기 (56.7% 진행)
        let mission2 = MissionCreationRequest(
            title: "새 자전거 사기",
            missionType: .savings,
            targetAmount: 150000,
            currentAmount: 85000,
            rewardAmount: 5000,
            targetDate: Calendar.current.date(byAdding: .day, value: 30, to: Date()),
            participantIds: [],
            description: "학교 갈 때 탈 새 자전거 사기"
        )

        // Create third sample mission - 가족 여행 기금 (72.5% 진행)
        let mission3 = MissionCreationRequest(
            title: "가족 여행 기금",
            missionType: .savings,
            targetAmount: 200000,
            currentAmount: 145000,
            rewardAmount: 8000,
            targetDate: Calendar.current.date(byAdding: .day, value: 20, to: Date()),
            participantIds: [],
            description: "가족과 함께 제주도 여행 가기"
        )

        // Create fourth sample mission - 친구 생일 선물 (70% 진행)
        let mission4 = MissionCreationRequest(
            title: "친구 생일 선물",
            missionType: .savings,
            targetAmount: 50000,
            currentAmount: 35000,
            rewardAmount: 2000,
            targetDate: Calendar.current.date(byAdding: .day, value: 10, to: Date()),
            participantIds: [],
            description: "친한 친구 생일 선물 사기"
        )

        // Create fifth sample mission - 새 운동화 (31.25% 진행)
        let mission5 = MissionCreationRequest(
            title: "새 운동화",
            missionType: .savings,
            targetAmount: 80000,
            currentAmount: 25000,
            rewardAmount: 3000,
            targetDate: Calendar.current.date(byAdding: .day, value: 50, to: Date()),
            participantIds: [],
            description: "체육 시간에 신을 운동화 사기"
        )

        // Create sixth sample mission - 새 게임기 (40% 진행)
        let mission6 = MissionCreationRequest(
            title: "새 게임기",
            missionType: .savings,
            targetAmount: 300000,
            currentAmount: 120000,
            rewardAmount: 10000,
            targetDate: Calendar.current.date(byAdding: .day, value: 60, to: Date()),
            participantIds: [],
            description: "친구들과 함께 할 게임기 사기"
        )

        let missions = [mission1, mission2, mission3, mission4, mission5, mission6]
        var createdCount = 0

        for request in missions {
            missionRepository.createMission(request)
                .subscribe(onSuccess: { [weak self] _ in
                    createdCount += 1
                    self?.debugSuccess("Sample mission created (\(createdCount)/\(missions.count))")

                    if createdCount == missions.count {
                        // All missions created, fetch again
                        self?.fetchMissions()
                    }
                }, onFailure: { [weak self] error in
                    self?.debugError("Failed to create sample mission", error: error)
                    self?.isLoading.accept(false)
                })
                .disposed(by: disposeBag)
        }
    }

    private func setExpandedIndex(at index: Int) {
        let missionsCount = missionsRelay.value.count
        guard index < missionsCount else { return }

        if expandedIndexRelay.value == index {
            expandedIndexRelay.accept(nil)
            debugLog("Collapsed mission index: \(index)")
            return
        }

        expandedIndexRelay.accept(index)
        debugLog("Expanded mission index updated to \(index)")
    }
}
