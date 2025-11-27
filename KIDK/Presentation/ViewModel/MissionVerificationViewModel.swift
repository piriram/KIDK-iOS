import Foundation
import RxSwift
import RxCocoa
import UIKit

final class MissionVerificationViewModel: BaseViewModel {

    struct Input {
        let verificationType: Observable<VerificationType>
        let photoSelected: Observable<UIImage?>
        let textInput: Observable<String>
        let memo: Observable<String?>
        let submitTapped: Observable<Void>
    }

    struct Output {
        let missionInfo: Driver<(title: String, progress: Int)>
        let isPhotoMode: Driver<Bool>
        let isSubmitEnabled: Driver<Bool>
        let characterCount: Driver<String>
        let verificationSubmitted: Driver<MissionVerification>
        let validationError: Driver<String?>
        let isLoading: Driver<Bool>
    }

    private let mission: Mission
    private let repository: MissionVerificationRepositoryProtocol

    private let verificationSubmittedRelay = PublishRelay<MissionVerification>()
    private let validationErrorRelay = PublishRelay<String?>()

    init(mission: Mission, repository: MissionVerificationRepositoryProtocol = MissionVerificationRepository.shared) {
        self.mission = mission
        self.repository = repository
        super.init()
    }

    func transform(input: Input) -> Output {
        let missionInfo = Observable.just((title: mission.title, progress: mission.progressPercentage))
            .asDriver(onErrorJustReturn: (title: "", progress: 0))

        let isPhotoMode = input.verificationType
            .map { $0 == .photo }
            .asDriver(onErrorJustReturn: true)

        let characterCount = input.textInput
            .map { "\($0.count)/500" }
            .asDriver(onErrorJustReturn: "0/500")

        let isSubmitEnabled = Observable.combineLatest(
            input.verificationType,
            input.photoSelected,
            input.textInput
        )
        .map { type, photo, text -> Bool in
            switch type {
            case .photo:
                return photo != nil
            case .text:
                return text.trimmingCharacters(in: .whitespacesAndNewlines).count >= 10
            case .parentCheck:
                return false
            }
        }
        .asDriver(onErrorJustReturn: false)

        input.submitTapped
            .withLatestFrom(Observable.combineLatest(
                input.verificationType,
                input.photoSelected,
                input.textInput,
                input.memo
            ))
            .do(onNext: { [weak self] _ in
                self?.isLoading.accept(true)
            })
            .flatMapLatest { [weak self] type, photo, text, memo -> Observable<MissionVerification> in
                guard let self = self else { return .empty() }

                // Validate
                let validationError = self.validate(type: type, photo: photo, text: text)
                if let error = validationError {
                    self.validationErrorRelay.accept(error)
                    self.isLoading.accept(false)
                    return .empty()
                }

                // Prepare content
                let content: String
                if type == .photo, let photo = photo {
                    content = self.savePhoto(photo)
                } else {
                    content = text.trimmingCharacters(in: .whitespacesAndNewlines)
                }

                let request = MissionVerificationRequest(
                    missionId: self.mission.id,
                    type: type,
                    content: content,
                    memo: memo
                )

                return self.repository.submitVerification(request)
                    .asObservable()
                    .do(onNext: { [weak self] _ in
                        self?.isLoading.accept(false)
                        self?.debugSuccess("Verification submitted successfully")
                    }, onError: { [weak self] error in
                        self?.isLoading.accept(false)
                        self?.debugError("Verification submission failed", error: error)
                        self?.validationErrorRelay.accept("인증 제출에 실패했어요")
                    })
            }
            .bind(to: verificationSubmittedRelay)
            .disposed(by: disposeBag)

        return Output(
            missionInfo: missionInfo,
            isPhotoMode: isPhotoMode,
            isSubmitEnabled: isSubmitEnabled,
            characterCount: characterCount,
            verificationSubmitted: verificationSubmittedRelay.asDriver(onErrorDriveWith: .empty()),
            validationError: validationErrorRelay.asDriver(onErrorJustReturn: nil),
            isLoading: isLoading.asDriver()
        )
    }

    private func validate(type: VerificationType, photo: UIImage?, text: String) -> String? {
        switch type {
        case .photo:
            if photo == nil {
                return "사진을 선택해주세요"
            }
            // Check image size (5MB limit)
            if let imageData = photo?.jpegData(compressionQuality: 0.8),
               imageData.count > 5 * 1024 * 1024 {
                return "이미지 크기가 너무 커요 (5MB 이하)"
            }
        case .text:
            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.count < 10 {
                return "최소 10자 이상 입력해주세요"
            }
            if trimmed.count > 500 {
                return "500자를 초과할 수 없어요"
            }
        case .parentCheck:
            return "부모님 확인은 아직 지원되지 않아요"
        }
        return nil
    }

    private func savePhoto(_ image: UIImage) -> String {
        // Phase 1: Save to local Documents directory
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            return ""
        }

        let timestamp = Int(Date().timeIntervalSince1970)
        let filename = "verification_\(timestamp).jpg"

        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsPath.appendingPathComponent(filename)

        do {
            try data.write(to: fileURL)
            debugSuccess("Photo saved: \(filename)")
            return fileURL.path
        } catch {
            debugError("Failed to save photo", error: error)
            return ""
        }
    }
}
