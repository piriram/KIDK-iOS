import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class WalletViewController: BaseViewController {

    private enum TransactionSortOption {
        case recent
        case amount

        var title: String {
            switch self {
            case .recent: return "최근순"
            case .amount: return "금액순"
            }
        }
    }

    // MARK: - Properties
    private let viewModel: WalletViewModel
    private var transactionSortOption: TransactionSortOption = .recent
    private var latestTransactions: [Transaction] = []

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = .clear
        return scrollView
    }()

    private let contentView = UIView()

    private let contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Spacing.lg
        return stack
    }()

    // A안 + 게임요소
    private let summaryCockpitView = WalletSummaryCockpitView()
    private let gameStatusView = WalletGameStatusView()

    private let quickActionsSectionView = WalletSectionView()
    private let accountsSectionView = WalletSectionView()
    private let savingsSectionView = WalletSectionView()
    private let transactionsSectionView = WalletSectionView()
    private let cardSectionView = WalletSectionView()

    private let quickActionsRowView = WalletQuickActionsRowView()
    private let accountsCarouselView = WalletAccountsCarouselView()
    private let savingsCarouselView = WalletSavingsCarouselView()
    private let transactionsTimelineView = WalletTransactionsTimelineView()

    private let refreshControl = UIRefreshControl()

    // MARK: - Initialization
    init(viewModel: WalletViewModel) {
        self.viewModel = viewModel
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
        bind()
    }

    // MARK: - Setup
    private func setupNavigationBar() {
        title = "내 지갑"
        navigationItem.largeTitleDisplayMode = .never
    }

    private func setupUI() {
        view.backgroundColor = .kidkDarkBackground
        refreshControl.tintColor = .kidkPink

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(contentStackView)

        scrollView.refreshControl = refreshControl

        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }

        contentStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Spacing.md)
            make.leading.trailing.equalToSuperview().inset(Spacing.sm)
            make.bottom.equalToSuperview().offset(-Spacing.xl)
        }

        contentStackView.addArrangedSubview(summaryCockpitView)
        contentStackView.addArrangedSubview(quickActionsSectionView)
        contentStackView.addArrangedSubview(transactionsSectionView)
        contentStackView.addArrangedSubview(gameStatusView)
        contentStackView.addArrangedSubview(accountsSectionView)
        contentStackView.addArrangedSubview(savingsSectionView)
        contentStackView.addArrangedSubview(cardSectionView)

        summaryCockpitView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(220)
        }

        quickActionsSectionView.configure(title: "빠른 액션", subtitle: "한 번에 바로 실행")
        quickActionsSectionView.setContentView(quickActionsRowView)

        accountsSectionView.configure(title: "내 통장", subtitle: "좌우로 넘겨서 확인")
        accountsSectionView.setContentView(accountsCarouselView)

        savingsSectionView.configure(title: "저축 목표", subtitle: "진행 중 목표 트랙")
        savingsSectionView.setContentView(savingsCarouselView)

        transactionsSectionView.configure(
            title: "최근 거래 타임라인",
            subtitle: nil,
            trailingText: transactionSortOption.title,
            trailingIconName: "arrow.up.arrow.down"
        )
        transactionsSectionView.setHeaderTrailingTap { [weak self] in
            self?.toggleTransactionSortOption()
        }
        transactionsSectionView.setContentView(transactionsTimelineView)

        cardSectionView.configure(title: "내 카드", subtitle: "카드 상태 확인")

        quickActionsRowView.onActionTap = { [weak self] action in
            self?.handleQuickAction(action)
        }
    }

    private func bind() {
        refreshControl.rx.controlEvent(.valueChanged)
            .subscribe(onNext: { [weak self] in
                self?.viewModel.refreshData()
            })
            .disposed(by: disposeBag)

        Observable.combineLatest(
            viewModel.accounts.asObservable(),
            viewModel.transactions.asObservable(),
            viewModel.savingsGoals.asObservable(),
            viewModel.card.asObservable(),
            viewModel.userLevel.asObservable(),
            viewModel.userExperience.asObservable(),
            viewModel.dailySpendingLimit.asObservable()
        )
        .observe(on: MainScheduler.instance)
        .subscribe(onNext: { [weak self] accounts, transactions, savingsGoals, card, level, exp, dailyLimit in
            self?.render(
                accounts: accounts,
                transactions: transactions,
                savingsGoals: savingsGoals,
                card: card,
                level: level,
                experience: exp,
                dailyLimit: dailyLimit
            )
        })
        .disposed(by: disposeBag)
    }

    // MARK: - Render
    private func render(
        accounts: [Account],
        transactions: [Transaction],
        savingsGoals: [SavingsGoal],
        card: Card?,
        level: Int,
        experience: Int,
        dailyLimit: Int
    ) {
        let totalBalance = viewModel.getTotalBalance()
        let primaryAccountName = viewModel.getPrimaryAccount()?.name ?? "주 계좌 없음"
        let todaySpent = calculateTodaySpent(from: transactions)
        let todayMissionCount = calculateTodayMissionCount(from: transactions)

        summaryCockpitView.configure(
            totalBalance: totalBalance,
            primaryAccountName: primaryAccountName,
            accountCount: accounts.count,
            goalCount: savingsGoals.count,
            dailyLimit: dailyLimit,
            todaySpent: todaySpent
        )

        gameStatusView.configure(
            level: level,
            experience: experience,
            missionDone: todayMissionCount,
            missionTarget: 3,
            savingsGoalCount: savingsGoals.count,
            accountCount: accounts.count
        )

        accountsCarouselView.configure(accounts: accounts) { [weak self] account in
            let message = "계좌 유형: \(account.type.displayName)\n현재 잔액: \(account.formattedBalance)"
            self?.showAlert(title: account.name, message: message)
        }

        savingsCarouselView.configure(goals: Array(savingsGoals.prefix(6))) { [weak self] goal in
            self?.showSavingsGoalDetail(goal)
        }

        latestTransactions = transactions
        applyTransactionSortAndRenderTimeline()

        if let card {
            let cardView = WalletCardInfoView()
            cardView.configure(with: card)
            cardView.onTap = { [weak self] in
                self?.showCardManagement()
            }
            cardSectionView.configure(title: "내 카드", subtitle: "카드 상태 확인")
            cardSectionView.setContentView(cardView)
        } else {
            cardSectionView.configure(title: "내 카드", subtitle: "등록된 카드가 없어요")
            cardSectionView.setContentView(WalletEmptyCardView(message: "등록된 카드가 없어요"))
        }

        refreshControl.endRefreshing()
    }

    private func toggleTransactionSortOption() {
        transactionSortOption = (transactionSortOption == .recent) ? .amount : .recent
        transactionsSectionView.configure(
            title: "최근 거래 타임라인",
            subtitle: nil,
            trailingText: transactionSortOption.title,
            trailingIconName: "arrow.up.arrow.down"
        )
        applyTransactionSortAndRenderTimeline()
    }

    private func applyTransactionSortAndRenderTimeline() {
        let sortedTransactions: [Transaction]
        switch transactionSortOption {
        case .recent:
            sortedTransactions = latestTransactions.sorted { $0.date > $1.date }
        case .amount:
            sortedTransactions = latestTransactions.sorted { abs($0.amount) > abs($1.amount) }
        }

        transactionsTimelineView.configure(transactions: Array(sortedTransactions.prefix(8))) { [weak self] transaction in
            self?.showTransactionDetail(transaction)
        }
    }

    private func calculateTodaySpent(from transactions: [Transaction]) -> Int {
        let calendar = Calendar.current
        return transactions
            .filter { calendar.isDateInToday($0.date) }
            .filter { $0.type == .withdrawal || $0.type == .transfer }
            .reduce(0) { $0 + $1.amount }
    }

    private func calculateTodayMissionCount(from transactions: [Transaction]) -> Int {
        let calendar = Calendar.current
        return transactions
            .filter { calendar.isDateInToday($0.date) }
            .filter { $0.type == .missionReward }
            .count
    }

    // MARK: - Actions
    private func handleQuickAction(_ action: QuickActionType) {
        switch action {
        case .deposit:
            showTransactionInput(type: .deposit)
        case .withdraw:
            showTransactionInput(type: .withdraw)
        case .transfer:
            showTransferScreen()
        case .scanReceipt:
            showReceiptScanScreen()
        }
    }

    private func showTransactionInput(type: TransactionInputType) {
        let transactionInputVC = TransactionInputViewController(inputType: type)
        let navController = UINavigationController(rootViewController: transactionInputVC)
        navController.modalPresentationStyle = .pageSheet

        if #available(iOS 15.0, *) {
            if let sheet = navController.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.prefersGrabberVisible = true
            }
        }

        present(navController, animated: true)
    }

    private func showTransferScreen() {
        let transferVC = TransferViewController()
        navigationController?.pushViewController(transferVC, animated: true)
    }

    private func showReceiptScanScreen() {
        let receiptScanVC = ReceiptScanViewController()
        navigationController?.pushViewController(receiptScanVC, animated: true)
    }

    // MARK: - Detail Alerts
    private func showTransactionDetail(_ transaction: Transaction) {
        var message = """
        거래 타입: \(transaction.type.displayName)
        금액: \(transaction.formattedAmount)
        거래 후 잔액: \(transaction.formattedBalanceAfter)
        """

        if let memo = transaction.memo {
            message += "\n메모: \(memo)"
        }

        showAlert(title: transaction.description, message: message)
    }

    private func showSavingsGoalDetail(_ goal: SavingsGoal) {
        var message = """
        목표 금액: \(goal.formattedTargetAmount)
        현재 금액: \(goal.formattedCurrentAmount)
        남은 금액: \(goal.formattedRemainingAmount)
        진행률: \(String(format: "%.1f", goal.progressPercentage))%
        """

        if let targetDate = goal.formattedTargetDate {
            message += "\n목표일: \(targetDate)"
        }

        showAlert(title: goal.name, message: message)
    }

    private func showCardManagement() {
        showAlert(title: "카드 관리", message: "카드 관리 기능은 준비중입니다.")
    }
}

// MARK: - Section Wrapper
private final class WalletSectionView: UIView {

    private let headerView = SectionHeaderView()

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .cardBackground
        view.layer.cornerRadius = CornerRadius.large
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        return view
    }()

    private var currentContentView: UIView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(headerView)
        addSubview(containerView)

        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        containerView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(Spacing.xs)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    func configure(title: String, subtitle: String?, trailingText: String? = nil, trailingIconName: String? = nil) {
        headerView.configure(title: title, subtitle: subtitle, trailingText: trailingText, trailingIconName: trailingIconName)
    }

    func setHeaderTrailingTap(_ action: (() -> Void)?) {
        headerView.onTrailingTap = action
    }

    func setContentView(_ view: UIView) {
        currentContentView?.removeFromSuperview()
        currentContentView = view

        containerView.addSubview(view)
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(Spacing.sm)
        }
    }
}

// MARK: - Cockpit Summary
private final class WalletSummaryCockpitView: UIView {

    private let gradientLayer = CAGradientLayer()

    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = CornerRadius.extraLarge
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        view.clipsToBounds = true
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s14, .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.82)
        label.text = "내 지갑"
        return label
    }()

    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s32, .bold)
        label.textColor = .kidkTextWhite
        label.text = "0원"
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s14, .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.78)
        label.text = "주 계좌: 없음"
        return label
    }()

    private let chipsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = Spacing.xs
        return stack
    }()

    private let accountChip = WalletSummaryChipView()
    private let goalChip = WalletSummaryChipView()

    private let budgetRingView = WalletBudgetRingView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = containerView.bounds
    }

    private func setupUI() {
        addSubview(containerView)

        gradientLayer.colors = [
            UIColor(hex: "#4A2E71").cgColor,
            UIColor(hex: "#2A3656").cgColor,
            UIColor(hex: "#20232D").cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        containerView.layer.insertSublayer(gradientLayer, at: 0)

        containerView.addSubview(titleLabel)
        containerView.addSubview(amountLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(chipsStackView)
        containerView.addSubview(budgetRingView)

        chipsStackView.addArrangedSubview(accountChip)
        chipsStackView.addArrangedSubview(goalChip)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        budgetRingView.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(Spacing.md)
            make.width.height.equalTo(104)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(Spacing.md)
            make.trailing.lessThanOrEqualTo(budgetRingView.snp.leading).offset(-Spacing.sm)
        }

        amountLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Spacing.xs)
            make.leading.equalToSuperview().inset(Spacing.md)
            make.trailing.lessThanOrEqualTo(budgetRingView.snp.leading).offset(-Spacing.xs)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(amountLabel.snp.bottom).offset(Spacing.xxs)
            make.leading.equalToSuperview().inset(Spacing.md)
            make.trailing.lessThanOrEqualTo(budgetRingView.snp.leading).offset(-Spacing.xs)
        }

        chipsStackView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(Spacing.sm)
            make.leading.equalToSuperview().inset(Spacing.md)
            make.trailing.lessThanOrEqualTo(budgetRingView.snp.leading).offset(-Spacing.xs)
            make.bottom.equalToSuperview().inset(Spacing.md)
        }
    }

    func configure(
        totalBalance: Int,
        primaryAccountName: String,
        accountCount: Int,
        goalCount: Int,
        dailyLimit: Int,
        todaySpent: Int
    ) {
        amountLabel.text = totalBalance.formattedCurrency
        subtitleLabel.text = "주 계좌: \(primaryAccountName)"

        accountChip.configure(title: "통장", value: "\(accountCount)개", color: .kidkBlue)
        goalChip.configure(title: "목표", value: "\(goalCount)개", color: .kidkPink)

        budgetRingView.configure(dailyLimit: dailyLimit, todaySpent: todaySpent)

        accessibilityLabel = "총 자산 \(totalBalance.formattedCurrency), 주 계좌 \(primaryAccountName), 오늘 사용 \(todaySpent.formattedCurrency)"
    }
}

private final class WalletSummaryChipView: UIView {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s12, .regular)
        label.textColor = UIColor.white.withAlphaComponent(0.8)
        return label
    }()

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s12, .bold)
        label.textColor = .kidkTextWhite
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = UIColor.white.withAlphaComponent(0.14)
        layer.cornerRadius = CornerRadius.medium

        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stack.axis = .horizontal
        stack.spacing = 6

        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10))
        }
    }

    func configure(title: String, value: String, color: UIColor) {
        titleLabel.text = title
        valueLabel.text = value
        valueLabel.textColor = color
    }
}

private final class WalletBudgetRingView: UIView {

    private let trackLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()

    private let percentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s16, .bold)
        label.textColor = .kidkTextWhite
        label.textAlignment = .center
        label.text = "0%"
        return label
    }()

    private let captionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s10, .regular)
        label.textColor = UIColor.white.withAlphaComponent(0.7)
        label.textAlignment = .center
        label.text = "오늘 사용"
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateRingPath()
    }

    private func setupUI() {
        layer.addSublayer(trackLayer)
        layer.addSublayer(progressLayer)

        trackLayer.strokeColor = UIColor.white.withAlphaComponent(0.2).cgColor
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineWidth = 8

        progressLayer.strokeColor = UIColor.kidkGreen.cgColor
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = 8
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0

        let textStack = UIStackView(arrangedSubviews: [percentLabel, captionLabel])
        textStack.axis = .vertical
        textStack.spacing = 2
        textStack.alignment = .center

        addSubview(textStack)
        textStack.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    private func updateRingPath() {
        let centerPoint = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2 - 8
        let start = -CGFloat.pi / 2
        let end = start + CGFloat.pi * 2

        let path = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: start, endAngle: end, clockwise: true)
        trackLayer.path = path.cgPath
        progressLayer.path = path.cgPath
    }

    func configure(dailyLimit: Int, todaySpent: Int) {
        guard dailyLimit > 0 else {
            percentLabel.text = "0%"
            progressLayer.strokeEnd = 0
            captionLabel.text = "오늘 사용"
            return
        }

        let ratio = min(max(CGFloat(todaySpent) / CGFloat(dailyLimit), 0), 1)
        let percent = Int(ratio * 100)

        percentLabel.text = "\(percent)%"
        progressLayer.strokeEnd = ratio

        if ratio < 0.6 {
            progressLayer.strokeColor = UIColor.kidkGreen.cgColor
        } else if ratio < 0.85 {
            progressLayer.strokeColor = UIColor.kidkBlue.cgColor
        } else {
            progressLayer.strokeColor = UIColor.kidkPink.cgColor
        }

        let remaining = max(dailyLimit - todaySpent, 0)
        captionLabel.text = "남은 \(remaining.formattedCurrency)"
    }
}

// MARK: - Game Status
private final class WalletGameStatusView: UIView {

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#2B2B34")
        view.layer.cornerRadius = CornerRadius.large
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        return view
    }()

    private let levelBadgeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s14, .bold)
        label.textColor = .kidkTextWhite
        label.backgroundColor = .kidkBlue.withAlphaComponent(0.2)
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        label.textAlignment = .center
        label.text = "Lv.1"
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s16, .bold)
        label.textColor = .kidkTextWhite
        label.text = "오늘의 지갑 퀘스트"
        return label
    }()

    private let missionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s14, .medium)
        label.textColor = .kidkGray
        label.text = "미션 0/3 완료"
        return label
    }()

    private let expProgressView: UIProgressView = {
        let view = UIProgressView(progressViewStyle: .default)
        view.trackTintColor = UIColor.white.withAlphaComponent(0.12)
        view.progressTintColor = .kidkGreen
        view.transform = CGAffineTransform(scaleX: 1, y: 1.8)
        view.layer.cornerRadius = 6
        view.clipsToBounds = true
        return view
    }()

    private let expLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s12, .regular)
        label.textColor = UIColor.white.withAlphaComponent(0.75)
        label.text = "EXP 0 / 200"
        return label
    }()

    private let rewardsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = Spacing.xs
        stack.distribution = .fillEqually
        return stack
    }()

    private let rewardChip1 = WalletRewardChipView()
    private let rewardChip2 = WalletRewardChipView()
    private let rewardChip3 = WalletRewardChipView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(containerView)

        containerView.addSubview(levelBadgeLabel)
        containerView.addSubview(titleLabel)
        containerView.addSubview(missionLabel)
        containerView.addSubview(expProgressView)
        containerView.addSubview(expLabel)
        containerView.addSubview(rewardsStackView)

        rewardsStackView.addArrangedSubview(rewardChip1)
        rewardsStackView.addArrangedSubview(rewardChip2)
        rewardsStackView.addArrangedSubview(rewardChip3)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        levelBadgeLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(Spacing.sm)
            make.height.equalTo(24)
            make.width.greaterThanOrEqualTo(58)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(levelBadgeLabel.snp.trailing).offset(Spacing.xs)
            make.centerY.equalTo(levelBadgeLabel)
            make.trailing.equalToSuperview().inset(Spacing.sm)
        }

        missionLabel.snp.makeConstraints { make in
            make.top.equalTo(levelBadgeLabel.snp.bottom).offset(Spacing.sm)
            make.leading.trailing.equalToSuperview().inset(Spacing.sm)
        }

        expProgressView.snp.makeConstraints { make in
            make.top.equalTo(missionLabel.snp.bottom).offset(Spacing.xs)
            make.leading.trailing.equalToSuperview().inset(Spacing.sm)
            make.height.equalTo(8)
        }

        expLabel.snp.makeConstraints { make in
            make.top.equalTo(expProgressView.snp.bottom).offset(Spacing.xs)
            make.leading.trailing.equalToSuperview().inset(Spacing.sm)
        }

        rewardsStackView.snp.makeConstraints { make in
            make.top.equalTo(expLabel.snp.bottom).offset(Spacing.sm)
            make.leading.trailing.equalToSuperview().inset(Spacing.sm)
            make.bottom.equalToSuperview().inset(Spacing.sm)
            make.height.equalTo(44)
        }
    }

    func configure(
        level: Int,
        experience: Int,
        missionDone: Int,
        missionTarget: Int,
        savingsGoalCount: Int,
        accountCount: Int
    ) {
        levelBadgeLabel.text = "  Lv.\(level)  "
        missionLabel.text = "미션 \(min(missionDone, missionTarget))/\(missionTarget) 완료"

        let levelUnit = 200
        let currentExp = max(experience % levelUnit, 0)
        let progress = Float(currentExp) / Float(levelUnit)

        expProgressView.setProgress(progress, animated: true)
        expLabel.text = "EXP \(currentExp) / \(levelUnit)"

        rewardChip1.configure(
            title: missionDone >= 1 ? "미션러너" : "미션 시작",
            icon: "star.fill",
            color: missionDone >= 1 ? .kidkGreen : .kidkGray
        )
        rewardChip2.configure(
            title: savingsGoalCount > 0 ? "저축중" : "목표 만들기",
            icon: "target",
            color: savingsGoalCount > 0 ? .kidkPink : .kidkGray
        )
        rewardChip3.configure(
            title: accountCount >= 2 ? "통장 마스터" : "통장 확장",
            icon: "wallet.pass.fill",
            color: accountCount >= 2 ? .kidkBlue : .kidkGray
        )

        accessibilityLabel = "레벨 \(level), 미션 \(missionDone)개 완료, 경험치 \(currentExp)"
    }
}

private final class WalletRewardChipView: UIView {

    private let iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s12, .bold)
        label.textColor = .kidkTextWhite
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = UIColor.white.withAlphaComponent(0.08)
        layer.cornerRadius = CornerRadius.medium

        addSubview(iconView)
        addSubview(titleLabel)

        iconView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(14)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconView.snp.trailing).offset(4)
            make.trailing.equalToSuperview().inset(8)
            make.centerY.equalToSuperview()
        }
    }

    func configure(title: String, icon: String, color: UIColor) {
        titleLabel.text = title
        titleLabel.textColor = color
        iconView.image = UIImage(systemName: icon)
        iconView.tintColor = color
    }
}

// MARK: - Quick Actions Row (4 fixed)
private final class WalletQuickActionsRowView: UIView {

    var onActionTap: ((QuickActionType) -> Void)?

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = Spacing.xs
        return stack
    }()

    private let actions: [QuickActionType] = [.deposit, .withdraw, .transfer, .scanReceipt]

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

        actions.enumerated().forEach { index, action in
            let button = QuickActionButton(action: action)
            button.tag = index
            button.addTarget(self, action: #selector(didTapAction(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }

        snp.makeConstraints { make in
            make.height.equalTo(108)
        }
    }

    @objc private func didTapAction(_ sender: UIButton) {
        guard actions.indices.contains(sender.tag) else { return }
        onActionTap?(actions[sender.tag])
    }
}

// MARK: - Accounts Horizontal Carousel
private final class WalletAccountsCarouselView: UIView {

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = Spacing.sm
        return stack
    }()

    private let emptyView = WalletEmptyCardView(message: "등록된 계좌가 없어요")

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(scrollView)
        scrollView.addSubview(stackView)

        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(136)
        }

        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }

        snp.makeConstraints { make in
            make.height.equalTo(136)
        }
    }

    func configure(accounts: [Account], onTap: @escaping (Account) -> Void) {
        stackView.arrangedSubviews.forEach { view in
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        guard !accounts.isEmpty else {
            stackView.addArrangedSubview(emptyView)
            emptyView.snp.makeConstraints { make in
                make.width.equalTo(220)
            }
            return
        }

        for account in accounts {
            let card = WalletAccountCarouselCardView()
            card.configure(with: account)
            card.onTap = { onTap(account) }
            stackView.addArrangedSubview(card)
            card.snp.makeConstraints { make in
                make.width.equalTo(230)
            }
        }
    }
}

private final class WalletAccountCarouselCardView: UIControl {

    var onTap: (() -> Void)?

    private let iconBackgroundView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = CornerRadius.medium
        return view
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s14, .bold)
        label.textColor = .kidkTextWhite
        return label
    }()

    private let typeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s12, .regular)
        label.textColor = .kidkGray
        return label
    }()

    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s18, .bold)
        label.textColor = .kidkTextWhite
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        addTarget(self, action: #selector(didTap), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = UIColor.white.withAlphaComponent(0.06)
        layer.cornerRadius = CornerRadius.large

        addSubview(iconBackgroundView)
        iconBackgroundView.addSubview(iconImageView)
        addSubview(nameLabel)
        addSubview(typeLabel)
        addSubview(amountLabel)

        iconBackgroundView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(Spacing.sm)
            make.width.height.equalTo(40)
        }

        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(20)
        }

        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(iconBackgroundView)
            make.leading.equalTo(iconBackgroundView.snp.trailing).offset(Spacing.xs)
            make.trailing.equalToSuperview().inset(Spacing.sm)
        }

        typeLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel)
            make.bottom.equalTo(iconBackgroundView)
            make.trailing.equalTo(nameLabel)
        }

        amountLabel.snp.makeConstraints { make in
            make.top.equalTo(iconBackgroundView.snp.bottom).offset(Spacing.sm)
            make.leading.trailing.equalToSuperview().inset(Spacing.sm)
        }
    }

    func configure(with account: Account) {
        nameLabel.text = account.name
        typeLabel.text = account.type.displayName + (account.isPrimary ? " · 주 계좌" : "")
        amountLabel.text = account.formattedBalance
        amountLabel.textColor = account.isPrimary ? .kidkGreen : .kidkTextWhite

        switch account.type {
        case .spending:
            iconBackgroundView.backgroundColor = .kidkBlue.withAlphaComponent(0.2)
            iconImageView.image = UIImage(systemName: "wallet.pass.fill")
            iconImageView.tintColor = .kidkBlue
        case .savings:
            iconBackgroundView.backgroundColor = .kidkPink.withAlphaComponent(0.2)
            iconImageView.image = UIImage(systemName: "banknote.fill")
            iconImageView.tintColor = .kidkPink
        case .goal:
            iconBackgroundView.backgroundColor = .kidkGreen.withAlphaComponent(0.2)
            iconImageView.image = UIImage(systemName: "target")
            iconImageView.tintColor = .kidkGreen
        }
    }

    @objc private func didTap() {
        UISelectionFeedbackGenerator().selectionChanged()
        onTap?()
    }

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.12) {
                self.alpha = self.isHighlighted ? 0.7 : 1
            }
        }
    }
}

// MARK: - Savings Horizontal Carousel
private final class WalletSavingsCarouselView: UIView {

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = Spacing.sm
        return stack
    }()

    private let emptyView = WalletEmptyCardView(message: "저축 목표를 추가해보세요")

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(scrollView)
        scrollView.addSubview(stackView)

        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(148)
        }

        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }

        snp.makeConstraints { make in
            make.height.equalTo(148)
        }
    }

    func configure(goals: [SavingsGoal], onTap: @escaping (SavingsGoal) -> Void) {
        stackView.arrangedSubviews.forEach { view in
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        guard !goals.isEmpty else {
            stackView.addArrangedSubview(emptyView)
            emptyView.snp.makeConstraints { make in
                make.width.equalTo(240)
            }
            return
        }

        for goal in goals {
            let card = WalletSavingsGoalCarouselCardView()
            card.configure(with: goal)
            card.onTap = { onTap(goal) }
            stackView.addArrangedSubview(card)
            card.snp.makeConstraints { make in
                make.width.equalTo(252)
            }
        }
    }
}

private final class WalletSavingsGoalCarouselCardView: UIControl {

    var onTap: (() -> Void)?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s16, .bold)
        label.textColor = .kidkTextWhite
        label.numberOfLines = 1
        return label
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s12, .bold)
        label.textColor = .kidkTextWhite
        label.textAlignment = .center
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        return label
    }()

    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s14, .medium)
        label.textColor = .kidkGray
        return label
    }()

    private let progressView: UIProgressView = {
        let view = UIProgressView(progressViewStyle: .default)
        view.trackTintColor = UIColor.white.withAlphaComponent(0.12)
        view.progressTintColor = .kidkPink
        view.transform = CGAffineTransform(scaleX: 1, y: 1.8)
        view.layer.cornerRadius = 6
        view.clipsToBounds = true
        return view
    }()

    private let bottomLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s12, .regular)
        label.textColor = UIColor.white.withAlphaComponent(0.75)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        addTarget(self, action: #selector(didTap), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = UIColor.white.withAlphaComponent(0.06)
        layer.cornerRadius = CornerRadius.large

        addSubview(titleLabel)
        addSubview(statusLabel)
        addSubview(amountLabel)
        addSubview(progressView)
        addSubview(bottomLabel)

        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(Spacing.sm)
            make.trailing.lessThanOrEqualTo(statusLabel.snp.leading).offset(-Spacing.xs)
        }

        statusLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(Spacing.sm)
            make.centerY.equalTo(titleLabel)
            make.height.equalTo(22)
            make.width.greaterThanOrEqualTo(50)
        }

        amountLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Spacing.xs)
            make.leading.trailing.equalToSuperview().inset(Spacing.sm)
        }

        progressView.snp.makeConstraints { make in
            make.top.equalTo(amountLabel.snp.bottom).offset(Spacing.xs)
            make.leading.trailing.equalToSuperview().inset(Spacing.sm)
            make.height.equalTo(8)
        }

        bottomLabel.snp.makeConstraints { make in
            make.top.equalTo(progressView.snp.bottom).offset(Spacing.xs)
            make.leading.trailing.bottom.equalToSuperview().inset(Spacing.sm)
        }
    }

    func configure(with goal: SavingsGoal) {
        titleLabel.text = goal.name
        amountLabel.text = "\(goal.formattedCurrentAmount) / \(goal.formattedTargetAmount)"
        progressView.setProgress(Float(goal.progress), animated: true)

        switch goal.status {
        case .inProgress:
            statusLabel.text = "진행"
            statusLabel.backgroundColor = .kidkBlue.withAlphaComponent(0.2)
            statusLabel.textColor = .kidkBlue
            progressView.progressTintColor = .kidkPink
        case .completed:
            statusLabel.text = "달성"
            statusLabel.backgroundColor = .kidkGreen.withAlphaComponent(0.2)
            statusLabel.textColor = .kidkGreen
            progressView.progressTintColor = .kidkGreen
        case .cancelled:
            statusLabel.text = "취소"
            statusLabel.backgroundColor = .kidkGray.withAlphaComponent(0.2)
            statusLabel.textColor = .kidkGray
            progressView.progressTintColor = .kidkGray
        }

        if let days = goal.daysRemaining {
            if days > 0 {
                bottomLabel.text = "D-\(days) · 남은 \(goal.formattedRemainingAmount)"
            } else if days == 0 {
                bottomLabel.text = "D-Day · 남은 \(goal.formattedRemainingAmount)"
            } else {
                bottomLabel.text = "D+\(-days) · 남은 \(goal.formattedRemainingAmount)"
            }
        } else {
            bottomLabel.text = "남은 \(goal.formattedRemainingAmount)"
        }
    }

    @objc private func didTap() {
        UISelectionFeedbackGenerator().selectionChanged()
        onTap?()
    }

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.12) {
                self.alpha = self.isHighlighted ? 0.7 : 1
            }
        }
    }
}

// MARK: - Transactions Timeline
private final class WalletTransactionsTimelineView: UIView {

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Spacing.xs
        return stack
    }()

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
    }

    func configure(transactions: [Transaction], onTap: @escaping (Transaction) -> Void) {
        stackView.arrangedSubviews.forEach { view in
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        guard !transactions.isEmpty else {
            stackView.addArrangedSubview(WalletEmptyCardView(message: "아직 거래 내역이 없어요"))
            return
        }

        for (index, transaction) in transactions.enumerated() {
            let row = WalletTimelineTransactionRowView()
            row.configure(with: transaction, isLast: index == transactions.count - 1)
            row.onTap = { onTap(transaction) }
            stackView.addArrangedSubview(row)
        }
    }
}

private final class WalletTimelineTransactionRowView: UIControl {

    var onTap: (() -> Void)?

    private let timelineLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.16)
        return view
    }()

    private let timelineDotView: UIView = {
        let view = UIView()
        view.backgroundColor = .kidkBlue
        view.layer.cornerRadius = 5
        return view
    }()

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        view.layer.cornerRadius = CornerRadius.medium
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s14, .bold)
        label.textColor = .kidkTextWhite
        label.numberOfLines = 2
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s12, .regular)
        label.textColor = .kidkGray
        return label
    }()

    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s16, .bold)
        label.textAlignment = .right
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        addTarget(self, action: #selector(didTap), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(timelineLineView)
        addSubview(timelineDotView)
        addSubview(containerView)

        containerView.addSubview(titleLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(amountLabel)

        timelineDotView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(4)
            make.top.equalToSuperview().offset(20)
            make.width.height.equalTo(10)
        }

        timelineLineView.snp.makeConstraints { make in
            make.centerX.equalTo(timelineDotView)
            make.top.equalTo(timelineDotView.snp.bottom)
            make.bottom.equalToSuperview()
            make.width.equalTo(2)
        }

        containerView.snp.makeConstraints { make in
            make.leading.equalTo(timelineDotView.snp.trailing).offset(Spacing.sm)
            make.trailing.top.bottom.equalToSuperview()
            make.height.greaterThanOrEqualTo(72)
        }

        amountLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(Spacing.sm)
            make.centerY.equalToSuperview()
            make.width.greaterThanOrEqualTo(90)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(Spacing.sm)
            make.leading.equalToSuperview().inset(Spacing.sm)
            make.trailing.lessThanOrEqualTo(amountLabel.snp.leading).offset(-Spacing.xs)
        }

        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.equalTo(titleLabel)
            make.trailing.lessThanOrEqualTo(amountLabel.snp.leading).offset(-Spacing.xs)
            make.bottom.equalToSuperview().inset(Spacing.sm)
        }
    }

    func configure(with transaction: Transaction, isLast: Bool) {
        titleLabel.text = transaction.description
        dateLabel.text = "\(transaction.formattedDateWithDay) · \(transaction.formattedDate)"
        amountLabel.text = transaction.formattedAmount

        switch transaction.type {
        case .deposit, .missionReward:
            amountLabel.textColor = .kidkGreen
            timelineDotView.backgroundColor = .kidkGreen
        case .withdrawal:
            amountLabel.textColor = .kidkPink
            timelineDotView.backgroundColor = .kidkPink
        case .transfer:
            amountLabel.textColor = .kidkBlue
            timelineDotView.backgroundColor = .kidkBlue
        }

        timelineLineView.isHidden = isLast
    }

    @objc private func didTap() {
        UISelectionFeedbackGenerator().selectionChanged()
        onTap?()
    }

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.12) {
                self.alpha = self.isHighlighted ? 0.7 : 1
            }
        }
    }
}

// MARK: - Card Info
private final class WalletCardInfoView: UIControl {

    var onTap: (() -> Void)?

    private let cardImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s16, .bold)
        label.textColor = .kidkTextWhite
        return label
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s14, .medium)
        label.textColor = .kidkGray
        return label
    }()

    private let numberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s12, .regular)
        label.textColor = UIColor.white.withAlphaComponent(0.72)
        return label
    }()

    private let chevronImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        imageView.tintColor = .chevronGray
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        addTarget(self, action: #selector(didTap), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(cardImageView)
        addSubview(titleLabel)
        addSubview(statusLabel)
        addSubview(numberLabel)
        addSubview(chevronImageView)

        snp.makeConstraints { make in
            make.height.equalTo(110)
        }

        cardImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(72)
        }

        chevronImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(8)
            make.height.equalTo(14)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(cardImageView).offset(4)
            make.leading.equalTo(cardImageView.snp.trailing).offset(Spacing.sm)
            make.trailing.lessThanOrEqualTo(chevronImageView.snp.leading).offset(-Spacing.sm)
        }

        statusLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Spacing.xxs)
            make.leading.trailing.equalTo(titleLabel)
        }

        numberLabel.snp.makeConstraints { make in
            make.top.equalTo(statusLabel.snp.bottom).offset(Spacing.xxs)
            make.leading.trailing.equalTo(titleLabel)
        }
    }

    func configure(with card: Card) {
        cardImageView.image = UIImage(named: card.characterImageName)
        titleLabel.text = card.isPhysicalCard ? "실물 카드" : "디지털 카드"
        statusLabel.text = card.statusDescription

        if let digits = card.lastFourDigits {
            numberLabel.text = "•••• \(digits)"
        } else {
            numberLabel.text = "카드 번호 미등록"
        }
    }

    @objc private func didTap() {
        UISelectionFeedbackGenerator().selectionChanged()
        onTap?()
    }

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.12) {
                self.alpha = self.isHighlighted ? 0.7 : 1
            }
        }
    }
}

// MARK: - Empty
private final class WalletEmptyCardView: UIView {

    private let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s14, .medium)
        label.textColor = .kidkGray
        label.textAlignment = .center
        return label
    }()

    init(message: String) {
        super.init(frame: .zero)
        label.text = message
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = UIColor.white.withAlphaComponent(0.05)
        layer.cornerRadius = CornerRadius.medium

        addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(Spacing.sm)
        }

        snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(88)
        }
    }
}
