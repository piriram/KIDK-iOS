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

        // Create second sample mission - 경제 퀴즈 10문제 풀기 (70% 진행)
        let mission2 = MissionCreationRequest(
            title: "경제 퀴즈 10문제 풀기",
            missionType: .quiz,
            targetAmount: 10,
            currentAmount: 7,
            rewardAmount: 5000,
            targetDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()),
            participantIds: [],
            description: "경제 상식을 키우는 퀴즈 미션"
        )

        // Create third sample mission - 용돈 기입장 1주일 쓰기 (71% 진행)
        let mission3 = MissionCreationRequest(
            title: "용돈 기입장 1주일 쓰기",
            missionType: .custom,
            targetAmount: 7,
            currentAmount: 5,
            rewardAmount: 3000,
            targetDate: Calendar.current.date(byAdding: .day, value: 2, to: Date()),
            participantIds: [],
            description: "매일 용돈 사용 내역을 기록하기"
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
