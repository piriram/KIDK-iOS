import Foundation
import RxSwift
import RxCocoa

final class KIDKCityViewModel: BaseViewModel {

    struct Input {
        let viewDidAppear: Observable<Void>
        let locationTapped: Observable<KIDKCityLocationType>
        let missionCompleted: Observable<MissionRewardCompletedEvent>
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
    private let progressStore: CityProgressStore

    private let gameStateRelay = BehaviorRelay<GameState>(value: .initial)
    private var processedEventIds = Set<String>()

    init(user: User, progressStore: CityProgressStore = UserDefaultsCityProgressStore()) {
        self.user = user
        self.progressStore = progressStore
        super.init()

        let progress = progressStore.load(userId: user.id) ?? .initial
        gameStateRelay.accept(GameState(progress: progress))
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
            .subscribe(onNext: { [weak self] event in
                self?.applyMissionCompletionReward(event: event)
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

    private func applyMissionCompletionReward(event: MissionRewardCompletedEvent) {
        guard !processedEventIds.contains(event.idempotencyKey) else {
            debugWarning("Skip duplicated mission completion event: \(event.idempotencyKey)")
            return
        }
        processedEventIds.insert(event.idempotencyKey)

        // TODO: 서버 API 문서 기준으로 mission completion 확정 API 연동
        syncMissionCompletionIfNeeded(event: event)

        var state = gameStateRelay.value
        state.gaugePoint += GaugeSystem.rewardPoints(for: event.rewardType)
        state.level = GaugeSystem.level(points: state.gaugePoint)
        state.unlockedLocations = CityUnlockSystem.unlockedLocations(level: state.level)
        gameStateRelay.accept(state)

        let progress = state.toCityProgress(lastRewardedMissionId: event.missionId, updatedAt: event.timestamp)
        progressStore.save(progress, userId: user.id)

        debugSuccess(
            "Mission reward applied - missionId: \(event.missionId), type: \(event.rewardType.rawValue), level: \(state.level), exp: \(state.gaugePoint)"
        )
    }

    private func syncMissionCompletionIfNeeded(event: MissionRewardCompletedEvent) {
        // NOTE:
        // - endpoint/path: 서버 API 문서 기준
        // - payload/status/에러코드: 서버 API 문서 기준
        // - idempotency key: event.idempotencyKey 사용
        debugLog("Mission completion sync placeholder. payload=\(event)")
    }

    private func createLocations(from state: GameState) -> [KIDKCityLocation] {
        [
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

    init(gaugePoint: Int, level: Int, unlockedLocations: Set<KIDKCityLocationType>) {
        self.gaugePoint = gaugePoint
        self.level = level
        self.unlockedLocations = unlockedLocations
    }

    init(progress: CityProgress) {
        self.gaugePoint = progress.exp
        self.level = progress.currentLevel
        self.unlockedLocations = Set(progress.unlockedZones.compactMap(KIDKCityLocationType.init(rawValue:)))
        if self.unlockedLocations.isEmpty {
            self.unlockedLocations = [.home, .school]
        }
    }

    func toCityProgress(lastRewardedMissionId: String?, updatedAt: Date) -> CityProgress {
        CityProgress(
            currentLevel: level,
            exp: gaugePoint,
            unlockedZones: unlockedLocations.map(\.rawValue).sorted(),
            lastRewardedMissionId: lastRewardedMissionId,
            updatedAt: updatedAt
        )
    }
}

private enum GaugeSystem {
    static let pointsPerLevel = 100

    static func rewardPoints(for rewardType: MissionRewardType) -> Int {
        switch rewardType {
        case .missionApproved:
            return 10
        case .streakBonus:
            return 5
        case .goalAmountAchieved:
            return 20
        }
    }

    static func level(points: Int) -> Int {
        max(1, (points / pointsPerLevel) + 1)
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

protocol CityProgressStore {
    func load(userId: String) -> CityProgress?
    func save(_ progress: CityProgress, userId: String)
}

final class UserDefaultsCityProgressStore: CityProgressStore {
    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load(userId: String) -> CityProgress? {
        guard let data = defaults.data(forKey: storageKey(userId: userId)) else { return nil }
        return try? decoder.decode(CityProgress.self, from: data)
    }

    func save(_ progress: CityProgress, userId: String) {
        guard let data = try? encoder.encode(progress) else { return }
        defaults.set(data, forKey: storageKey(userId: userId))
    }

    private func storageKey(userId: String) -> String {
        "kidk.city.progress.\(userId)"
    }
}
