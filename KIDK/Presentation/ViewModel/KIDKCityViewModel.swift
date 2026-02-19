import Foundation
import RxSwift
import RxCocoa

final class KIDKCityViewModel: BaseViewModel {

    struct Input {
        let viewDidAppear: Observable<Void>
        let locationTapped: Observable<KIDKCityLocationType>
        let missionCompleted: Observable<Void>
    }

    struct Output {
        let shouldStartAutoWalk: Driver<Bool>
        let locations: Driver<[KIDKCityLocation]>
        let gaugeProgress: Driver<Float>
        let gaugeText: Driver<String>
        let levelText: Driver<String>
        let isLoading: Driver<Bool>
    }

    let navigateToLocation: PublishSubject<KIDKCityLocationType> = PublishSubject()

    private let user: User

    private let gameStateRelay = BehaviorRelay<GameState>(value: .initial)

    init(user: User) {
        self.user = user
        super.init()
        debugLog("KIDKCityViewModel initialized")
    }

    func transform(input: Input) -> Output {
        let shouldStartAutoWalk = BehaviorRelay<Bool>(value: true)

        input.viewDidAppear
            .take(1)
            .map { true }
            .bind(to: shouldStartAutoWalk)
            .disposed(by: disposeBag)

        input.locationTapped
            .subscribe(onNext: { [weak self] locationType in
                guard let self = self else { return }
                let state = self.gameStateRelay.value

                if state.unlockedLocations.contains(locationType) {
                    self.debugLog("Location tapped: \(locationType)")
                    self.navigateToLocation.onNext(locationType)
                } else {
                    self.debugWarning("Blocked locked location tap: \(locationType)")
                }
            })
            .disposed(by: disposeBag)

        input.missionCompleted
            .subscribe(onNext: { [weak self] in
                self?.applyMissionCompletionReward()
            })
            .disposed(by: disposeBag)

        let locations = gameStateRelay
            .map { [weak self] state -> [KIDKCityLocation] in
                self?.createLocations(from: state) ?? []
            }
            .asDriver(onErrorJustReturn: [])

        let gaugeProgress = gameStateRelay
            .map { GaugeSystem.progress(points: $0.gaugePoint) }
            .asDriver(onErrorJustReturn: 0)

        let gaugeText = gameStateRelay
            .map { "\(Int(GaugeSystem.progress(points: $0.gaugePoint) * 100))%" }
            .asDriver(onErrorJustReturn: "0%")

        let levelText = gameStateRelay
            .map { "Lv.\($0.level)" }
            .asDriver(onErrorJustReturn: "Lv.1")

        return Output(
            shouldStartAutoWalk: shouldStartAutoWalk.asDriver(),
            locations: locations,
            gaugeProgress: gaugeProgress,
            gaugeText: gaugeText,
            levelText: levelText,
            isLoading: isLoading.asDriver()
        )
    }

    private func applyMissionCompletionReward() {
        var state = gameStateRelay.value
        state.gaugePoint += GaugeSystem.rewardPerMission
        state.level = GaugeSystem.level(points: state.gaugePoint)

        let unlocked = CityUnlockSystem.unlockedLocations(level: state.level)
        state.unlockedLocations = unlocked

        gameStateRelay.accept(state)
        debugSuccess("Mission reward applied - level: \(state.level), point: \(state.gaugePoint)")
    }

    private func createLocations(from state: GameState) -> [KIDKCityLocation] {
        return [
            KIDKCityLocation(
                type: .school,
                position: CGPoint(x: 0.5, y: 0.3),
                isUnlocked: state.unlockedLocations.contains(.school),
                requiredLevel: 1
            ),
            KIDKCityLocation(
                type: .mart,
                position: CGPoint(x: 0.7, y: 0.7),
                isUnlocked: state.unlockedLocations.contains(.mart),
                requiredLevel: 2
            )
        ]
    }
}

private struct GameState {
    var gaugePoint: Int
    var level: Int
    var unlockedLocations: Set<KIDKCityLocationType>

    static let initial = GameState(gaugePoint: 0, level: 1, unlockedLocations: [.home, .school])
}

private enum GaugeSystem {
    static let pointsPerLevel = 100
    static let rewardPerMission = 30

    static func level(points: Int) -> Int {
        return max(1, (points / pointsPerLevel) + 1)
    }

    static func progress(points: Int) -> Float {
        let remain = points % pointsPerLevel
        return Float(remain) / Float(pointsPerLevel)
    }
}

private enum CityUnlockSystem {
    static func unlockedLocations(level: Int) -> Set<KIDKCityLocationType> {
        var locations: Set<KIDKCityLocationType> = [.home, .school]

        if level >= 2 {
            locations.insert(.mart)
        }

        return locations
    }
}
