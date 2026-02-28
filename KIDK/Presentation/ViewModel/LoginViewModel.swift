import Foundation
import RxSwift
import RxCocoa

final class LoginViewModel: BaseViewModel {
    
    struct Input {
        let emailText: Observable<String>
        let passwordText: Observable<String>
        let autoLoginToggled: Observable<Bool>
        let userTypeSelected: Observable<UserType>
        let loginButtonTapped: Observable<Void>
        let signupButtonTapped: Observable<Void>
    }
    
    struct Output {
        let isLoginEnabled: Driver<Bool>
        let isLoading: Driver<Bool>
        let savedEmail: Driver<String>
        let isAutoLoginEnabled: Driver<Bool>
    }
    
    let loginSuccess = PublishSubject<User>()
    let navigateToSignup = PublishSubject<Void>()
    
    private let authRepository: AuthRepositoryProtocol
    private let autoLoginEnabled = BehaviorRelay<Bool>(value: false)
    
    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
        super.init()
        
        autoLoginEnabled.accept(authRepository.isAutoLoginEnabled())
    }
    
    func transform(input: Input) -> Output {
        let credentials = Observable.combineLatest(
            input.emailText,
            input.passwordText,
            input.userTypeSelected
        )
        
        let isLoginEnabled = credentials
            .map { email, password, _ in
                !email.isEmpty && !password.isEmpty && email.contains("@")
            }
        
        input.autoLoginToggled
            .subscribe(onNext: { [weak self] isEnabled in
                self?.autoLoginEnabled.accept(isEnabled)
                self?.authRepository.saveAutoLoginPreference(isEnabled)
                self?.debugLog("Auto-login toggled: \(isEnabled)")
            })
            .disposed(by: disposeBag)
        
        input.loginButtonTapped
            .withLatestFrom(credentials)
            .do(onNext: { [weak self] email, password, userType in
                self?.startLoading()
                self?.debugLog("Login attempt with email: \(email), userType: \(userType)")
            })
            .flatMapLatest { [weak self] email, password, userType -> Observable<User> in
                guard let self = self else { return .empty() }
                // Mock 로그인 (개발용)
                return self.mockLogin(email: email, password: password, userType: userType)
            }
            .do(onNext: { [weak self] user in
                self?.stopLoading()
                self?.debugSuccess("Login successful")
                
                if let isAutoLogin = self?.autoLoginEnabled.value, isAutoLogin {
                    self?.authRepository.saveLoginCredentials(email: user.name)
                }
            }, onError: { [weak self] error in
                self?.handleError(error)
            })
            .subscribe(onNext: { [weak self] user in
                self?.loginSuccess.onNext(user)
            })
            .disposed(by: disposeBag)
        
        input.signupButtonTapped
            .subscribe(onNext: { [weak self] in
                self?.debugLog("Navigate to signup")
                self?.navigateToSignup.onNext(())
            })
            .disposed(by: disposeBag)
        
        let savedEmail = Observable.just(authRepository.getLastLoginEmail() ?? "")
        
        return Output(
            isLoginEnabled: isLoginEnabled.asDriver(onErrorJustReturn: false),
            isLoading: isLoading.asDriver(),
            savedEmail: savedEmail.asDriver(onErrorJustReturn: ""),
            isAutoLoginEnabled: autoLoginEnabled.asDriver()
        )
    }
    
    // MARK: - Real Login (Backend Only)

    private func realLogin(email: String, password: String, userType: UserType) -> Observable<User> {
        debugLog("Starting backend-only login flow")
        debugLog("Login input received (email: \(email), userType: \(userType))")
        _ = password

        return authRepository.devLogin()
            .flatMap { result -> Observable<User> in
                switch result {
                case .success(let user):
                    return .just(user)
                case .failure(let error):
                    return .error(error)
                }
            }
            .do(onNext: { [weak self] user in
                self?.authRepository.setFirstLaunchComplete()
                self?.debugSuccess("Backend login success with userId: \(user.id)")

                Task {
                    await UserProfileManager.shared.saveProfile(user)
                }
            })
    }

    // MARK: - Mock Login (개발용)

    private func mockLogin(email: String, password: String, userType: UserType) -> Observable<User> {
        return Observable.create { [weak self] observer in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                guard let self = self else {
                    observer.onError(NSError(domain: "LoginViewModel", code: -1))
                    return
                }

                let firebaseUID = "mock_\(UUID().uuidString)"
                let user = User(
                    id: UUID().uuidString,
                    firebaseUID: firebaseUID,
                    userType: userType,
                    name: email.components(separatedBy: "@").first ?? "User",
                    status: .active
                )

                // Mock 토큰 저장 (백엔드 준비되면 실제 토큰으로 대체)
                let mockAccessToken = "mock_access_token_\(UUID().uuidString)"
                let mockRefreshToken = "mock_refresh_token_\(UUID().uuidString)"
                TokenManager.shared.saveAccessToken(mockAccessToken)
                TokenManager.shared.saveRefreshToken(mockRefreshToken)

                self.authRepository.setFirstLaunchComplete()
                self.debugSuccess("Mock login successful with mock tokens")

                // UserProfileManager에 사용자 정보 저장
                Task {
                    await UserProfileManager.shared.saveProfile(user)
                }

                observer.onNext(user)
                observer.onCompleted()
            }

            return Disposables.create()
        }
    }
}
