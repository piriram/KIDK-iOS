//
//  KIDKCityViewModel.swift
//  KIDK
//
//  Created by Claude on 11/17/25.
//

import Foundation
import RxSwift
import RxCocoa

final class KIDKCityViewModel: BaseViewModel {

    struct Input {
        let viewDidLoad: Observable<Void>
    }

    struct Output {
        let unlockedBuildings: Driver<Set<BuildingType>>
        let characterLevel: Driver<Int>
    }

    // MARK: - Properties
    private let unlockedBuildingsRelay = BehaviorRelay<Set<BuildingType>>(value: [])
    private let characterLevelRelay = BehaviorRelay<Int>(value: 10)

    // MARK: - Initialization
    override init() {
        super.init()
        debugLog("KIDKCityViewModel initialized")
        loadMockData()
    }

    // MARK: - Transform
    func transform(input: Input) -> Output {
        input.viewDidLoad
            .subscribe(onNext: { [weak self] in
                self?.debugLog("View did load")
            })
            .disposed(by: disposeBag)

        return Output(
            unlockedBuildings: unlockedBuildingsRelay.asDriver(),
            characterLevel: characterLevelRelay.asDriver()
        )
    }

    // MARK: - Private Methods
    private func loadMockData() {
        // Mock 데이터: 레벨 10, home과 mart 해금
        characterLevelRelay.accept(10)
        unlockedBuildingsRelay.accept([.home, .mart])

        debugLog("Mock data loaded: Level \(characterLevelRelay.value), Unlocked: \(unlockedBuildingsRelay.value)")
    }
}
