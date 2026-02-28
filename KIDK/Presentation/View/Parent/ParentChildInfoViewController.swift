import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class ParentChildInfoViewController: BaseViewController, NavigationChromeConfigurable {

    // MARK: - Properties

    private let viewModel: ParentChildInfoViewModel
    private let authRepository: AuthRepositoryProtocol
    private let navigationHeaderView = KIDKNavigationHeaderView(title: "아이 정보")

    private var latestChildInfo: ChildInfo?
    private var latestMonthlyStats: MonthlyStats?
    private var latestCompletedMissions: [Mission] = []

    // MARK: - UI Components

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()

    private let contentView = UIView()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Spacing.md
        return stackView
    }()

    private let monthlyGrowthSummaryView = MonthlyGrowthSummaryView()
    private let childInfoHeaderView = ChildInfoHeaderView()

    private let statsSectionHeader = ParentTimelineSectionHeaderView()

    private let statsCardsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = Spacing.xs
        stackView.distribution = .fillEqually
        return stackView
    }()

    private let spendingStatCard = TimelineStatCardView(
        title: "이번 달 지출",
        icon: "creditcard.fill",
        accentColor: .kidkPink
    )

    private let savingsStatCard = TimelineStatCardView(
        title: "이번 달 저축",
        icon: "banknote.fill",
        accentColor: .kidkGreen
    )

    private let usageStatCard = TimelineStatCardView(
        title: "한도 사용률",
        icon: "gauge.with.needle",
        accentColor: .kidkPinkLight
    )

    private let timelineSectionHeader = ParentTimelineSectionHeaderView()
    private let timelineCardView = ParentTimelineCardView(accentColor: .kidkPink)

    private let timelineGuideLabel: UILabel = {
        let label = UILabel()
        label.text = "완료된 미션을 최신 순으로 최대 7개까지 보여드려요"
        label.font = UIFont.kidkFont(.s12, .regular)
        label.textColor = .kidkGray
        return label
    }()

    private let timelineStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Spacing.sm
        return stackView
    }()

    private let actionBarView: UIView = {
        let view = UIView()
        view.backgroundColor = .cardBackground
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.kidkTextWhite.withAlphaComponent(0.06).cgColor
        return view
    }()

    private let accountActionTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "계정 관리"
        label.font = UIFont.kidkFont(.s16, .bold)
        label.textColor = .kidkTextWhite
        return label
    }()

    private let accountActionDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "다른 기기에서 로그인하려면 로그아웃 후 다시 로그인해 주세요"
        label.font = UIFont.kidkFont(.s14, .regular)
        label.textColor = .kidkGray
        label.numberOfLines = 2
        return label
    }()

    private lazy var logoutButton = KIDKButton(
        title: "로그아웃",
        backgroundColor: .systemRed,
        titleColor: .white,
        font: UIFont.kidkFont(.s16, .bold)
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

    var prefersNavigationBarHidden: Bool { true }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.verticalScrollIndicatorInsets.bottom = actionBarView.bounds.height
        updateLayoutForCompactWidthIfNeeded()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .kidkDarkBackground

        view.addSubview(navigationHeaderView)
        view.addSubview(scrollView)
        view.addSubview(actionBarView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)

        statsCardsStackView.addArrangedSubview(spendingStatCard)
        statsCardsStackView.addArrangedSubview(savingsStatCard)
        statsCardsStackView.addArrangedSubview(usageStatCard)

        timelineCardView.contentView.addSubview(timelineGuideLabel)
        timelineCardView.contentView.addSubview(timelineStackView)

        actionBarView.addSubview(accountActionTitleLabel)
        actionBarView.addSubview(accountActionDescriptionLabel)
        actionBarView.addSubview(logoutButton)

        stackView.addArrangedSubview(monthlyGrowthSummaryView)
        stackView.addArrangedSubview(childInfoHeaderView)
        stackView.addArrangedSubview(statsSectionHeader)
        stackView.addArrangedSubview(statsCardsStackView)
        stackView.addArrangedSubview(timelineSectionHeader)
        stackView.addArrangedSubview(timelineCardView)

        stackView.setCustomSpacing(Spacing.sm, after: statsSectionHeader)
        stackView.setCustomSpacing(Spacing.sm, after: timelineSectionHeader)

        statsSectionHeader.configure(
            step: "STEP 4",
            title: "성장 지표 요약",
            subtitle: "핵심 수치를 한눈에 보고 현재 상태를 빠르게 파악해요"
        )

        timelineSectionHeader.configure(
            step: "STEP 5",
            title: "완료 미션 타임라인",
            subtitle: "날짜 · 상태 · 보상 흐름으로 최근 성과를 읽어보세요"
        )

        navigationHeaderView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(KIDKNavigationHeaderView.height)
        }

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(navigationHeaderView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(actionBarView.snp.top)
        }

        actionBarView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }

        stackView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(Spacing.md)
            make.bottom.equalToSuperview().offset(-Spacing.md)
        }

        statsCardsStackView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(116)
        }

        timelineGuideLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        timelineStackView.snp.makeConstraints { make in
            make.top.equalTo(timelineGuideLabel.snp.bottom).offset(Spacing.sm)
            make.leading.trailing.bottom.equalToSuperview()
        }

        accountActionTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Spacing.sm)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
        }

        accountActionDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(accountActionTitleLabel.snp.bottom).offset(Spacing.xxs)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
        }

        logoutButton.snp.makeConstraints { make in
            make.top.equalTo(accountActionDescriptionLabel.snp.bottom).offset(Spacing.sm)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
            make.bottom.equalTo(actionBarView.safeAreaLayoutGuide).offset(-Spacing.sm)
            make.height.greaterThanOrEqualTo(50)
        }
    }

    private func updateLayoutForCompactWidthIfNeeded() {
        let isCompact = view.bounds.width <= 360
        statsCardsStackView.axis = isCompact ? .vertical : .horizontal
        childInfoHeaderView.setCompactLayout(isCompact)
        monthlyGrowthSummaryView.setCompactLayout(isCompact)
        timelineGuideLabel.numberOfLines = isCompact ? 0 : 1
    }

    // MARK: - Binding

    private func bindViewModel() {
        let input = ParentChildInfoViewModel.Input(
            viewDidLoad: Observable.just(())
        )

        let output = viewModel.transform(input: input)

        output.childInfo
            .drive(onNext: { [weak self] childInfo in
                self?.updateChildInfo(childInfo)
            })
            .disposed(by: disposeBag)

        output.monthlyStats
            .drive(onNext: { [weak self] stats in
                self?.updateMonthlyStats(stats)
            })
            .disposed(by: disposeBag)

        output.completedMissions
            .drive(onNext: { [weak self] missions in
                self?.updateCompletedMissions(missions)
            })
            .disposed(by: disposeBag)

        output.isLoading
            .drive(onNext: { [weak self] isLoading in
                if isLoading {
                    self?.showLoading()
                } else {
                    self?.hideLoading()
                }
            })
            .disposed(by: disposeBag)

        output.error
            .drive(onNext: { [weak self] error in
                self?.showError(message: error.localizedDescription)
            })
            .disposed(by: disposeBag)

        logoutButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.handleLogout()
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Update Methods

    private func updateChildInfo(_ childInfo: ChildInfo) {
        latestChildInfo = childInfo

        childInfoHeaderView.configure(
            name: childInfo.user.name,
            level: childInfo.level,
            points: childInfo.points,
            profileImageURL: childInfo.user.profileImageURL
        )

        refreshMonthlyGrowthSummary()
    }

    private func updateMonthlyStats(_ stats: MonthlyStats) {
        latestMonthlyStats = stats

        let percentage = max(0, min(Int((stats.usagePercentage * 100).rounded()), 100))

        spendingStatCard.configure(
            value: stats.totalSpending.formattedCurrency,
            subtitle: "사용 금액"
        )

        savingsStatCard.configure(
            value: stats.totalSavings.formattedCurrency,
            subtitle: "모은 금액"
        )

        usageStatCard.configure(
            value: "\(percentage)%",
            subtitle: "일일 한도 \(stats.dailyLimit.formattedCurrency)"
        )

        refreshMonthlyGrowthSummary()
    }

    private func updateCompletedMissions(_ missions: [Mission]) {
        latestCompletedMissions = missions

        timelineStackView.arrangedSubviews.forEach { view in
            timelineStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        let timelineMissions = missions
            .sorted { lhs, rhs in
                let lhsDate = lhs.completedAt ?? lhs.createdAt
                let rhsDate = rhs.completedAt ?? rhs.createdAt
                return lhsDate > rhsDate
            }
            .prefix(7)

        for (index, mission) in timelineMissions.enumerated() {
            let row = createTimelineMissionRow(mission: mission, isLast: index == timelineMissions.count - 1)
            timelineStackView.addArrangedSubview(row)
        }

        if timelineMissions.isEmpty {
            timelineStackView.addArrangedSubview(createEmptyTimelineView())
        }

        refreshMonthlyGrowthSummary()
    }

    private func refreshMonthlyGrowthSummary() {
        guard let childInfo = latestChildInfo else { return }

        let stats = latestMonthlyStats
        let missionCount = latestCompletedMissions.count
        let usagePercent = stats.map { max(0, min(Int(($0.usagePercentage * 100).rounded()), 100)) } ?? 0

        let savingsText = stats?.totalSavings.formattedCurrency ?? "0원"
        let story = "이번 달 \(childInfo.user.name)은(는) 미션 \(missionCount)개를 완료하고, \(savingsText)을 저축했어요. 한도 사용률은 \(usagePercent)%예요."

        monthlyGrowthSummaryView.configure(
            monthText: currentMonthTitle(),
            childName: childInfo.user.name,
            level: childInfo.level,
            points: childInfo.points,
            completedMissionCount: missionCount,
            summaryText: story,
            usagePercent: usagePercent
        )
    }

    private func createTimelineMissionRow(mission: Mission, isLast: Bool) -> UIView {
        let containerView = UIView()

        let dateLabel = UILabel()
        dateLabel.font = UIFont.kidkFont(.s12, .medium)
        dateLabel.textColor = .kidkGray
        dateLabel.text = (mission.completedAt ?? mission.createdAt).formattedShortDate
        dateLabel.textAlignment = .left

        let timelineDot = UIView()
        timelineDot.backgroundColor = .kidkPink
        timelineDot.layer.cornerRadius = 5

        let timelineLine = UIView()
        timelineLine.backgroundColor = .kidkDarkBackground
        timelineLine.isHidden = isLast

        let missionCard = UIView()
        missionCard.backgroundColor = .kidkDarkBackground.withAlphaComponent(0.42)
        missionCard.layer.cornerRadius = CornerRadius.medium

        let titleLabel = UILabel()
        titleLabel.font = UIFont.kidkFont(.s16, .bold)
        titleLabel.textColor = .kidkTextWhite
        titleLabel.numberOfLines = 2
        titleLabel.text = mission.title

        let rewardLabel = UILabel()
        rewardLabel.font = UIFont.kidkFont(.s12, .regular)
        rewardLabel.textColor = .kidkGray
        rewardLabel.text = "보상 \(mission.rewardAmount.formattedCurrency)"

        let statusBadge = ParentTimelineStatusBadgeView()

        if mission.status == .completed {
            statusBadge.configure(text: "완료", tone: .green)
            timelineDot.backgroundColor = .kidkGreen
        } else {
            statusBadge.configure(text: "진행", tone: .pink)
            timelineDot.backgroundColor = .kidkPink
        }

        let textStackView = UIStackView(arrangedSubviews: [titleLabel, rewardLabel])
        textStackView.axis = .vertical
        textStackView.spacing = 4

        containerView.addSubview(dateLabel)
        containerView.addSubview(timelineDot)
        containerView.addSubview(timelineLine)
        containerView.addSubview(missionCard)

        missionCard.addSubview(textStackView)
        missionCard.addSubview(statusBadge)

        dateLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.width.equalTo(70)
        }

        timelineDot.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(Spacing.xxs)
            make.centerX.equalTo(dateLabel)
            make.width.height.equalTo(10)
        }

        timelineLine.snp.makeConstraints { make in
            make.top.equalTo(timelineDot.snp.bottom).offset(2)
            make.centerX.equalTo(timelineDot)
            make.width.equalTo(2)
            make.bottom.equalToSuperview()
        }

        missionCard.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview()
            make.leading.equalTo(dateLabel.snp.trailing).offset(Spacing.xs)
            make.bottom.equalToSuperview()
        }

        statusBadge.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Spacing.sm)
            make.trailing.equalToSuperview().offset(-Spacing.sm)
            make.width.greaterThanOrEqualTo(54)
        }

        textStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Spacing.sm)
            make.leading.equalToSuperview().offset(Spacing.sm)
            make.trailing.lessThanOrEqualTo(statusBadge.snp.leading).offset(-Spacing.xs)
            make.bottom.equalToSuperview().offset(-Spacing.sm)
        }

        containerView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(96)
        }

        return containerView
    }

    private func createEmptyTimelineView() -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .kidkDarkBackground.withAlphaComponent(0.4)
        containerView.layer.cornerRadius = CornerRadius.medium

        let iconLabel = UILabel()
        iconLabel.text = "🌟"
        iconLabel.font = .systemFont(ofSize: 24)

        let titleLabel = UILabel()
        titleLabel.text = "아직 기록된 완료 미션이 없어요"
        titleLabel.font = UIFont.kidkFont(.s14, .medium)
        titleLabel.textColor = .kidkTextWhite

        let subtitleLabel = UILabel()
        subtitleLabel.text = "미션을 완료하면 성장 타임라인에 자동으로 기록됩니다"
        subtitleLabel.font = UIFont.kidkFont(.s12, .regular)
        subtitleLabel.textColor = .kidkGray
        subtitleLabel.numberOfLines = 0

        containerView.addSubview(iconLabel)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)

        iconLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Spacing.sm)
            make.centerY.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Spacing.sm)
            make.leading.equalTo(iconLabel.snp.trailing).offset(Spacing.xs)
            make.trailing.equalToSuperview().offset(-Spacing.sm)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.trailing.equalTo(titleLabel)
            make.bottom.equalToSuperview().offset(-Spacing.sm)
        }

        containerView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(92)
        }

        return containerView
    }

    private func currentMonthTitle() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 성장 요약"
        return formatter.string(from: Date())
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
        authRepository.saveAutoLoginPreference(false)
        authRepository.saveLoginCredentials(email: "")

        NotificationCenter.default.post(name: .userLoggedOut, object: nil)

        debugSuccess("User logged out successfully")
    }
}

private final class MonthlyGrowthSummaryView: UIView {

    private let cardView = ParentTimelineCardView(accentColor: .kidkPinkLight)

    private let monthLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s12, .bold)
        label.textColor = .kidkPinkLight
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s20, .bold)
        label.textColor = .kidkTextWhite
        return label
    }()

    private let summaryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s14, .regular)
        label.textColor = .kidkGray
        label.numberOfLines = 0
        return label
    }()

    private let metricStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = Spacing.xs
        stackView.distribution = .fillEqually
        return stackView
    }()

    private let usageProgressView = ParentTimelineProgressRowView()

    private let levelMetricView = SummaryMetricPillView(title: "레벨")
    private let pointsMetricView = SummaryMetricPillView(title: "보유 KP")
    private let missionMetricView = SummaryMetricPillView(title: "완료 미션")

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        configure(
            monthText: "이번 달 성장 요약",
            childName: "우리 아이",
            level: 0,
            points: 0,
            completedMissionCount: 0,
            summaryText: "이번 달 성장 데이터가 준비 중이에요",
            usagePercent: 0
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(cardView)

        cardView.contentView.addSubview(monthLabel)
        cardView.contentView.addSubview(titleLabel)
        cardView.contentView.addSubview(summaryLabel)
        cardView.contentView.addSubview(metricStackView)
        cardView.contentView.addSubview(usageProgressView)

        metricStackView.addArrangedSubview(levelMetricView)
        metricStackView.addArrangedSubview(pointsMetricView)
        metricStackView.addArrangedSubview(missionMetricView)

        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        monthLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(monthLabel.snp.bottom).offset(Spacing.xxs)
            make.leading.trailing.equalToSuperview()
        }

        summaryLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Spacing.xs)
            make.leading.trailing.equalToSuperview()
        }

        metricStackView.snp.makeConstraints { make in
            make.top.equalTo(summaryLabel.snp.bottom).offset(Spacing.sm)
            make.leading.trailing.equalToSuperview()
        }

        usageProgressView.snp.makeConstraints { make in
            make.top.equalTo(metricStackView.snp.bottom).offset(Spacing.sm)
            make.leading.trailing.bottom.equalToSuperview()
        }

        metricStackView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(72)
        }
    }

    func configure(
        monthText: String,
        childName: String,
        level: Int,
        points: Int,
        completedMissionCount: Int,
        summaryText: String,
        usagePercent: Int
    ) {
        monthLabel.text = monthText
        titleLabel.text = "\(childName)의 타임라인"
        summaryLabel.text = summaryText

        levelMetricView.configure(value: "Lv.\(level)")
        pointsMetricView.configure(value: "\(points) KP")
        missionMetricView.configure(value: "\(completedMissionCount)개")

        usageProgressView.configure(
            title: "한도 사용률",
            valueText: "\(usagePercent)%",
            progress: CGFloat(usagePercent) / 100,
            tintColor: usagePercent >= 80 ? .kidkPink : .kidkGreen
        )
    }

    func setCompactLayout(_ isCompact: Bool) {
        metricStackView.axis = isCompact ? .vertical : .horizontal
        metricStackView.distribution = .fillEqually
    }
}

private final class SummaryMetricPillView: UIView {

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .kidkDarkBackground.withAlphaComponent(0.4)
        view.layer.cornerRadius = CornerRadius.medium
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s12, .medium)
        label.textColor = .kidkGray
        return label
    }()

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s16, .bold)
        label.textColor = .kidkTextWhite
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.85
        return label
    }()

    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(valueLabel)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(Spacing.xs)
        }

        valueLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.trailing.bottom.equalToSuperview().inset(Spacing.xs)
        }
    }

    func configure(value: String) {
        valueLabel.text = value
    }
}

private final class TimelineStatCardView: UIView {

    private let cardView: ParentTimelineCardView
    private let iconImageView = UIImageView()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s12, .medium)
        label.textColor = .kidkGray
        return label
    }()

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s18, .bold)
        label.textColor = .kidkTextWhite
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.82
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s12, .regular)
        label.textColor = .kidkGray
        label.numberOfLines = 2
        return label
    }()

    init(title: String, icon: String, accentColor: UIColor) {
        self.cardView = ParentTimelineCardView(accentColor: accentColor)
        super.init(frame: .zero)

        iconImageView.image = UIImage(systemName: icon)
        iconImageView.tintColor = accentColor
        iconImageView.contentMode = .scaleAspectFit

        titleLabel.text = title

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(cardView)
        cardView.contentView.addSubview(iconImageView)
        cardView.contentView.addSubview(titleLabel)
        cardView.contentView.addSubview(valueLabel)
        cardView.contentView.addSubview(subtitleLabel)

        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        iconImageView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.width.height.equalTo(18)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(6)
            make.centerY.equalTo(iconImageView)
            make.trailing.equalToSuperview()
        }

        valueLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(Spacing.xs)
            make.leading.trailing.equalToSuperview()
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(valueLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    func configure(value: String, subtitle: String) {
        valueLabel.text = value
        subtitleLabel.text = subtitle
    }
}
