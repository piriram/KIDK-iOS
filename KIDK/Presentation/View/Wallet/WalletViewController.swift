import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class WalletViewController: BaseViewController {

    // MARK: - Properties
    private let viewModel: WalletViewModel

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

    private let summaryView = WalletSummaryHeroView()
    private let accountsSectionView = WalletSectionView()
    private let quickActionsSectionView = WalletSectionView()
    private let savingsSectionView = WalletSectionView()
    private let transactionsSectionView = WalletSectionView()
    private let cardSectionView = WalletSectionView()

    private let quickActionsView = WalletQuickActionsGridView()

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
        navigationController?.navigationBar.prefersLargeTitles = true
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

        contentStackView.addArrangedSubview(summaryView)
        contentStackView.addArrangedSubview(accountsSectionView)
        contentStackView.addArrangedSubview(quickActionsSectionView)
        contentStackView.addArrangedSubview(savingsSectionView)
        contentStackView.addArrangedSubview(transactionsSectionView)
        contentStackView.addArrangedSubview(cardSectionView)

        quickActionsSectionView.configure(title: "빠른 액션", subtitle: "자주 쓰는 기능")
        quickActionsSectionView.setContentViews([quickActionsView])

        quickActionsView.onActionTap = { [weak self] action in
            self?.handleQuickAction(action)
        }

        summaryView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(232)
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
        summaryView.configure(
            totalBalance: viewModel.getTotalBalance(),
            primaryAccountName: viewModel.getPrimaryAccount()?.name ?? "주 계좌 없음",
            accountCount: accounts.count,
            dailyLimit: dailyLimit,
            userLevel: level,
            experience: experience
        )

        renderAccounts(accounts)
        renderSavingsGoals(savingsGoals)
        renderTransactions(transactions)
        renderCard(card)

        refreshControl.endRefreshing()
    }

    private func renderAccounts(_ accounts: [Account]) {
        accountsSectionView.configure(
            title: "내 계좌",
            subtitle: accounts.isEmpty ? "등록된 계좌가 없어요" : "총 \(accounts.count)개"
        )

        guard !accounts.isEmpty else {
            accountsSectionView.setContentViews([WalletEmptyStateRowView(message: "등록된 계좌가 없어요")])
            return
        }

        let rows = accounts.map { account in
            let row = WalletAccountRowView()
            row.configure(with: account)
            row.onTap = { [weak self] in
                let message = "계좌 유형: \(account.type.displayName)\n현재 잔액: \(account.formattedBalance)"
                self?.showAlert(title: account.name, message: message)
            }
            return row
        }

        accountsSectionView.setContentViews(rows)
    }

    private func renderSavingsGoals(_ goals: [SavingsGoal]) {
        let displayGoals = Array(goals.prefix(3))

        savingsSectionView.configure(
            title: "저축 목표",
            subtitle: goals.isEmpty ? "설정된 목표가 없어요" : "진행 중 \(goals.count)개"
        )

        guard !displayGoals.isEmpty else {
            savingsSectionView.setContentViews([WalletEmptyStateRowView(message: "저축 목표를 추가해보세요")])
            return
        }

        let rows = displayGoals.map { goal in
            let row = WalletSavingsGoalRowView()
            row.configure(with: goal)
            row.onTap = { [weak self] in
                self?.showSavingsGoalDetail(goal)
            }
            return row
        }

        savingsSectionView.setContentViews(rows)
    }

    private func renderTransactions(_ transactions: [Transaction]) {
        let displayTransactions = Array(transactions.prefix(8))

        transactionsSectionView.configure(
            title: "최근 거래",
            subtitle: transactions.isEmpty ? "아직 거래 내역이 없어요" : "최근 \(displayTransactions.count)건"
        )

        guard !displayTransactions.isEmpty else {
            transactionsSectionView.setContentViews([WalletEmptyStateRowView(message: "아직 거래 내역이 없어요")])
            return
        }

        let rows = displayTransactions.map { transaction in
            let row = WalletTransactionRowView()
            row.configure(with: transaction)
            row.onTap = { [weak self] in
                self?.showTransactionDetail(transaction)
            }
            return row
        }

        transactionsSectionView.setContentViews(rows)
    }

    private func renderCard(_ card: Card?) {
        cardSectionView.configure(
            title: "내 카드",
            subtitle: card == nil ? "등록된 카드가 없어요" : "카드 상태 확인"
        )

        guard let card else {
            cardSectionView.setContentViews([WalletEmptyStateRowView(message: "등록된 카드가 없어요")])
            return
        }

        let cardView = WalletCardInfoView()
        cardView.configure(with: card)
        cardView.onTap = { [weak self] in
            self?.showCardManagement()
        }

        cardSectionView.setContentViews([cardView])
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

// MARK: - Section Container
private final class WalletSectionView: UIView {

    private let headerView = SectionHeaderView()

    private let bodyContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .cardBackground
        view.layer.cornerRadius = CornerRadius.large
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        return view
    }()

    private let contentStackView: UIStackView = {
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
        addSubview(headerView)
        addSubview(bodyContainerView)
        bodyContainerView.addSubview(contentStackView)

        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        bodyContainerView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(Spacing.xs)
            make.leading.trailing.bottom.equalToSuperview()
        }

        contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(Spacing.sm)
        }
    }

    func configure(title: String, subtitle: String?) {
        headerView.configure(title: title, subtitle: subtitle)
    }

    func setContentViews(_ views: [UIView]) {
        contentStackView.arrangedSubviews.forEach { subview in
            contentStackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }

        views.forEach { view in
            contentStackView.addArrangedSubview(view)
        }
    }
}

// MARK: - Summary Hero
private final class WalletSummaryHeroView: UIView {

    private let gradientLayer = CAGradientLayer()

    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = CornerRadius.extraLarge
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        view.clipsToBounds = true
        return view
    }()

    private let iconBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.16)
        view.layer.cornerRadius = CornerRadius.medium
        return view
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "wallet.pass.fill"))
        imageView.tintColor = .kidkTextWhite
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s16, .bold)
        label.textColor = UIColor.white.withAlphaComponent(0.9)
        label.text = "총 자산"
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
        label.numberOfLines = 1
        return label
    }()

    private let metricsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = Spacing.xs
        return stack
    }()

    private let accountMetricView = WalletSummaryMetricView()
    private let limitMetricView = WalletSummaryMetricView()
    private let levelMetricView = WalletSummaryMetricView()

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
            UIColor(hex: "#47306A").cgColor,
            UIColor(hex: "#2A3554").cgColor,
            UIColor(hex: "#21242E").cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        containerView.layer.insertSublayer(gradientLayer, at: 0)

        containerView.addSubview(iconBackgroundView)
        iconBackgroundView.addSubview(iconImageView)

        containerView.addSubview(titleLabel)
        containerView.addSubview(amountLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(metricsStackView)

        metricsStackView.addArrangedSubview(accountMetricView)
        metricsStackView.addArrangedSubview(limitMetricView)
        metricsStackView.addArrangedSubview(levelMetricView)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        iconBackgroundView.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(Spacing.md)
            make.width.height.equalTo(38)
        }

        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(20)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(Spacing.md)
            make.trailing.lessThanOrEqualTo(iconBackgroundView.snp.leading).offset(-Spacing.sm)
        }

        amountLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Spacing.xs)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(amountLabel.snp.bottom).offset(Spacing.xxs)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
        }

        metricsStackView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(Spacing.sm)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
            make.bottom.equalToSuperview().inset(Spacing.md)
            make.height.equalTo(68)
        }
    }

    func configure(
        totalBalance: Int,
        primaryAccountName: String,
        accountCount: Int,
        dailyLimit: Int,
        userLevel: Int,
        experience: Int
    ) {
        amountLabel.text = totalBalance.formattedCurrency
        subtitleLabel.text = "주 계좌: \(primaryAccountName)"

        accountMetricView.configure(title: "계좌", value: "\(accountCount)개", color: .kidkBlue)
        limitMetricView.configure(title: "일일 한도", value: dailyLimit.formattedCurrency, color: .kidkPink)
        levelMetricView.configure(title: "레벨", value: "Lv.\(userLevel) · EXP \(experience)", color: .kidkGreen)

        accessibilityLabel = "총 자산 \(totalBalance.formattedCurrency), 주 계좌 \(primaryAccountName), 계좌 \(accountCount)개"
    }
}

private final class WalletSummaryMetricView: UIView {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s12, .regular)
        label.textColor = UIColor.white.withAlphaComponent(0.72)
        label.textAlignment = .center
        return label
    }()

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s14, .bold)
        label.textColor = .kidkTextWhite
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.75
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
        backgroundColor = UIColor.white.withAlphaComponent(0.1)
        layer.cornerRadius = CornerRadius.medium

        addSubview(titleLabel)
        addSubview(valueLabel)

        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(6)
        }

        valueLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(6)
            make.bottom.equalToSuperview().inset(6)
        }
    }

    func configure(title: String, value: String, color: UIColor) {
        titleLabel.text = title
        valueLabel.text = value
        valueLabel.textColor = color
    }
}

// MARK: - Account Row
private final class WalletAccountRowView: UIControl {

    var onTap: (() -> Void)?

    private let iconBackgroundView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = CornerRadius.medium
        return view
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .kidkTextWhite
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s16, .bold)
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
        label.textAlignment = .right
        return label
    }()

    private let chevronImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .chevronGray
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
        backgroundColor = .clear

        addSubview(iconBackgroundView)
        iconBackgroundView.addSubview(iconImageView)
        addSubview(nameLabel)
        addSubview(typeLabel)
        addSubview(amountLabel)
        addSubview(chevronImageView)

        snp.makeConstraints { make in
            make.height.equalTo(78)
        }

        iconBackgroundView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }

        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(22)
        }

        chevronImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(8)
            make.height.equalTo(14)
        }

        amountLabel.snp.makeConstraints { make in
            make.trailing.equalTo(chevronImageView.snp.leading).offset(-Spacing.sm)
            make.centerY.equalToSuperview()
            make.width.greaterThanOrEqualTo(90)
        }

        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(iconBackgroundView.snp.top)
            make.leading.equalTo(iconBackgroundView.snp.trailing).offset(Spacing.sm)
            make.trailing.lessThanOrEqualTo(amountLabel.snp.leading).offset(-Spacing.xs)
        }

        typeLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel)
            make.bottom.equalTo(iconBackgroundView.snp.bottom)
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

        accessibilityLabel = "\(account.name), 잔액 \(account.formattedBalance)"
    }

    @objc private func didTap() {
        UISelectionFeedbackGenerator().selectionChanged()
        onTap?()
    }

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.12) {
                self.alpha = self.isHighlighted ? 0.7 : 1.0
            }
        }
    }
}

// MARK: - Quick Actions
private final class WalletQuickActionsGridView: UIView {

    var onActionTap: ((QuickActionType) -> Void)?

    private let firstRowStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = Spacing.xs
        return stack
    }()

    private let secondRowStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
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
        let actions: [QuickActionType] = [.deposit, .withdraw, .transfer, .scanReceipt]

        let vertical = UIStackView(arrangedSubviews: [firstRowStackView, secondRowStackView])
        vertical.axis = .vertical
        vertical.spacing = Spacing.xs
        vertical.distribution = .fillEqually

        addSubview(vertical)
        vertical.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        actions.enumerated().forEach { index, action in
            let button = QuickActionButton(action: action)
            button.tag = index
            button.addTarget(self, action: #selector(handleTap(_:)), for: .touchUpInside)

            if index < 2 {
                firstRowStackView.addArrangedSubview(button)
            } else {
                secondRowStackView.addArrangedSubview(button)
            }
        }

        snp.makeConstraints { make in
            make.height.equalTo(224)
        }
    }

    @objc private func handleTap(_ sender: UIButton) {
        switch sender.tag {
        case 0: onActionTap?(.deposit)
        case 1: onActionTap?(.withdraw)
        case 2: onActionTap?(.transfer)
        case 3: onActionTap?(.scanReceipt)
        default: break
        }
    }
}

// MARK: - Savings Goal Row
private final class WalletSavingsGoalRowView: UIControl {

    var onTap: (() -> Void)?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s16, .bold)
        label.textColor = .kidkTextWhite
        label.numberOfLines = 1
        return label
    }()

    private let statusBadge: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s12, .bold)
        label.textColor = .kidkTextWhite
        label.textAlignment = .center
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        return label
    }()

    private let progressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s14, .medium)
        label.textColor = .kidkGray
        return label
    }()

    private let progressView: UIProgressView = {
        let view = UIProgressView(progressViewStyle: .default)
        view.trackTintColor = UIColor.white.withAlphaComponent(0.12)
        view.progressTintColor = .kidkPink
        view.layer.cornerRadius = 6
        view.clipsToBounds = true
        view.transform = CGAffineTransform(scaleX: 1, y: 1.8)
        return view
    }()

    private let remainLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s12, .regular)
        label.textColor = .kidkGray
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
        backgroundColor = UIColor.white.withAlphaComponent(0.04)
        layer.cornerRadius = CornerRadius.medium

        addSubview(titleLabel)
        addSubview(statusBadge)
        addSubview(progressLabel)
        addSubview(progressView)
        addSubview(remainLabel)

        snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(108)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(Spacing.sm)
            make.trailing.lessThanOrEqualTo(statusBadge.snp.leading).offset(-Spacing.xs)
        }

        statusBadge.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(Spacing.sm)
            make.centerY.equalTo(titleLabel)
            make.height.equalTo(22)
            make.width.greaterThanOrEqualTo(52)
        }

        progressLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Spacing.xs)
            make.leading.trailing.equalToSuperview().inset(Spacing.sm)
        }

        progressView.snp.makeConstraints { make in
            make.top.equalTo(progressLabel.snp.bottom).offset(Spacing.xs)
            make.leading.trailing.equalToSuperview().inset(Spacing.sm)
            make.height.equalTo(8)
        }

        remainLabel.snp.makeConstraints { make in
            make.top.equalTo(progressView.snp.bottom).offset(Spacing.xs)
            make.leading.trailing.equalToSuperview().inset(Spacing.sm)
            make.bottom.equalToSuperview().inset(Spacing.sm)
        }
    }

    func configure(with goal: SavingsGoal) {
        titleLabel.text = goal.name
        progressLabel.text = "\(goal.formattedCurrentAmount) / \(goal.formattedTargetAmount)"
        progressView.setProgress(Float(goal.progress), animated: true)
        remainLabel.text = "남은 금액: \(goal.formattedRemainingAmount)"

        switch goal.status {
        case .inProgress:
            statusBadge.text = "진행 중"
            statusBadge.backgroundColor = .kidkBlue.withAlphaComponent(0.2)
            statusBadge.textColor = .kidkBlue
            progressView.progressTintColor = .kidkPink
        case .completed:
            statusBadge.text = "달성"
            statusBadge.backgroundColor = .kidkGreen.withAlphaComponent(0.2)
            statusBadge.textColor = .kidkGreen
            progressView.progressTintColor = .kidkGreen
        case .cancelled:
            statusBadge.text = "취소"
            statusBadge.backgroundColor = .kidkGray.withAlphaComponent(0.2)
            statusBadge.textColor = .kidkGray
            progressView.progressTintColor = .kidkGray
        }

        if let days = goal.daysRemaining {
            if days > 0 {
                remainLabel.text = "남은 금액: \(goal.formattedRemainingAmount) · D-\(days)"
            } else if days == 0 {
                remainLabel.text = "남은 금액: \(goal.formattedRemainingAmount) · D-Day"
            } else {
                remainLabel.text = "남은 금액: \(goal.formattedRemainingAmount) · D+\(-days)"
            }
        }

        accessibilityLabel = "\(goal.name), 진행률 \(String(format: "%.1f", goal.progressPercentage))퍼센트"
    }

    @objc private func didTap() {
        UISelectionFeedbackGenerator().selectionChanged()
        onTap?()
    }

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.12) {
                self.alpha = self.isHighlighted ? 0.7 : 1.0
            }
        }
    }
}

// MARK: - Transaction Row
private final class WalletTransactionRowView: UIControl {

    var onTap: (() -> Void)?

    private let iconBackgroundView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 18
        view.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        return view
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .kidkTextWhite
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s14, .bold)
        label.textColor = .kidkTextWhite
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
        addSubview(iconBackgroundView)
        iconBackgroundView.addSubview(iconImageView)
        addSubview(titleLabel)
        addSubview(dateLabel)
        addSubview(amountLabel)

        snp.makeConstraints { make in
            make.height.equalTo(70)
        }

        iconBackgroundView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(36)
        }

        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(18)
        }

        amountLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.greaterThanOrEqualTo(90)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconBackgroundView.snp.top)
            make.leading.equalTo(iconBackgroundView.snp.trailing).offset(Spacing.sm)
            make.trailing.lessThanOrEqualTo(amountLabel.snp.leading).offset(-Spacing.xs)
        }

        dateLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.bottom.equalTo(iconBackgroundView.snp.bottom)
        }
    }

    func configure(with transaction: Transaction) {
        titleLabel.text = transaction.description
        dateLabel.text = "\(transaction.formattedDateWithDay) · \(transaction.formattedDate)"
        amountLabel.text = transaction.formattedAmount

        switch transaction.type {
        case .deposit:
            amountLabel.textColor = .kidkGreen
            iconImageView.image = UIImage(systemName: "plus.circle.fill")
            iconBackgroundView.backgroundColor = .kidkGreen.withAlphaComponent(0.2)
            iconImageView.tintColor = .kidkGreen
        case .missionReward:
            amountLabel.textColor = .kidkGreen
            iconImageView.image = UIImage(systemName: "star.fill")
            iconBackgroundView.backgroundColor = .kidkGreen.withAlphaComponent(0.2)
            iconImageView.tintColor = .kidkGreen
        case .withdrawal:
            amountLabel.textColor = .kidkPink
            iconImageView.image = UIImage(systemName: "minus.circle.fill")
            iconBackgroundView.backgroundColor = .kidkPink.withAlphaComponent(0.2)
            iconImageView.tintColor = .kidkPink
        case .transfer:
            amountLabel.textColor = .kidkBlue
            iconImageView.image = UIImage(systemName: "arrow.left.arrow.right.circle.fill")
            iconBackgroundView.backgroundColor = .kidkBlue.withAlphaComponent(0.2)
            iconImageView.tintColor = .kidkBlue
        }

        accessibilityLabel = "\(transaction.description), \(transaction.formattedAmount)"
    }

    @objc private func didTap() {
        UISelectionFeedbackGenerator().selectionChanged()
        onTap?()
    }

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.12) {
                self.alpha = self.isHighlighted ? 0.7 : 1.0
            }
        }
    }
}

// MARK: - Card View
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
            make.height.equalTo(116)
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

        if let lastFourDigits = card.lastFourDigits {
            numberLabel.text = "•••• \(lastFourDigits)"
        } else {
            numberLabel.text = "카드 번호 미등록"
        }

        accessibilityLabel = "\(titleLabel.text ?? "카드"), \(statusLabel.text ?? "")"
    }

    @objc private func didTap() {
        UISelectionFeedbackGenerator().selectionChanged()
        onTap?()
    }

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.12) {
                self.alpha = self.isHighlighted ? 0.7 : 1.0
            }
        }
    }
}

// MARK: - Empty Row
private final class WalletEmptyStateRowView: UIView {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s14, .medium)
        label.textColor = .kidkGray
        label.textAlignment = .center
        return label
    }()

    init(message: String) {
        super.init(frame: .zero)
        titleLabel.text = message
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = UIColor.white.withAlphaComponent(0.04)
        layer.cornerRadius = CornerRadius.medium

        addSubview(titleLabel)

        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(Spacing.sm)
        }

        snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(56)
        }
    }
}
