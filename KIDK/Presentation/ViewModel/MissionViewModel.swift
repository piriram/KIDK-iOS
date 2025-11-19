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

                // If no missions exist, create sample missions for testing
                if missions.isEmpty {
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

        // Create first sample mission
        let mission1 = MissionCreationRequest(
            title: "여름방학 놀이공원 가기",
            missionType: .savings,
            rewardAmount: 5000,
            targetDate: Calendar.current.date(byAdding: .day, value: 30, to: Date()),
            participantIds: [],
            description: "친구들과 함께 놀이공원 가기 위해 저축하기"
        )

        // Create second sample mission
        let mission2 = MissionCreationRequest(
            title: "새 자전거 사기",
            missionType: .savings,
            rewardAmount: 3000,
            targetDate: Calendar.current.date(byAdding: .day, value: 60, to: Date()),
            participantIds: [],
            description: "멋진 자전거를 사기 위한 저축 미션"
        )

        // Create third sample mission
        let mission3 = MissionCreationRequest(
            title: "게임기 구매",
            missionType: .savings,
            rewardAmount: 10000,
            targetDate: Calendar.current.date(byAdding: .day, value: 90, to: Date()),
            participantIds: [],
            description: "원하는 게임기를 사기 위한 저축"
        )

        let missions = [mission1, mission2, mission3]
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
