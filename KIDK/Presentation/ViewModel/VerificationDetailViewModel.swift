//
//  VerificationDetailViewModel.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/19/25.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

final class VerificationDetailViewModel: BaseViewModel {

    struct Input {
        let approveTapped: Observable<Void>
        let rejectTapped: Observable<String>  // Rejection reason
    }

    struct Output {
        let verification: Driver<MissionVerification>
        let missionTitle: Driver<String>
        let photoImage: Driver<UIImage?>
        let textContent: Driver<String?>
        let approvalSuccess: Driver<Void>
        let rejectionSuccess: Driver<Void>
        let error: Driver<String?>
        let isLoading: Driver<Bool>
    }

    private let verification: MissionVerification
    private let missionTitle: String
    private let verificationRepository: MissionVerificationRepositoryProtocol

    private let photoImageRelay = BehaviorRelay<UIImage?>(value: nil)
    private let textContentRelay = BehaviorRelay<String?>(value: nil)
    private let approvalSuccessRelay = PublishRelay<Void>()
    private let rejectionSuccessRelay = PublishRelay<Void>()
    private let errorRelay = PublishRelay<String?>()

    init(
        verification: MissionVerification,
        missionTitle: String,
        missionRepository: MissionRepositoryProtocol,
        verificationRepository: MissionVerificationRepositoryProtocol = MissionVerificationRepository.shared
    ) {
        self.verification = verification
        self.missionTitle = missionTitle
        self.verificationRepository = verificationRepository
        super.init()

        // Load content based on verification type
        loadContent()
    }

    func transform(input: Input) -> Output {
        // Handle approval
        input.approveTapped
            .do(onNext: { [weak self] in
                self?.isLoading.accept(true)
            })
            .flatMapLatest { [weak self] _ -> Observable<MissionVerification> in
                guard let self = self else { return .empty() }

                return self.verificationRepository.approveVerification(id: self.verification.id)
                    .asObservable()
                    .do(
                        onNext: { [weak self] _ in
                            self?.isLoading.accept(false)
                            self?.debugSuccess("Verification approved: \(self?.verification.id ?? "")")
                        },
                        onError: { [weak self] error in
                            self?.isLoading.accept(false)
                            self?.errorRelay.accept("승인 처리에 실패했어요")
                            self?.debugError("Failed to approve verification", error: error)
                        }
                    )
            }
            .map { _ in () }
            .bind(to: approvalSuccessRelay)
            .disposed(by: disposeBag)

        // Handle rejection
        input.rejectTapped
            .do(onNext: { [weak self] _ in
                self?.isLoading.accept(true)
            })
            .flatMapLatest { [weak self] reason -> Observable<MissionVerification> in
                guard let self = self else { return .empty() }

                return self.verificationRepository.rejectVerification(id: self.verification.id, reason: reason)
                    .asObservable()
                    .do(
                        onNext: { [weak self] _ in
                            self?.isLoading.accept(false)
                            self?.debugSuccess("Verification rejected: \(self?.verification.id ?? "")")
                        },
                        onError: { [weak self] error in
                            self?.isLoading.accept(false)
                            self?.errorRelay.accept("거절 처리에 실패했어요")
                            self?.debugError("Failed to reject verification", error: error)
                        }
                    )
            }
            .map { _ in () }
            .bind(to: rejectionSuccessRelay)
            .disposed(by: disposeBag)

        return Output(
            verification: Driver.just(verification),
            missionTitle: Driver.just(missionTitle),
            photoImage: photoImageRelay.asDriver(),
            textContent: textContentRelay.asDriver(),
            approvalSuccess: approvalSuccessRelay.asDriver(onErrorDriveWith: .empty()),
            rejectionSuccess: rejectionSuccessRelay.asDriver(onErrorDriveWith: .empty()),
            error: errorRelay.asDriver(onErrorJustReturn: nil),
            isLoading: isLoading.asDriver()
        )
    }

    // MARK: - Private Methods

    private func loadContent() {
        switch verification.type {
        case .photo:
            if let photoPath = verification.content {
                loadPhoto(from: photoPath)
            }
        case .text:
            textContentRelay.accept(verification.content)
        case .parentCheck:
            textContentRelay.accept("부모님 확인이 필요한 미션입니다")
        }
    }

    private func loadPhoto(from path: String) {
        let url = URL(fileURLWithPath: path)
        if let imageData = try? Data(contentsOf: url),
           let image = UIImage(data: imageData) {
            photoImageRelay.accept(image)
        } else {
            debugError("Failed to load photo from path: \(path)")
            photoImageRelay.accept(nil)
        }
    }
}
