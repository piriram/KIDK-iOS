//
//  MissionViewModel.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/13/25.
//

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
        let collapseStates: Driver<[Bool]>
        let isLoading: Driver<Bool>
    }

    let navigateToKIDKCity: PublishSubject<Void> = PublishSubject()

    private let user: User
    private let missionRepository: MissionRepositoryProtocol

    private let missionsRelay = BehaviorRelay<[Mission]>(value: [])
    private let collapseStatesRelay = BehaviorRelay<[Bool]>(value: [])

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
                self?.toggleCollapseState(at: index)
            })
            .disposed(by: disposeBag)

        return Output(
            missions: missionsRelay.asDriver(),
            collapseStates: collapseStatesRelay.asDriver(),
            isLoading: isLoading.asDriver()
        )
    }

    private func fetchMissions() {
        isLoading.accept(true)

        missionRepository.fetchMissions(for: user.id)
            .subscribe(onSuccess: { [weak self] missions in
                guard let self = self else { return }
                self.debugLog("Fetched \(missions.count) missions")

                // Check if we have enough savings missions
                let savingsMissions = missions.filter { $0.missionType == .savings }
                self.debugLog("Found \(savingsMissions.count) savings missions")

                // If no missions exist or less than 3 savings missions, create sample missions
                if missions.isEmpty || savingsMissions.count < 3 {
                    self.debugLog("Creating sample missions (total: \(missions.count), savings: \(savingsMissions.count))")
                    self.createSampleMissions()
                } else {
                    self.missionsRelay.accept(missions)

                    // Initialize collapse states (all expanded by default)
                    let initialStates = Array(repeating: false, count: missions.count)
                    self.collapseStatesRelay.accept(initialStates)

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

    private func createSampleMissions() {
        debugLog("Creating sample missions for testing")

        // Create first sample mission - 닌텐도 스위치 모으기 (65% 진행)
        let mission1 = MissionCreationRequest(
            title: "닌텐도 스위치 모으기",
            missionType: .savings,
            targetAmount: 300000,
            currentAmount: 195000,
            rewardAmount: 10000,
            targetDate: Calendar.current.date(byAdding: .day, value: 30, to: Date()),
            participantIds: [],
            description: "친구들과 함께 놀이공원 가기 위해 저축하기"
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

    private func toggleCollapseState(at index: Int) {
        var currentStates = collapseStatesRelay.value
        guard index < currentStates.count else { return }

        currentStates[index].toggle()
        collapseStatesRelay.accept(currentStates)
        debugLog("Toggled collapse state at index \(index): \(currentStates[index])")
    }
}
