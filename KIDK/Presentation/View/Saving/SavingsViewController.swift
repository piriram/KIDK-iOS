import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class SavingsViewController: BaseViewController {

    private let viewModel: SavingsViewModel
    weak var coordinator: SavingsCoordinator?

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()

    private let contentView = UIView()

    private let headerView = SavingsHeaderView()
    private let quickStatsView = SavingsQuickStatsView()
    private let bentoOverviewView = SavingsBentoOverviewView()
    private let warmHeroView = SavingsWarmHeroView()

    private let inProgressSection = SectionHeaderView()
    private let inProgressStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Spacing.md
        return stackView
    }()

    private let completedSection = SectionHeaderView()
    private let completedStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Spacing.md
        return stackView
    }()

    private let emptyStateView: UIView = {
        let view = UIView()
        view.backgroundColor = .cardBackground
        view.layer.cornerRadius = CornerRadius.extraLarge
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        view.isHidden = true
        return view
    }()

    private let emptyImageBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .kidkPink.withAlphaComponent(0.18)
        view.layer.cornerRadius = 44
        return view
    }()

    private let emptyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "banknote.fill")
        imageView.tintColor = .kidkPink
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let emptyTitleLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(
            text: "아직 저축 목표가 없어요",
            size: .s20,
            weight: .bold,
            color: .kidkTextWhite,
            lineHeight: 140
        )
        label.textAlignment = .center
        return label
    }()

    private let emptyMessageLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(
            text: "첫 저축 목표를 만들고 차곡차곡 모아봐요",
            size: .s16,
            weight: .regular,
            color: .kidkGray,
            lineHeight: 140
        )
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()

    private let addGoalButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("저축 목표 만들기", for: .normal)
        button.titleLabel?.font = UIFont.kidkFont(.s16, .bold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .kidkPink
        button.layer.cornerRadius = CornerRadius.medium
        return button
    }()

    private let refreshControl = UIRefreshControl()
    private var currentStyle: SavingsDisplayStyle = .warmKids

    init(viewModel: SavingsViewModel) {
        self.viewModel = viewModel
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
        title = "내 저금통"
        view.backgroundColor = .kidkDarkBackground
        refreshControl.tintColor = .kidkPink

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(headerView)
        contentView.addSubview(quickStatsView)
        contentView.addSubview(bentoOverviewView)
        contentView.addSubview(warmHeroView)
        contentView.addSubview(inProgressSection)
        contentView.addSubview(inProgressStackView)
        contentView.addSubview(completedSection)
        contentView.addSubview(completedStackView)
        contentView.addSubview(emptyStateView)

        emptyStateView.addSubview(emptyImageBackgroundView)
        emptyImageBackgroundView.addSubview(emptyImageView)
        emptyStateView.addSubview(emptyTitleLabel)
        emptyStateView.addSubview(emptyMessageLabel)
        emptyStateView.addSubview(addGoalButton)

        scrollView.refreshControl = refreshControl

        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }

        headerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Spacing.md)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
        }

        quickStatsView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(Spacing.sm)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
        }

        bentoOverviewView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Spacing.md)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
        }

        warmHeroView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Spacing.md)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
        }

        inProgressSection.snp.makeConstraints { make in
            make.top.equalTo(quickStatsView.snp.bottom).offset(Spacing.lg)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
        }

        inProgressStackView.snp.makeConstraints { make in
            make.top.equalTo(inProgressSection.snp.bottom).offset(Spacing.md)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
        }

        completedSection.snp.makeConstraints { make in
            make.top.equalTo(inProgressStackView.snp.bottom).offset(Spacing.lg)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
        }

        completedStackView.snp.makeConstraints { make in
            make.top.equalTo(completedSection.snp.bottom).offset(Spacing.md)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
            make.bottom.equalToSuperview().offset(-Spacing.xl)
        }

        emptyStateView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview().inset(Spacing.lg)
        }

        emptyImageBackgroundView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(Spacing.xl)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(88)
        }

        emptyImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(48)
        }

        emptyTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(emptyImageBackgroundView.snp.bottom).offset(Spacing.md)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
        }

        emptyMessageLabel.snp.makeConstraints { make in
            make.top.equalTo(emptyTitleLabel.snp.bottom).offset(Spacing.xs)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
        }

        addGoalButton.snp.makeConstraints { make in
            make.top.equalTo(emptyMessageLabel.snp.bottom).offset(Spacing.lg)
            make.centerX.equalToSuperview()
            make.width.equalTo(220)
            make.height.equalTo(52)
            make.bottom.equalToSuperview().inset(Spacing.xl)
        }

        inProgressSection.configure(title: "진행 중인 목표", subtitle: nil)
        completedSection.configure(title: "달성한 목표", subtitle: nil)

        applyStyle(currentStyle)
    }

    private func bind() {
        let viewDidLoadTrigger = rx.sentMessage(#selector(UIViewController.viewDidLoad))
            .map { _ in () }
            .asObservable()

        let goalSelectedTrigger = PublishRelay<SavingsGoal>()

        let input = SavingsViewModel.Input(
            viewDidLoad: viewDidLoadTrigger,
            goalSelected: goalSelectedTrigger.asObservable(),
            refreshTrigger: refreshControl.rx.controlEvent(.valueChanged).asObservable()
        )

        let output = viewModel.transform(input: input)

        output.isLoading
            .drive(onNext: { [weak self] isLoading in
                if isLoading {
                    self?.showLoading()
                } else {
                    self?.hideLoading()
                    self?.refreshControl.endRefreshing()
                }
            })
            .disposed(by: disposeBag)

        output.stats
            .drive(onNext: { [weak self] stats in
                self?.headerView.configure(with: stats)
                self?.quickStatsView.configure(
                    streakDays: stats.currentStreak,
                    weeklyAverage: stats.averageWeeklySavings.formattedCurrency,
                    monthlyAverage: stats.averageMonthlySavings.formattedCurrency
                )
                self?.bentoOverviewView.configure(with: stats)
                self?.warmHeroView.configure(with: stats)
            })
            .disposed(by: disposeBag)

        output.inProgressGoals
            .drive(onNext: { [weak self] goals in
                self?.updateInProgressGoals(goals, goalSelectedRelay: goalSelectedTrigger)
            })
            .disposed(by: disposeBag)

        output.completedGoals
            .drive(onNext: { [weak self] goals in
                self?.updateCompletedGoals(goals, goalSelectedRelay: goalSelectedTrigger)
            })
            .disposed(by: disposeBag)

        Observable.combineLatest(
            output.inProgressGoals.asObservable(),
            output.completedGoals.asObservable()
        )
        .subscribe(onNext: { [weak self] inProgress, completed in
            let isEmpty = inProgress.isEmpty && completed.isEmpty
            self?.emptyStateView.isHidden = !isEmpty
            self?.inProgressSection.isHidden = isEmpty
            self?.completedSection.isHidden = isEmpty
            self?.inProgressStackView.isHidden = isEmpty
            self?.completedStackView.isHidden = isEmpty
        })
        .disposed(by: disposeBag)

        output.error
            .drive(onNext: { [weak self] error in
                self?.showError(message: error)
            })
            .disposed(by: disposeBag)

        addGoalButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.showAlert(title: "준비중", message: "저축 목표 만들기 기능은 곧 추가될 예정입니다.")
            })
            .disposed(by: disposeBag)
    }

    private func applyStyle(_ style: SavingsDisplayStyle) {
        let visualStyle = designStyle(for: style)

        view.backgroundColor = visualStyle.screenBackgroundColor
        refreshControl.tintColor = visualStyle.primaryAccentColor

        headerView.applyStyle(visualStyle)
        quickStatsView.applyStyle(visualStyle)
        bentoOverviewView.applyStyle(visualStyle)
        let warmHeroStyle: SavingsDisplayStyle = (style == .warmKids) ? .bentoDashboard : visualStyle
        warmHeroView.applyStyle(warmHeroStyle)
        inProgressSection.applyStyle(titleColor: visualStyle.sectionTitleColor, subtitleColor: visualStyle.sectionSubtitleColor)
        completedSection.applyStyle(titleColor: visualStyle.sectionTitleColor, subtitleColor: visualStyle.sectionSubtitleColor)

        emptyStateView.backgroundColor = visualStyle.emptyCardBackgroundColor
        emptyStateView.layer.borderColor = visualStyle.emptyCardBorderColor.cgColor
        emptyImageBackgroundView.backgroundColor = visualStyle.primaryAccentColor.withAlphaComponent(0.20)
        emptyImageView.tintColor = visualStyle.primaryAccentColor
        emptyMessageLabel.textColor = visualStyle.sectionSubtitleColor
        addGoalButton.backgroundColor = visualStyle.primaryButtonColor

        switch style {
        case .neoBankClean:
            headerView.isHidden = false
            quickStatsView.isHidden = false
            bentoOverviewView.isHidden = true
            warmHeroView.isHidden = true
            inProgressStackView.spacing = Spacing.md
            completedStackView.spacing = Spacing.md
            inProgressSection.snp.remakeConstraints { make in
                make.top.equalTo(quickStatsView.snp.bottom).offset(Spacing.lg)
                make.leading.trailing.equalToSuperview().inset(Spacing.md)
            }
        case .bentoDashboard:
            headerView.isHidden = true
            quickStatsView.isHidden = true
            bentoOverviewView.isHidden = false
            warmHeroView.isHidden = true
            inProgressStackView.spacing = Spacing.sm
            completedStackView.spacing = Spacing.sm
            inProgressSection.snp.remakeConstraints { make in
                make.top.equalTo(bentoOverviewView.snp.bottom).offset(Spacing.lg)
                make.leading.trailing.equalToSuperview().inset(Spacing.md)
            }
        case .warmKids:
            headerView.isHidden = true
            quickStatsView.isHidden = true
            bentoOverviewView.isHidden = true
            warmHeroView.isHidden = false
            inProgressStackView.spacing = Spacing.lg
            completedStackView.spacing = Spacing.md
            inProgressSection.snp.remakeConstraints { make in
                make.top.equalTo(warmHeroView.snp.bottom).offset(Spacing.lg)
                make.leading.trailing.equalToSuperview().inset(Spacing.md)
            }
        }

        inProgressStackView.arrangedSubviews.forEach {
            if let card = $0 as? SavingsGoalCardView {
                card.applyStyle(visualStyle)
            }
            if let emptyCard = $0 as? SavingsSectionEmptyCardView {
                emptyCard.applyStyle(visualStyle)
            }
        }

        completedStackView.arrangedSubviews.forEach {
            if let card = $0 as? SavingsGoalCardView {
                card.applyStyle(visualStyle)
            }
            if let emptyCard = $0 as? SavingsSectionEmptyCardView {
                emptyCard.applyStyle(visualStyle)
            }
        }
    }

    private func designStyle(for layoutStyle: SavingsDisplayStyle) -> SavingsDisplayStyle {
        layoutStyle
    }

    private func updateInProgressGoals(_ goals: [SavingsGoal], goalSelectedRelay: PublishRelay<SavingsGoal>) {
        let activeDesignStyle = designStyle(for: currentStyle)
        let inProgressTitle = activeDesignStyle == .warmKids ? "지금 모으는 목표" : "진행 중인 목표"
        inProgressSection.configure(title: inProgressTitle, subtitle: goals.isEmpty ? "현재 목표가 없어요" : "\(goals.count)개 진행 중")

        inProgressStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        if goals.isEmpty {
            inProgressStackView.addArrangedSubview(makeSectionEmptyCard(message: "진행 중인 저축 목표가 없습니다"))
        } else {
            goals.forEach { goal in
                let cardView = SavingsGoalCardView()
                cardView.applyStyle(activeDesignStyle)
                cardView.configure(with: goal)
                cardView.cardTapped
                    .bind(to: goalSelectedRelay)
                    .disposed(by: disposeBag)
                inProgressStackView.addArrangedSubview(cardView)
            }
        }
    }

    private func updateCompletedGoals(_ goals: [SavingsGoal], goalSelectedRelay: PublishRelay<SavingsGoal>) {
        let activeDesignStyle = designStyle(for: currentStyle)
        let completedTitle = activeDesignStyle == .warmKids ? "달성한 목표 스티커" : "달성한 목표"
        completedSection.configure(title: completedTitle, subtitle: goals.isEmpty ? "아직 달성된 목표가 없어요" : "\(goals.count)개 달성")

        completedStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        if goals.isEmpty {
            completedStackView.addArrangedSubview(makeSectionEmptyCard(message: "달성한 저축 목표가 없습니다"))
        } else {
            goals.forEach { goal in
                let cardView = SavingsGoalCardView()
                cardView.applyStyle(activeDesignStyle)
                cardView.configure(with: goal)
                cardView.cardTapped
                    .bind(to: goalSelectedRelay)
                    .disposed(by: disposeBag)
                completedStackView.addArrangedSubview(cardView)
            }
        }
    }

    private func makeSectionEmptyCard(message: String) -> UIView {
        let card = SavingsSectionEmptyCardView(message: message)
        card.applyStyle(designStyle(for: currentStyle))
        return card
    }
}

private final class SavingsSectionEmptyCardView: UIView {

    private let iconView = UIImageView(image: UIImage(systemName: "tray"))
    private let messageLabel = UILabel()

    init(message: String) {
        super.init(frame: .zero)
        setupUI()
        messageLabel.text = message
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .cardBackground
        layer.cornerRadius = CornerRadius.medium
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.withAlphaComponent(0.06).cgColor

        iconView.tintColor = .kidkGray

        messageLabel.applyTextStyle(
            text: "",
            size: .s14,
            weight: .regular,
            color: .kidkGray,
            lineHeight: 140
        )
        messageLabel.textAlignment = .center

        addSubview(iconView)
        addSubview(messageLabel)

        iconView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(Spacing.sm)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(18)
        }

        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(iconView.snp.bottom).offset(Spacing.xxs)
            make.leading.trailing.equalToSuperview().inset(Spacing.sm)
            make.bottom.equalToSuperview().inset(Spacing.sm)
        }

        snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(78)
        }
    }

    func applyStyle(_ style: SavingsDisplayStyle) {
        backgroundColor = style.emptyCardBackgroundColor
        layer.borderColor = style.emptyCardBorderColor.cgColor
        iconView.tintColor = style.emptyIconColor
        messageLabel.textColor = style.sectionSubtitleColor
    }
}

private final class SavingsQuickStatsView: UIView {

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = Spacing.xs
        stack.distribution = .fillEqually
        return stack
    }()

    private let streakItem = SavingsQuickStatItemView()
    private let weeklyItem = SavingsQuickStatItemView()
    private let monthlyItem = SavingsQuickStatItemView()

    private var currentStyle: SavingsDisplayStyle = .neoBankClean
    private var streakDays: Int = 0
    private var weeklyAverage: String = "0원"
    private var monthlyAverage: String = "0원"

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        stackView.addArrangedSubview(streakItem)
        stackView.addArrangedSubview(weeklyItem)
        stackView.addArrangedSubview(monthlyItem)

        render()
    }

    func configure(streakDays: Int, weeklyAverage: String, monthlyAverage: String) {
        self.streakDays = max(streakDays, 0)
        self.weeklyAverage = weeklyAverage
        self.monthlyAverage = monthlyAverage
        render()
    }

    func applyStyle(_ style: SavingsDisplayStyle) {
        currentStyle = style
        switch style {
        case .bentoDashboard:
            stackView.spacing = Spacing.sm
        default:
            stackView.spacing = Spacing.xs
        }
        render()
    }

    private func render() {
        streakItem.applyStyle(backgroundColor: currentStyle.statCardBackgroundColor, borderColor: currentStyle.statCardBorderColor, titleColor: currentStyle.statTitleColor)
        weeklyItem.applyStyle(backgroundColor: currentStyle.statCardBackgroundColor, borderColor: currentStyle.statCardBorderColor, titleColor: currentStyle.statTitleColor)
        monthlyItem.applyStyle(backgroundColor: currentStyle.statCardBackgroundColor, borderColor: currentStyle.statCardBorderColor, titleColor: currentStyle.statTitleColor)

        streakItem.configure(title: "연속", value: "\(streakDays)일", iconName: "flame.fill", tintColor: currentStyle.secondaryAccentColor)
        weeklyItem.configure(title: "주간 평균", value: weeklyAverage, iconName: "calendar.badge.clock", tintColor: currentStyle.primaryAccentColor)
        monthlyItem.configure(title: "월간 평균", value: monthlyAverage, iconName: "chart.line.uptrend.xyaxis", tintColor: currentStyle.accentColor(for: .completed))
    }
}

private final class SavingsBentoOverviewView: UIView {

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Spacing.sm
        return stack
    }()

    private let topRow: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = Spacing.sm
        stack.distribution = .fillEqually
        return stack
    }()

    private let bottomRow: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = Spacing.sm
        stack.distribution = .fillEqually
        return stack
    }()

    private let totalItem = SavingsQuickStatItemView()
    private let monthItem = SavingsQuickStatItemView()
    private let rateItem = SavingsQuickStatItemView()
    private let completedItem = SavingsQuickStatItemView()

    private var currentStyle: SavingsDisplayStyle = .bentoDashboard

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(stackView)
        stackView.addArrangedSubview(topRow)
        stackView.addArrangedSubview(bottomRow)

        topRow.addArrangedSubview(totalItem)
        topRow.addArrangedSubview(monthItem)
        bottomRow.addArrangedSubview(rateItem)
        bottomRow.addArrangedSubview(completedItem)

        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        applyStyle(.bentoDashboard)
    }

    func applyStyle(_ style: SavingsDisplayStyle) {
        currentStyle = style
        [totalItem, monthItem, rateItem, completedItem].forEach {
            $0.applyStyle(
                backgroundColor: style.statCardBackgroundColor,
                borderColor: style.statCardBorderColor,
                titleColor: style.statTitleColor
            )
        }
    }

    func configure(with stats: SavingsStats) {
        totalItem.configure(title: "총 저축", value: stats.formattedTotalSavings, iconName: "banknote", tintColor: currentStyle.primaryAccentColor)
        monthItem.configure(title: "이번 달", value: stats.formattedThisMonthSavings, iconName: "calendar", tintColor: currentStyle.secondaryAccentColor)
        rateItem.configure(title: "저축률", value: stats.formattedSavingsRate, iconName: "chart.line.uptrend.xyaxis", tintColor: currentStyle.accentColor(for: .inProgress))
        completedItem.configure(title: "달성", value: "\(stats.completedGoalsCount)개", iconName: "checkmark.seal.fill", tintColor: currentStyle.accentColor(for: .completed))
    }
}

private final class SavingsWarmHeroView: UIView {

    private let containerView = UIView()
    private let mascotBubble = UIView()
    private let mascotIcon = UIImageView(image: UIImage(systemName: "heart.fill"))
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let infoBadge = PaddingBadgeLabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(containerView)
        containerView.addSubview(mascotBubble)
        mascotBubble.addSubview(mascotIcon)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(infoBadge)

        containerView.layer.cornerRadius = CornerRadius.large
        containerView.layer.borderWidth = 1

        mascotBubble.layer.cornerRadius = 22
        mascotIcon.tintColor = .white
        mascotIcon.contentMode = .scaleAspectFit

        titleLabel.applyTextStyle(text: "저축 모험 진행 중!", size: .s18, weight: .bold, color: .kidkTextWhite, lineHeight: 130)
        subtitleLabel.applyTextStyle(text: "오늘도 목표에 한 걸음 가까워졌어요", size: .s14, weight: .medium, color: .kidkTextWhite, lineHeight: 140)
        infoBadge.applyTextStyle(text: "0일 연속", size: .s12, weight: .bold, color: .kidkTextWhite, lineHeight: 120)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        mascotBubble.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(Spacing.md)
            make.width.height.equalTo(44)
        }

        mascotIcon.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(18)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(Spacing.md)
            make.leading.equalTo(mascotBubble.snp.trailing).offset(Spacing.sm)
            make.trailing.equalToSuperview().inset(Spacing.md)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Spacing.xs)
            make.leading.equalTo(titleLabel)
            make.trailing.equalToSuperview().inset(Spacing.md)
        }

        infoBadge.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(Spacing.sm)
            make.leading.equalTo(titleLabel)
            make.bottom.equalToSuperview().inset(Spacing.md)
        }
    }

    func applyStyle(_ style: SavingsDisplayStyle) {
        containerView.backgroundColor = style.goalCardBackgroundColor
        containerView.layer.borderColor = style.emptyCardBorderColor.cgColor
        mascotBubble.backgroundColor = style.primaryAccentColor.withAlphaComponent(0.24)
        infoBadge.backgroundColor = style.secondaryAccentColor.withAlphaComponent(0.24)
        infoBadge.textColor = style.secondaryAccentColor
        subtitleLabel.textColor = style.sectionSubtitleColor
    }

    func configure(with stats: SavingsStats) {
        titleLabel.text = "저축 모험 진행 중!"
        subtitleLabel.text = "이번 달에 \(stats.formattedThisMonthSavings) 모았어요"
        infoBadge.text = "\(stats.currentStreak)일 연속"
    }
}

private final class SavingsQuickStatItemView: UIView {

    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = UIColor.white.withAlphaComponent(0.04)
        layer.cornerRadius = CornerRadius.medium
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.withAlphaComponent(0.06).cgColor

        iconView.contentMode = .scaleAspectFit

        titleLabel.applyTextStyle(
            text: "",
            size: .s12,
            weight: .regular,
            color: .kidkGray,
            lineHeight: 120
        )

        valueLabel.applyTextStyle(
            text: "",
            size: .s14,
            weight: .bold,
            color: .kidkTextWhite,
            lineHeight: 130
        )
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.8

        addSubview(iconView)
        addSubview(titleLabel)
        addSubview(valueLabel)

        iconView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(Spacing.xs)
            make.width.height.equalTo(14)
        }

        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(iconView)
            make.leading.equalTo(iconView.snp.trailing).offset(4)
            make.trailing.lessThanOrEqualToSuperview().inset(Spacing.xs)
        }

        valueLabel.snp.makeConstraints { make in
            make.top.equalTo(iconView.snp.bottom).offset(Spacing.xs)
            make.leading.trailing.equalToSuperview().inset(Spacing.xs)
            make.bottom.equalToSuperview().inset(Spacing.xs)
        }

        snp.makeConstraints { make in
            make.height.equalTo(70)
        }
    }

    func configure(title: String, value: String, iconName: String, tintColor: UIColor) {
        titleLabel.text = title
        valueLabel.text = value
        valueLabel.textColor = tintColor
        iconView.image = UIImage(systemName: iconName)
        iconView.tintColor = tintColor
    }

    func applyStyle(backgroundColor: UIColor, borderColor: UIColor, titleColor: UIColor) {
        self.backgroundColor = backgroundColor
        layer.borderColor = borderColor.cgColor
        titleLabel.textColor = titleColor
    }
}

private final class PaddingBadgeLabel: UILabel {

    private let horizontalPadding: CGFloat = 10
    private let verticalPadding: CGFloat = 5

    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + horizontalPadding * 2,
            height: size.height + verticalPadding * 2
        )
    }
}
