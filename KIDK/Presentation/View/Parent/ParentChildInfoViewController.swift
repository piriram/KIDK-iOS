//
//  ParentChildInfoViewController.swift
//  KIDK
//
//  Created by Claude on 11/21/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

/// Phase 1: 간단한 아이 정보 표시 뷰
/// Phase 2: 상세 정보 및 설정 기능 추가
final class ParentChildInfoViewController: BaseViewController {

    private let authRepository: AuthRepositoryProtocol

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()

    private let contentView = UIView()

    // MARK: - Profile Section

    private let profileCard: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#2C2C2E")
        view.layer.cornerRadius = CornerRadius.large
        return view
    }()

    private let profileImageView = ProfileImageView(
        assetName: "kidk_profile_one",
        size: 80,
        bgColor: .white,
        iconRatio: 0.7
    )

    private let childNameLabel: UILabel = {
        let label = UILabel()
        label.text = "김시아"
        label.font = .kidkFont(.s24, .bold)
        label.textColor = .kidkTextWhite
        return label
    }()

    private let levelBadge: UILabel = {
        let label = UILabel()
        label.text = "Lv. 5"
        label.font = .kidkFont(.s16, .bold)
        label.textColor = .white
        label.backgroundColor = .kidkPink
        label.textAlignment = .center
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        return label
    }()

    // MARK: - Info Section

    private let infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Spacing.sm
        return stackView
    }()

    // MARK: - Logout Button

    private lazy var logoutButton = KIDKButton(
        title: "로그아웃",
        backgroundColor: .systemRed,
        titleColor: .white,
        font: .kidkFont(.s16, .bold)
    )

    // MARK: - Initialization

    init(authRepository: AuthRepositoryProtocol = AuthRepository()) {
        self.authRepository = authRepository
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        loadMockData()
        bind()
    }

    private func setupNavigationBar() {
        title = "아이 정보"
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    private func setupUI() {
        view.backgroundColor = .kidkDarkBackground

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(profileCard)
        profileCard.addSubview(profileImageView)
        profileCard.addSubview(childNameLabel)
        profileCard.addSubview(levelBadge)

        contentView.addSubview(infoStackView)
        contentView.addSubview(logoutButton)

        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }

        profileCard.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Spacing.md)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
        }

        profileImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Spacing.lg)
            make.centerX.equalToSuperview()
        }

        childNameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(Spacing.md)
            make.centerX.equalToSuperview()
        }

        levelBadge.snp.makeConstraints { make in
            make.top.equalTo(childNameLabel.snp.bottom).offset(Spacing.sm)
            make.centerX.equalToSuperview()
            make.width.equalTo(60)
            make.height.equalTo(24)
            make.bottom.equalToSuperview().offset(-Spacing.lg)
        }

        infoStackView.snp.makeConstraints { make in
            make.top.equalTo(profileCard.snp.bottom).offset(Spacing.lg)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
        }

        logoutButton.snp.makeConstraints { make in
            make.top.equalTo(infoStackView.snp.bottom).offset(Spacing.xl)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
            make.height.equalTo(56)
            make.bottom.equalToSuperview().offset(-Spacing.xl)
        }
    }

    private func bind() {
        logoutButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.handleLogout()
            })
            .disposed(by: disposeBag)
    }

    private func handleLogout() {
        let alert = UIAlertController(
            title: "로그아웃",
            message: "정말 로그아웃하시겠습니까?",
            preferredStyle: .alert
        )

        let confirmAction = UIAlertAction(title: "로그아웃", style: .destructive) { [weak self] _ in
            self?.performLogout()
        }

        let cancelAction = UIAlertAction(title: "취소", style: .cancel)

        alert.addAction(confirmAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }

    private func performLogout() {
        // Clear auto-login preference
        authRepository.saveAutoLoginPreference(false)
        authRepository.saveLoginCredentials(email: "")

        // Post logout notification
        NotificationCenter.default.post(name: .userLoggedOut, object: nil)

        debugSuccess("User logged out successfully")
    }

    private func loadMockData() {
        let infoItems = [
            ("생년월일", "2015년 6월 7일"),
            ("나이", "9세"),
            ("학교", "키득초등학교 3학년"),
            ("이메일", "judy@love.net"),
            ("가입일", "2025년 1월 15일"),
            ("일일 지출 한도", "10,000원"),
            ("이번 달 지출", "45,000원"),
            ("총 미션 완료", "24개")
        ]

        for (title, value) in infoItems {
            let infoView = createInfoRow(title: title, value: value)
            infoStackView.addArrangedSubview(infoView)
        }
    }

    private func createInfoRow(title: String, value: String) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = UIColor(hex: "#2C2C2E")
        containerView.layer.cornerRadius = CornerRadius.medium

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .kidkFont(.s14, .regular)
        titleLabel.textColor = .kidkGray

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .kidkFont(.s16, .medium)
        valueLabel.textColor = .kidkTextWhite
        valueLabel.textAlignment = .right

        containerView.addSubview(titleLabel)
        containerView.addSubview(valueLabel)

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Spacing.md)
            make.centerY.equalToSuperview()
        }

        valueLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-Spacing.md)
            make.leading.equalTo(titleLabel.snp.trailing).offset(Spacing.sm)
            make.centerY.equalToSuperview()
        }

        containerView.snp.makeConstraints { make in
            make.height.equalTo(56)
        }

        return containerView
    }
}
