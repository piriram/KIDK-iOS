//
//  ProfileViewModel.swift
//  KIDK
//
//  Created by KIDK on 12/02/24.
//

import Foundation
import RxSwift
import RxCocoa

final class ProfileViewModel: BaseViewModel {

    struct Input {
        let viewDidLoad: Observable<Void>
        let nameText: Observable<String>
        let birthdateText: Observable<String?>
        let phoneText: Observable<String?>
        let profileImageSelected: Observable<Data?>
        let saveButtonTapped: Observable<Void>
    }

    struct Output {
        let userProfile: Driver<User>
        let isLoading: Driver<Bool>
        let isSaveEnabled: Driver<Bool>
        let profileImageURL: Driver<String?>
    }

    let profileUpdated = PublishSubject<User>()

    private let networkService: NetworkService

    init(networkService: NetworkService = .shared) {
        self.networkService = networkService
        super.init()
    }

    func transform(input: Input) -> Output {
        let userProfile = BehaviorRelay<User?>(value: nil)
        let profileImageURL = BehaviorRelay<String?>(value: nil)

        // 1. 화면 로드 시 프로필 조회
        input.viewDidLoad
            .do(onNext: { [weak self] in
                self?.startLoading()
            })
            .flatMapLatest { [weak self] _ -> Observable<Result<ApiResponseUserResponse, NetworkError>> in
                guard let self = self else { return .empty() }
                return self.networkService.request(UserAPI.getMyProfile)
            }
            .do(onNext: { [weak self] _ in
                self?.stopLoading()
            })
            .subscribe(onNext: { [weak self] result in
                switch result {
                case .success(let response):
                    if let userData = response.data {
                        let user = userData.toDomain()
                        userProfile.accept(user)
                        profileImageURL.accept(user.profileImageURL)
                        self?.debugSuccess("Profile loaded successfully")

                        // UserProfileManager에도 저장
                        Task {
                            await UserProfileManager.shared.saveProfile(user)
                        }
                    }
                case .failure(let error):
                    self?.handleError(error)
                }
            })
            .disposed(by: disposeBag)

        // 2. 프로필 이미지 업로드
        input.profileImageSelected
            .compactMap { $0 }
            .do(onNext: { [weak self] _ in
                self?.startLoading()
                self?.debugLog("Uploading profile image...")
            })
            .flatMapLatest { [weak self] imageData -> Observable<Result<ApiResponseString, NetworkError>> in
                guard let self = self else { return .empty() }
                // TODO: 이미지 업로드 API 구현 필요 (multipart/form-data)
                // 현재는 단순 예시로 처리
                return .just(.failure(.unknown(nil)))
            }
            .subscribe(onNext: { [weak self] result in
                self?.stopLoading()
                switch result {
                case .success(let response):
                    if let imageUrl = response.data {
                        profileImageURL.accept(imageUrl)
                        self?.debugSuccess("Profile image uploaded: \(imageUrl)")

                        // UserProfileManager 업데이트
                        Task {
                            await UserProfileManager.shared.updateProfileImage(imageUrl)
                        }
                    }
                case .failure(let error):
                    self?.debugError("Image upload failed", error: error)
                }
            })
            .disposed(by: disposeBag)

        // 3. 입력 값 검증
        let isSaveEnabled = Observable.combineLatest(
            input.nameText,
            userProfile.compactMap { $0 }
        )
        .map { name, _ in
            return !name.isEmpty && name.count >= 1 && name.count <= 100
        }

        // 4. 저장 버튼 탭
        input.saveButtonTapped
            .withLatestFrom(Observable.combineLatest(
                input.nameText,
                input.birthdateText,
                input.phoneText
            ))
            .do(onNext: { [weak self] _ in
                self?.startLoading()
                self?.debugLog("Updating profile...")
            })
            .flatMapLatest { [weak self] name, birthdate, phone -> Observable<Result<ApiResponseUserResponse, NetworkError>> in
                guard let self = self else { return .empty() }

                // birthdate를 Date -> String 변환 (YYYY-MM-DD)
                let birthdateString = birthdate

                return self.networkService.request(
                    UserAPI.updateProfile(
                        name: name,
                        birthDate: birthdateString,
                        phone: phone
                    )
                )
            }
            .subscribe(onNext: { [weak self] result in
                self?.stopLoading()
                switch result {
                case .success(let response):
                    if let userData = response.data {
                        let updatedUser = userData.toDomain()
                        userProfile.accept(updatedUser)
                        self?.profileUpdated.onNext(updatedUser)
                        self?.debugSuccess("Profile updated successfully")

                        // UserProfileManager 업데이트
                        Task {
                            await UserProfileManager.shared.saveProfile(updatedUser)
                        }
                    }
                case .failure(let error):
                    self?.handleError(error)
                }
            })
            .disposed(by: disposeBag)

        return Output(
            userProfile: userProfile.compactMap { $0 }.asDriver(onErrorJustReturn: User(
                id: "",
                firebaseUID: "",
                userType: .child,
                name: "",
                status: .active
            )),
            isLoading: isLoading.asDriver(),
            isSaveEnabled: isSaveEnabled.asDriver(onErrorJustReturn: false),
            profileImageURL: profileImageURL.asDriver()
        )
    }
}
