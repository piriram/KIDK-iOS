import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class ParentChildInfoViewController: BaseViewController {

    // MARK: - Properties

    private let viewModel: ParentChildInfoViewModel
    private let authRepository: AuthRepositoryProtocol

    // MARK: - UI Components

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()

    private let contentView = UIView()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Spacing.lg
        return stackView
    }()

    private let childInfoHeaderView = ChildInfoHeaderView()
    private let monthlyStatsSummaryView = MonthlyStatsSummaryView()

    private let missionsSectionHeader = SectionHeaderView()
    private let missionCompletionBadge = MissionCompletionBadge()

    private let missionsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Spacing.sm
        return stackView
    }()

    private lazy var logoutButton = KIDKButton(
        title: "로그아웃",
        backgroundColor: .systemRed,
        titleColor: .white,
        font: .kidkFont(.s16, .bold)
    )

    // MARK: - Initialization

    init(viewModel: ParentChildInfoViewModel, authRepository: AuthRepositoryProtocol = AuthRepository()) {
        self.viewModel = viewModel
        self.authRepository = authRepository
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        bindViewModel()
    }

    // MARK: - Setup

    private func setupNavigationBar() {
        title = "아이 정보"
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)

        // Add views to stack
        stackView.addArrangedSubview(childInfoHeaderView)
        stackView.addArrangedSubview(monthlyStatsSummaryView)
        stackView.addArrangedSubview(missionsSectionHeader)
        stackView.addArrangedSubview(missionCompletionBadge)
        stackView.addArrangedSubview(missionsStackView)
        stackView.addArrangedSubview(logoutButton)

        // Configure section header
        missionsSectionHeader.configure(title: "✨ 완료한 미션")

        // Layout
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }

        stackView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(Spacing.md)
            make.bottom.equalToSuperview().offset(-Spacing.xl)
        }

        logoutButton.snp.makeConstraints { make in
            make.height.equalTo(56)
        }
    }

    // MARK: - Binding

    private func bindViewModel() {
        let input = ParentChildInfoViewModel.Input(
            viewDidLoad: Observable.just(())
        )

        let output = viewModel.transform(input: input)

        // Child Info
        output.childInfo
            .drive(onNext: { [weak self] childInfo in
                self?.updateChildInfo(childInfo)
            })
            .disposed(by: disposeBag)

        // Monthly Stats
        output.monthlyStats
            .drive(onNext: { [weak self] stats in
                self?.updateMonthlyStats(stats)
            })
            .disposed(by: disposeBag)

        // Completed Missions
        output.completedMissions
            .drive(onNext: { [weak self] missions in
                self?.updateCompletedMissions(missions)
            })
            .disposed(by: disposeBag)

        // Loading
        output.isLoading
            .drive(onNext: { [weak self] isLoading in
                if isLoading {
                    self?.showLoading()
                } else {
                    self?.hideLoading()
                }
            })
            .disposed(by: disposeBag)

        // Error
        output.error
            .drive(onNext: { [weak self] error in
                self?.showError(message: error.localizedDescription)
            })
            .disposed(by: disposeBag)

        // Logout Button
        logoutButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.handleLogout()
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Update Methods

    private func updateChildInfo(_ childInfo: ChildInfo) {
        childInfoHeaderView.configure(
            name: childInfo.user.name,
            level: childInfo.level,
            points: childInfo.points,
            profileImageURL: childInfo.user.profileImageURL
        )
    }

    private func updateMonthlyStats(_ stats: MonthlyStats) {
        monthlyStatsSummaryView.configure(
            totalSpending: stats.totalSpending,
            totalSavings: stats.totalSavings,
            dailyLimit: stats.dailyLimit,
            usagePercentage: stats.usagePercentage
        )
    }

    private func updateCompletedMissions(_ missions: [Mission]) {
        missionCompletionBadge.configure(completedCount: missions.count)

        // Clear existing mission views
        missionsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Add mission rows
        for mission in missions.prefix(5) { // 최대 5개만 표시
            let missionRow = createMissionRow(mission: mission)
            missionsStackView.addArrangedSubview(missionRow)
        }

        // Show empty state if no missions
        if missions.isEmpty {
            let emptyLabel = UILabel()
            emptyLabel.text = "완료한 미션이 없습니다"
            emptyLabel.font = .kidkFont(.s14, .regular)
            emptyLabel.textColor = .kidkGray
            emptyLabel.textAlignment = .center
            missionsStackView.addArrangedSubview(emptyLabel)

            emptyLabel.snp.makeConstraints { make in
                make.height.equalTo(60)
            }
        }
    }

    private func createMissionRow(mission: Mission) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .cardBackground
        containerView.layer.cornerRadius = CornerRadius.medium

        let titleLabel = UILabel()
        titleLabel.text = mission.title
        titleLabel.font = .kidkFont(.s16, .bold)
        titleLabel.textColor = .kidkTextWhite

        let statusLabel = UILabel()
        statusLabel.text = "✅ 완료"
        statusLabel.font = .kidkFont(.s12, .medium)
        statusLabel.textColor = .kidkGreen

        let rewardLabel = UILabel()
        rewardLabel.text = "보상: \(mission.rewardAmount.formattedCurrency)"
        rewardLabel.font = .kidkFont(.s14, .medium)
        rewardLabel.textColor = .kidkGray

        containerView.addSubview(titleLabel)
        containerView.addSubview(statusLabel)
        containerView.addSubview(rewardLabel)

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Spacing.md)
            make.top.equalToSuperview().offset(Spacing.sm)
            make.trailing.lessThanOrEqualTo(statusLabel.snp.leading).offset(-Spacing.xs)
        }

        statusLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-Spacing.md)
            make.centerY.equalTo(titleLabel)
        }

        rewardLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Spacing.md)
            make.top.equalTo(titleLabel.snp.bottom).offset(Spacing.xxs)
            make.trailing.equalToSuperview().offset(-Spacing.md)
            make.bottom.equalToSuperview().offset(-Spacing.sm)
        }

        containerView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(70)
        }

        return containerView
    }

    // MARK: - Actions

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
}
