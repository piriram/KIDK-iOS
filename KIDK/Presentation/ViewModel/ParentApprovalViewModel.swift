import Foundation
import UIKit
import RxSwift
import RxCocoa

final class ParentApprovalViewModel: BaseViewModel {

    struct Input {
        let viewWillAppear: Observable<Void>
        let verificationSelected: Observable<IndexPath>
        let refreshTriggered: Observable<Void>
    }

    struct Output {
        let verifications: Driver<[VerificationWithMission]>
        let selectedVerification: Driver<VerificationWithMission>
        let isLoading: Driver<Bool>
        let error: Driver<String?>
    }

    struct VerificationWithMission {
        let verification: MissionVerification
        let missionTitle: String
    }

    private let verificationRepository: MissionVerificationRepositoryProtocol
    private let missionRepository: MissionRepositoryProtocol

    private let verificationsRelay = BehaviorRelay<[VerificationWithMission]>(value: [])
    private let selectedVerificationRelay = PublishRelay<VerificationWithMission>()
    private let errorRelay = PublishRelay<String?>()

    init(
        missionRepository: MissionRepositoryProtocol,
        verificationRepository: MissionVerificationRepositoryProtocol = MissionVerificationRepository.shared
    ) {
        self.verificationRepository = verificationRepository
        self.missionRepository = missionRepository
        super.init()

        // Subscribe to notifications
        subscribeToNotifications()
    }

    func transform(input: Input) -> Output {
        // Load pending verifications on view appear and refresh
        Observable.merge(input.viewWillAppear, input.refreshTriggered)
            .do(onNext: { [weak self] in
                self?.isLoading.accept(true)
            })
            .flatMapLatest { [weak self] _ -> Observable<[VerificationWithMission]> in
                guard let self = self else { return .empty() }
                return self.loadPendingVerifications()
            }
            .do(onNext: { [weak self] _ in
                self?.isLoading.accept(false)
            }, onError: { [weak self] error in
                self?.isLoading.accept(false)
                self?.errorRelay.accept("인증 목록을 불러올 수 없어요")
                self?.debugError("Failed to load verifications", error: error)
            })
            .bind(to: verificationsRelay)
            .disposed(by: disposeBag)

        // Handle verification selection
        input.verificationSelected
            .withLatestFrom(verificationsRelay) { indexPath, verifications in
                verifications[indexPath.row]
            }
            .bind(to: selectedVerificationRelay)
            .disposed(by: disposeBag)

        return Output(
            verifications: verificationsRelay.asDriver(),
            selectedVerification: selectedVerificationRelay.asDriver(onErrorDriveWith: .empty()),
            isLoading: isLoading.asDriver(),
            error: errorRelay.asDriver(onErrorJustReturn: nil)
        )
    }

    // MARK: - Private Methods

    private func loadPendingVerifications() -> Observable<[VerificationWithMission]> {
        return verificationRepository.getPendingVerifications()
            .asObservable()
            .flatMap { [weak self] verifications -> Observable<[VerificationWithMission]> in
                guard let self = self else { return .empty() }

                // Handle empty case
                guard !verifications.isEmpty else {
                    return .just([])
                }

                // Fetch mission details for each verification
                let observables = verifications.map { verification in
                    self.missionRepository.fetchMission(by: verification.missionId)
                        .asObservable()
                        .map { mission -> VerificationWithMission in
                            let missionTitle = mission?.title ?? self.getMockMissionTitle(for: verification.missionId)
                            return VerificationWithMission(
                                verification: verification,
                                missionTitle: missionTitle
                            )
                        }
                        .catchAndReturn(VerificationWithMission(
                            verification: verification,
                            missionTitle: self.getMockMissionTitle(for: verification.missionId)
                        ))
                }

                return Observable.zip(observables)
            }
            .do(onNext: { [weak self] verifications in
                self?.debugLog("Loaded \(verifications.count) pending verifications")
            })
    }

    private func getMockMissionTitle(for missionId: String) -> String {
        let mockTitles: [String: String] = [
            "mission_1": "방 정리하기",
            "mission_2": "책 30페이지 읽기",
            "mission_3": "설거지 돕기",
            "mission_4": "영어 단어 20개 외우기",
            "mission_5": "줄넘기 100개 하기",
            "mission_6": "수학 숙제 완료하기"
        ]
        return mockTitles[missionId] ?? "알 수 없는 미션"
    }

    private func subscribeToNotifications() {
        // Reload when verification is approved or rejected
        NotificationCenter.default.rx
            .notification(.verificationApproved)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.debugLog("Verification approved notification received")
                self?.reloadVerifications()
            })
            .disposed(by: disposeBag)

        NotificationCenter.default.rx
            .notification(.verificationRejected)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.debugLog("Verification rejected notification received")
                self?.reloadVerifications()
            })
            .disposed(by: disposeBag)
    }

    private func reloadVerifications() {
        isLoading.accept(true)

        loadPendingVerifications()
            .subscribe(
                onNext: { [weak self] verifications in
                    self?.verificationsRelay.accept(verifications)
                    self?.isLoading.accept(false)
                },
                onError: { [weak self] error in
                    self?.isLoading.accept(false)
                    self?.debugError("Failed to reload verifications", error: error)
                }
            )
            .disposed(by: disposeBag)
    }
}
