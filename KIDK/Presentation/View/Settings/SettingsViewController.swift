import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class SettingsViewController: BaseViewController {
    
    private let authRepository: AuthRepositoryProtocol
    weak var coordinator: SettingsCoordinator?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(
            text: "설정",
            size: .s24,
            weight: .bold,
            color: .kidkTextWhite
        )
        return label
    }()
    
    // 🔧 개발용 - 가족 생성 버튼
    private lazy var createFamilyButton = KIDKButton(
        title: "🏠 가족 생성 (부모용)",
        backgroundColor: .kidkBlue,
        titleColor: .kidkTextWhite,
        font: .kidkFont(.s14, .medium)
    )

    // 🔧 개발용 - 가족 가입 버튼
    private lazy var joinFamilyButton = KIDKButton(
        title: "👶 가족 가입 (자녀용)",
        backgroundColor: .kidkGreen,
        titleColor: .kidkTextWhite,
        font: .kidkFont(.s14, .medium)
    )

    private lazy var logoutButton = KIDKButton(
        title: "로그아웃",
        backgroundColor: .kidkPink,
        titleColor: .kidkTextWhite,
        font: .kidkFont(.s16, .bold)
    )

    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
    }
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(logoutButton)

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Spacing.lg)
            make.leading.trailing.equalToSuperview().inset(Spacing.lg)
        }

        // 🔧 개발용 버튼은 DEV 빌드에서만 표시
        if AppConfiguration.showDeveloperMenu {
            view.addSubview(createFamilyButton)
            view.addSubview(joinFamilyButton)

            createFamilyButton.snp.makeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(Spacing.xl)
                make.leading.trailing.equalToSuperview().inset(Spacing.lg)
                make.height.equalTo(48)
            }

            joinFamilyButton.snp.makeConstraints { make in
                make.top.equalTo(createFamilyButton.snp.bottom).offset(Spacing.md)
                make.leading.trailing.equalToSuperview().inset(Spacing.lg)
                make.height.equalTo(48)
            }
        }

        logoutButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-Spacing.lg)
            make.leading.trailing.equalToSuperview().inset(Spacing.lg)
            make.height.equalTo(56)
        }
    }
    
    private func bind() {
        // 🔧 개발용 - 가족 생성 버튼
        createFamilyButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.handleCreateFamily()
            })
            .disposed(by: disposeBag)

        // 🔧 개발용 - 가족 가입 버튼
        joinFamilyButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.handleJoinFamily()
            })
            .disposed(by: disposeBag)

        logoutButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.showLogoutConfirmation()
            })
            .disposed(by: disposeBag)
    }
    
    private func showLogoutConfirmation() {
        let alert = UIAlertController(
            title: "로그아웃",
            message: "정말 로그아웃 하시겠습니까?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "로그아웃", style: .destructive) { [weak self] _ in
            self?.performLogout()
        })
        
        present(alert, animated: true)
    }
    
    private func performLogout() {
        showLoading()

        authRepository.logout()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] result in
                self?.hideLoading()

                switch result {
                case .success:
                    self?.debugSuccess("Logout successful")
                    self?.coordinator?.logout()

                case .failure(let error):
                    self?.debugError("Logout API failed", error: error)
                    // API 실패해도 로컬 세션은 정리되었으므로 로그아웃 처리
                    self?.coordinator?.logout()
                }
            }, onError: { [weak self] error in
                self?.hideLoading()
                self?.debugError("Logout failed", error: error)
                // 에러 발생 시에도 로그아웃 처리 (로컬 세션은 정리됨)
                self?.coordinator?.logout()
            })
            .disposed(by: disposeBag)
    }

    // MARK: - 🔧 개발용 - 가족 매칭 헬퍼

    private func handleCreateFamily() {
        showLoading()

        Task {
            guard let user = await UserProfileManager.shared.getCurrentUser() else {
                await MainActor.run {
                    self.hideLoading()
                    self.showError(message: "사용자 정보를 불러올 수 없습니다.")
                }
                return
            }

            let familyName = "\(user.name)의 가족"
            let request = FamilyCreationRequest(
                familyName: familyName,
                creatorId: user.id,
                creatorRole: .parent
            )

            FamilyRepository.shared.createFamily(request)
                .observe(on: MainScheduler.instance)
                .subscribe(onSuccess: { [weak self] family in
                    self?.hideLoading()
                    self?.showInviteCode(family.inviteCode)
                }, onFailure: { [weak self] error in
                    self?.hideLoading()
                    self?.debugError("가족 생성 실패", error: error)

                    let alert = UIAlertController(
                        title: "⚠️ 가족 생성 실패",
                        message: "현재 백엔드 서버에서 500 에러가 발생하고 있습니다.\n\n백엔드 개발자에게 Family API 수정을 요청해주세요.\n\n기술 정보:\n- API: POST /api/v1/families\n- Error: Server 500",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "확인", style: .default))
                    self?.present(alert, animated: true)
                })
                .disposed(by: self.disposeBag)
        }
    }

    private func handleJoinFamily() {
        let alert = UIAlertController(
            title: "가족 가입",
            message: "초대 코드를 입력하세요",
            preferredStyle: .alert
        )

        alert.addTextField { textField in
            textField.placeholder = "초대 코드"
            textField.autocapitalizationType = .allCharacters
        }

        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "가입", style: .default) { [weak self] _ in
            guard let inviteCode = alert.textFields?.first?.text, !inviteCode.isEmpty else {
                self?.showError(message: "초대 코드를 입력하세요.")
                return
            }
            self?.joinFamilyWithCode(inviteCode)
        })

        present(alert, animated: true)
    }

    private func joinFamilyWithCode(_ inviteCode: String) {
        showLoading()

        Task {
            guard let user = await UserProfileManager.shared.getCurrentUser() else {
                await MainActor.run {
                    self.hideLoading()
                    self.showError(message: "사용자 정보를 불러올 수 없습니다.")
                }
                return
            }

            let request = FamilyJoinRequest(
                userId: user.id,
                inviteCode: inviteCode,
                role: .child
            )

            FamilyRepository.shared.joinFamily(request)
                .observe(on: MainScheduler.instance)
                .subscribe(onSuccess: { [weak self] family in
                    self?.hideLoading()
                    self?.showFamilyJoinSuccess(familyName: family.familyName)
                }, onFailure: { [weak self] error in
                    self?.hideLoading()
                    self?.debugError("가족 가입 실패", error: error)

                    let alert = UIAlertController(
                        title: "⚠️ 가족 가입 실패",
                        message: "초대 코드가 유효하지 않거나 백엔드 서버 오류가 발생했습니다.\n\n초대 코드를 확인하거나 백엔드 개발자에게 문의해주세요.\n\n기술 정보:\n- API: POST /api/v1/families/join\n- 입력한 코드: \(inviteCode)",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "확인", style: .default))
                    self?.present(alert, animated: true)
                })
                .disposed(by: self.disposeBag)
        }
    }

    private func showInviteCode(_ inviteCode: String) {
        let alert = UIAlertController(
            title: "🎉 가족 생성 완료!",
            message: "초대 코드를 자녀에게 공유하세요:\n\n\(inviteCode)",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "복사", style: .default) { [weak self] _ in
            UIPasteboard.general.string = inviteCode

            let successAlert = UIAlertController(
                title: "복사 완료",
                message: "초대 코드가 클립보드에 복사되었습니다.",
                preferredStyle: .alert
            )
            successAlert.addAction(UIAlertAction(title: "확인", style: .default))
            self?.present(successAlert, animated: true)
        })

        alert.addAction(UIAlertAction(title: "확인", style: .cancel))

        present(alert, animated: true)
    }

    private func showFamilyJoinSuccess(familyName: String) {
        let alert = UIAlertController(
            title: "🎉 가족 가입 완료!",
            message: "\"\(familyName)\"에 가입되었습니다.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "확인", style: .default))

        present(alert, animated: true)
    }
}
