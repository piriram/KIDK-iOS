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
                self.missionsRelay.accept(missions)

                // Initialize collapse states (all expanded by default)
                let initialStates = Array(repeating: false, count: missions.count)
                self.collapseStatesRelay.accept(initialStates)

                self.isLoading.accept(false)
            }, onFailure: { [weak self] error in
                guard let self = self else { return }
                self.debugError("Failed to fetch missions", error: error)
                self.error.onNext(error)
                self.isLoading.accept(false)
            })
            .disposed(by: disposeBag)
    }

    private func toggleCollapseState(at index: Int) {
        var currentStates = collapseStatesRelay.value
        guard index < currentStates.count else { return }

        currentStates[index].toggle()
        collapseStatesRelay.accept(currentStates)
        debugLog("Toggled collapse state at index \(index): \(currentStates[index])")
    }
}
