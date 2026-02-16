import Foundation
import RxSwift
import RxCocoa

final class MissionCreationViewModel: BaseViewModel {
    
    struct Input {
        let goalTitle: Observable<String>
        let targetDate: Observable<Date?>
        let rewardAmount: Observable<Int>
        let participantIds: Observable<[String]>
        let createTapped: Observable<Void>
    }
    
    struct Output {
        let isCreateEnabled: Driver<Bool>
        let missionCreated: Signal<Mission>
        let createError: Signal<Error>
    }
    
    private let missionRepository: MissionRepositoryProtocol
    let missionType: MissionType
    
    init(missionRepository: MissionRepositoryProtocol, missionType: MissionType = .video) {
        self.missionRepository = missionRepository
        self.missionType = missionType
        super.init()
    }
    
    func transform(input: Input) -> Output {
        let missionCreatedRelay = PublishRelay<Mission>()
        let createErrorRelay = PublishRelay<Error>()
        
        let isCreateEnabled = input.goalTitle
            .map { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .asDriver(onErrorJustReturn: false)
        
        let missionData = Observable.combineLatest(
            input.goalTitle,
            input.targetDate,
            input.rewardAmount,
            input.participantIds
        )
        
        input.createTapped
            .withLatestFrom(missionData)
            .flatMapLatest { [weak self] title, targetDate, rewardAmount, participantIds -> Observable<Mission> in
                guard let self = self else { return .empty() }

                self.debugLog("Create button tapped - title: \(title), targetDate: \(targetDate?.description ?? "nil"), rewardAmount: \(rewardAmount), participantIds: \(participantIds)")

                // missionType에 따라 기본 description 설정
                let defaultDescription: String
                switch self.missionType {
                case .video:
                    defaultDescription = "영상 미션을 완료해주세요"
                case .quiz:
                    defaultDescription = "퀴즈 미션을 완료해주세요"
                case .savings:
                    defaultDescription = "저축 목표를 달성해주세요"
                case .study:
                    defaultDescription = "학습 미션을 완료해주세요"
                case .custom:
                    defaultDescription = "미션을 완료해주세요"
                }

                let targetAmount = self.missionType == .savings ? 10000 : 0
                self.debugLog("Creating request - missionType: \(self.missionType.rawValue), targetAmount: \(targetAmount)")

                let request = MissionCreationRequest(
                    title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                    missionType: self.missionType,
                    targetAmount: targetAmount,  // SAVING 타입은 기본 목표 금액 설정
                    currentAmount: 0,
                    rewardAmount: rewardAmount,
                    targetDate: targetDate,
                    participantIds: participantIds,
                    description: defaultDescription
                )

                self.debugLog("MissionCreationRequest created successfully")
                self.startLoading()

                return self.missionRepository.createMission(request)
                    .asObservable()
                    .do(onNext: { [weak self] _ in
                        self?.stopLoading()
                        self?.debugSuccess("Mission created successfully")
                    }, onError: { [weak self] error in
                        self?.stopLoading()
                        self?.debugError("Mission creation failed", error: error)
                    })
                    .catch { error in
                        createErrorRelay.accept(error)
                        return .empty()
                    }
            }
            .bind(to: missionCreatedRelay)
            .disposed(by: disposeBag)
        
        return Output(
            isCreateEnabled: isCreateEnabled,
            missionCreated: missionCreatedRelay.asSignal(),
            createError: createErrorRelay.asSignal()
        )
    }
}
