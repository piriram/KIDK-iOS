import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class WalletViewController: BaseViewController {

    // MARK: - Properties
    private let viewModel: WalletViewModel

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .kidkDarkBackground
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 60
        tableView.sectionFooterHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        return tableView
    }()

    private let refreshControl = UIRefreshControl()

    private enum Section: Int, CaseIterable {
        case hero
        case quickActions
        case accounts
        case goals
        case transactions
        case card

        var title: String? {
            switch self {
            case .hero:
                return nil
            case .quickActions:
                return "빠른 액션"
            case .accounts:
                return "내 통장"
            case .goals:
                return "저축 목표"
            case .transactions:
                return "최근 거래"
            case .card:
                return "내 카드"
            }
        }
    }

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
        setupTableView()
        bind()
    }

    // MARK: - Setup
    private func setupNavigationBar() {
        title = "내 지갑"
        view.backgroundColor = .kidkDarkBackground
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    private func setupTableView() {
        view.addSubview(tableView)

        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PlaceholderCell")
        tableView.register(WalletHeroCell.self, forCellReuseIdentifier: WalletHeroCell.identifier)
        tableView.register(WalletQuickActionsGridCell.self, forCellReuseIdentifier: WalletQuickActionsGridCell.identifier)
        tableView.register(WalletAccountModernCell.self, forCellReuseIdentifier: WalletAccountModernCell.identifier)
        tableView.register(WalletGoalModernCell.self, forCellReuseIdentifier: WalletGoalModernCell.identifier)
        tableView.register(WalletTransactionModernCell.self, forCellReuseIdentifier: WalletTransactionModernCell.identifier)
        tableView.register(WalletCardModernCell.self, forCellReuseIdentifier: WalletCardModernCell.identifier)

        refreshControl.tintColor = .kidkPink
        tableView.refreshControl = refreshControl
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
        .subscribe(onNext: { [weak self] _, _, _, _, _, _, _ in
            self?.tableView.reloadData()
            self?.refreshControl.endRefreshing()
        })
        .disposed(by: disposeBag)
    }

    private func sectionSubtitle(for section: Section) -> String? {
        switch section {
        case .hero:
            return nil
        case .quickActions:
            return "입금, 출금, 이체, 영수증"
        case .accounts:
            return viewModel.accounts.value.isEmpty ? "등록된 통장이 없어요" : "총 \(viewModel.accounts.value.count)개"
        case .goals:
            let count = viewModel.savingsGoals.value.count
            return count == 0 ? "진행 중인 목표가 없어요" : "진행 중 \(count)개"
        case .transactions:
            let count = viewModel.transactions.value.count
            return count == 0 ? "최근 거래가 없어요" : "최근 \(min(count, 8))건"
        case .card:
            return viewModel.card.value == nil ? "연결된 카드가 없어요" : "카드 상태를 확인해요"
        }
    }

    private func monthlyIncomeExpense() -> (income: Int, expense: Int) {
        let calendar = Calendar.current
        let now = Date()

        let monthTransactions = viewModel.transactions.value.filter {
            calendar.isDate($0.date, equalTo: now, toGranularity: .month)
        }

        var income = 0
        var expense = 0

        monthTransactions.forEach { transaction in
            switch transaction.type {
            case .deposit, .missionReward:
                income += transaction.amount
            case .withdrawal, .transfer:
                expense += transaction.amount
            }
        }

        return (income, expense)
    }

    private func todaySpending() -> Int {
        let calendar = Calendar.current
        return viewModel.transactions.value
            .filter { calendar.isDateInToday($0.date) }
            .filter { $0.type == .withdrawal || $0.type == .transfer }
            .reduce(0) { $0 + $1.amount }
    }

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

    private func makePlaceholderCell(_ tableView: UITableView, indexPath: IndexPath, text: String) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceholderCell", for: indexPath)
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }

        let containerView = UIView()
        containerView.backgroundColor = .cardBackground
        containerView.layer.cornerRadius = CornerRadius.large
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor

        let label = UILabel()
        label.font = UIFont.kidkFont(.s14, .medium)
        label.textColor = .kidkGray
        label.textAlignment = .center
        label.text = text

        cell.contentView.addSubview(containerView)
        containerView.addSubview(label)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16))
        }

        label.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(Spacing.sm)
        }

        return cell
    }
}

// MARK: - UITableViewDataSource
extension WalletViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = Section(rawValue: section) else { return 0 }

        switch sectionType {
        case .hero, .quickActions, .card:
            return 1
        case .accounts:
            return max(viewModel.accounts.value.count, 1)
        case .goals:
            return max(min(viewModel.savingsGoals.value.count, 3), 1)
        case .transactions:
            return max(min(viewModel.transactions.value.count, 8), 1)
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sectionType = Section(rawValue: indexPath.section) else {
            return UITableViewCell()
        }

        switch sectionType {
        case .hero:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: WalletHeroCell.identifier,
                for: indexPath
            ) as? WalletHeroCell else {
                return UITableViewCell()
            }

            let monthly = monthlyIncomeExpense()
            let primaryAccountName = viewModel.getPrimaryAccount()?.name ?? "주 통장 없음"
            cell.configure(
                totalBalance: viewModel.getTotalBalance(),
                primaryAccountName: primaryAccountName,
                todaySpending: todaySpending(),
                dailyLimit: viewModel.dailySpendingLimit.value,
                monthlyIncome: monthly.income,
                monthlyExpense: monthly.expense,
                accountCount: viewModel.accounts.value.count,
                userLevel: viewModel.userLevel.value,
                experience: viewModel.userExperience.value
            )
            return cell

        case .quickActions:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: WalletQuickActionsGridCell.identifier,
                for: indexPath
            ) as? WalletQuickActionsGridCell else {
                return UITableViewCell()
            }

            cell.configure { [weak self] action in
                self?.handleQuickAction(action)
            }
            return cell

        case .accounts:
            guard !viewModel.accounts.value.isEmpty else {
                return makePlaceholderCell(tableView, indexPath: indexPath, text: "등록된 통장이 없어요")
            }

            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: WalletAccountModernCell.identifier,
                for: indexPath
            ) as? WalletAccountModernCell else {
                return UITableViewCell()
            }

            cell.configure(with: viewModel.accounts.value[indexPath.row])
            return cell

        case .goals:
            guard !viewModel.savingsGoals.value.isEmpty else {
                return makePlaceholderCell(tableView, indexPath: indexPath, text: "저축 목표를 추가해보세요")
            }

            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: WalletGoalModernCell.identifier,
                for: indexPath
            ) as? WalletGoalModernCell else {
                return UITableViewCell()
            }

            cell.configure(with: viewModel.savingsGoals.value[indexPath.row])
            return cell

        case .transactions:
            guard !viewModel.transactions.value.isEmpty else {
                return makePlaceholderCell(tableView, indexPath: indexPath, text: "최근 거래가 없어요")
            }

            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: WalletTransactionModernCell.identifier,
                for: indexPath
            ) as? WalletTransactionModernCell else {
                return UITableViewCell()
            }

            cell.configure(with: viewModel.transactions.value[indexPath.row])
            return cell

        case .card:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: WalletCardModernCell.identifier,
                for: indexPath
            ) as? WalletCardModernCell else {
                return UITableViewCell()
            }

            cell.configure(with: viewModel.card.value)
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension WalletViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sectionType = Section(rawValue: section),
              let title = sectionType.title else {
            return nil
        }

        let wrapper = UIView()
        wrapper.backgroundColor = .clear

        let headerView = SectionHeaderView()
        headerView.configure(title: title, subtitle: sectionSubtitle(for: sectionType))

        wrapper.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 4, right: 16))
        }

        return wrapper
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let sectionType = Section(rawValue: section) else { return 0 }
        return sectionType == .hero ? 0 : 60
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let sectionType = Section(rawValue: indexPath.section) else {
            return UITableView.automaticDimension
        }

        switch sectionType {
        case .hero:
            return UITableView.automaticDimension
        case .quickActions:
            return 182
        case .accounts:
            return viewModel.accounts.value.isEmpty ? 72 : 96
        case .goals:
            return viewModel.savingsGoals.value.isEmpty ? 72 : 128
        case .transactions:
            return viewModel.transactions.value.isEmpty ? 72 : 88
        case .card:
            return viewModel.card.value == nil ? 86 : 168
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let sectionType = Section(rawValue: indexPath.section) else {
            return 100
        }

        switch sectionType {
        case .hero:
            return 280
        case .quickActions:
            return 182
        case .accounts:
            return 96
        case .goals:
            return 128
        case .transactions:
            return 88
        case .card:
            return 168
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let sectionType = Section(rawValue: indexPath.section) else { return }

        switch sectionType {
        case .accounts:
            guard !viewModel.accounts.value.isEmpty else { return }
            let account = viewModel.accounts.value[indexPath.row]
            let message = "계좌 유형: \(account.type.displayName)\n현재 잔액: \(account.formattedBalance)"
            showAlert(title: account.name, message: message)

        case .goals:
            guard !viewModel.savingsGoals.value.isEmpty else { return }
            showSavingsGoalDetail(viewModel.savingsGoals.value[indexPath.row])

        case .transactions:
            guard !viewModel.transactions.value.isEmpty else { return }
            showTransactionDetail(viewModel.transactions.value[indexPath.row])

        case .card:
            showCardManagement()

        default:
            break
        }
    }
}

// MARK: - Hero Cell
private final class WalletHeroCell: UITableViewCell {

    static let identifier = "WalletHeroCell"

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
        label.font = UIFont.kidkFont(.s16, .bold)
        label.textColor = UIColor.white.withAlphaComponent(0.9)
        label.text = "지갑 요약"
        return label
    }()

    private let levelBadgeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s12, .bold)
        label.textColor = .kidkGreen
        label.textAlignment = .center
        label.backgroundColor = .kidkGreen.withAlphaComponent(0.18)
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        return label
    }()

    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s34, .bold)
        label.textColor = .kidkTextWhite
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s14, .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.78)
        label.numberOfLines = 1
        return label
    }()

    private let spendingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s12, .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.9)
        return label
    }()

    private let spendingProgressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.progressTintColor = .kidkPink
        progressView.trackTintColor = UIColor.white.withAlphaComponent(0.18)
        progressView.transform = CGAffineTransform(scaleX: 1, y: 2.0)
        progressView.clipsToBounds = true
        return progressView
    }()

    private let metricsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = Spacing.xs
        return stackView
    }()

    private let incomeMetricView = WalletMetricView()
    private let expenseMetricView = WalletMetricView()
    private let countMetricView = WalletMetricView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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
        backgroundColor = .clear
        selectionStyle = .none

        gradientLayer.colors = [
            UIColor(hex: "#483165").cgColor,
            UIColor(hex: "#2F3354").cgColor,
            UIColor(hex: "#242A34").cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)

        contentView.addSubview(containerView)
        containerView.layer.insertSublayer(gradientLayer, at: 0)

        containerView.addSubview(titleLabel)
        containerView.addSubview(levelBadgeLabel)
        containerView.addSubview(amountLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(spendingLabel)
        containerView.addSubview(spendingProgressView)
        containerView.addSubview(metricsStackView)

        metricsStackView.addArrangedSubview(incomeMetricView)
        metricsStackView.addArrangedSubview(expenseMetricView)
        metricsStackView.addArrangedSubview(countMetricView)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        }

        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(Spacing.md)
        }

        levelBadgeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalToSuperview().inset(Spacing.md)
            make.height.equalTo(24)
            make.width.greaterThanOrEqualTo(68)
        }

        amountLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Spacing.xs)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(amountLabel.snp.bottom).offset(Spacing.xxs)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
        }

        spendingLabel.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(Spacing.sm)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
        }

        spendingProgressView.snp.makeConstraints { make in
            make.top.equalTo(spendingLabel.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
            make.height.equalTo(8)
        }

        metricsStackView.snp.makeConstraints { make in
            make.top.equalTo(spendingProgressView.snp.bottom).offset(Spacing.md)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
            make.bottom.equalToSuperview().inset(Spacing.md)
            make.height.equalTo(68)
        }
    }

    func configure(
        totalBalance: Int,
        primaryAccountName: String,
        todaySpending: Int,
        dailyLimit: Int,
        monthlyIncome: Int,
        monthlyExpense: Int,
        accountCount: Int,
        userLevel: Int,
        experience: Int
    ) {
        amountLabel.text = totalBalance.formattedCurrency
        subtitleLabel.text = "주 통장: \(primaryAccountName)"
        levelBadgeLabel.text = "Lv.\(userLevel) · EXP \(experience)"

        let safeLimit = max(dailyLimit, 1)
        let progress = min(Float(todaySpending) / Float(safeLimit), 1)
        spendingProgressView.setProgress(progress, animated: false)
        spendingLabel.text = "오늘 사용 \(todaySpending.formattedCurrency) / 일일 한도 \(dailyLimit.formattedCurrency)"

        incomeMetricView.configure(title: "이번달 수입", value: monthlyIncome.formattedCurrency, color: .kidkGreen)
        expenseMetricView.configure(title: "이번달 지출", value: monthlyExpense.formattedCurrency, color: .kidkPink)
        countMetricView.configure(title: "통장 수", value: "\(accountCount)개", color: .kidkBlue)

        accessibilityLabel = "총 자산 \(totalBalance.formattedCurrency), 오늘 사용 \(todaySpending.formattedCurrency), 일일 한도 \(dailyLimit.formattedCurrency)"
    }
}

private final class WalletMetricView: UIView {

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

// MARK: - Quick Actions Grid Cell
private final class WalletQuickActionsGridCell: UITableViewCell {

    static let identifier = "WalletQuickActionsGridCell"

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .cardBackground
        view.layer.cornerRadius = CornerRadius.large
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        return view
    }()

    private let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = Spacing.xs
        return stackView
    }()

    private let firstRowStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = Spacing.xs
        return stackView
    }()

    private let secondRowStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = Spacing.xs
        return stackView
    }()

    private let actions: [QuickActionType] = [.deposit, .withdraw, .transfer, .scanReceipt]
    private var onTap: ((QuickActionType) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupButtons()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(containerView)
        containerView.addSubview(verticalStackView)

        verticalStackView.addArrangedSubview(firstRowStackView)
        verticalStackView.addArrangedSubview(secondRowStackView)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16))
        }

        verticalStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(Spacing.sm)
        }
    }

    private func setupButtons() {
        actions.enumerated().forEach { index, action in
            let button = QuickActionButton(action: action)
            button.tag = index
            button.addTarget(self, action: #selector(actionTapped(_:)), for: .touchUpInside)

            if index < 2 {
                firstRowStackView.addArrangedSubview(button)
            } else {
                secondRowStackView.addArrangedSubview(button)
            }
        }
    }

    func configure(onTap: @escaping (QuickActionType) -> Void) {
        self.onTap = onTap
    }

    @objc private func actionTapped(_ sender: UIButton) {
        guard actions.indices.contains(sender.tag) else { return }
        onTap?(actions[sender.tag])
    }
}

// MARK: - Account Cell
private final class WalletAccountModernCell: UITableViewCell {

    static let identifier = "WalletAccountModernCell"

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .cardBackground
        view.layer.cornerRadius = CornerRadius.large
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        return view
    }()

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
        label.font = UIFont.kidkFont(.s16, .bold)
        label.textColor = .kidkTextWhite
        return label
    }()

    private let typeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s12, .medium)
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

    private let primaryBadgeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s12, .bold)
        label.textColor = .kidkPink
        label.text = "주 통장"
        label.backgroundColor = .kidkPink.withAlphaComponent(0.16)
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    private let chevronImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .chevronGray
        return imageView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .clear

        contentView.addSubview(containerView)
        containerView.addSubview(iconBackgroundView)
        iconBackgroundView.addSubview(iconImageView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(typeLabel)
        containerView.addSubview(primaryBadgeLabel)
        containerView.addSubview(amountLabel)
        containerView.addSubview(chevronImageView)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16))
        }

        iconBackgroundView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Spacing.sm)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }

        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(22)
        }

        chevronImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(Spacing.sm)
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

        primaryBadgeLabel.snp.makeConstraints { make in
            make.leading.equalTo(typeLabel.snp.trailing).offset(8)
            make.centerY.equalTo(typeLabel)
            make.height.equalTo(20)
            make.width.greaterThanOrEqualTo(52)
        }
    }

    func configure(with account: Account) {
        nameLabel.text = account.name
        typeLabel.text = account.type.displayName
        amountLabel.text = account.formattedBalance
        primaryBadgeLabel.isHidden = !account.isPrimary

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
}

// MARK: - Goal Cell
private final class WalletGoalModernCell: UITableViewCell {

    static let identifier = "WalletGoalModernCell"

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .cardBackground
        view.layer.cornerRadius = CornerRadius.large
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s16, .bold)
        label.textColor = .kidkTextWhite
        return label
    }()

    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s14, .medium)
        label.textColor = .kidkGray
        return label
    }()

    private let progressPercentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s12, .bold)
        label.textColor = .kidkPink
        label.backgroundColor = .kidkPink.withAlphaComponent(0.16)
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.textAlignment = .center
        return label
    }()

    private let progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.progressTintColor = .kidkPink
        progressView.trackTintColor = UIColor.white.withAlphaComponent(0.12)
        progressView.transform = CGAffineTransform(scaleX: 1, y: 1.9)
        progressView.clipsToBounds = true
        return progressView
    }()

    private let remainLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s12, .regular)
        label.textColor = .kidkGray
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .clear

        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(progressPercentLabel)
        containerView.addSubview(amountLabel)
        containerView.addSubview(progressView)
        containerView.addSubview(remainLabel)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16))
        }

        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(Spacing.sm)
            make.trailing.lessThanOrEqualTo(progressPercentLabel.snp.leading).offset(-Spacing.xs)
        }

        progressPercentLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(Spacing.sm)
            make.centerY.equalTo(titleLabel)
            make.height.equalTo(22)
            make.width.greaterThanOrEqualTo(62)
        }

        amountLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Spacing.xxs)
            make.leading.trailing.equalToSuperview().inset(Spacing.sm)
        }

        progressView.snp.makeConstraints { make in
            make.top.equalTo(amountLabel.snp.bottom).offset(Spacing.xs)
            make.leading.trailing.equalToSuperview().inset(Spacing.sm)
            make.height.equalTo(7)
        }

        remainLabel.snp.makeConstraints { make in
            make.top.equalTo(progressView.snp.bottom).offset(Spacing.xs)
            make.leading.trailing.equalToSuperview().inset(Spacing.sm)
            make.bottom.equalToSuperview().inset(Spacing.sm)
        }
    }

    func configure(with goal: SavingsGoal) {
        titleLabel.text = goal.name
        amountLabel.text = "\(goal.formattedCurrentAmount) / \(goal.formattedTargetAmount)"
        remainLabel.text = "남은 금액: \(goal.formattedRemainingAmount)"

        let progress = Float(goal.progress)
        progressView.setProgress(progress, animated: false)
        progressPercentLabel.text = String(format: "%.1f%%", goal.progressPercentage)

        switch goal.status {
        case .inProgress:
            progressView.progressTintColor = .kidkPink
            progressPercentLabel.textColor = .kidkPink
            progressPercentLabel.backgroundColor = .kidkPink.withAlphaComponent(0.16)
        case .completed:
            progressView.progressTintColor = .kidkGreen
            progressPercentLabel.textColor = .kidkGreen
            progressPercentLabel.backgroundColor = .kidkGreen.withAlphaComponent(0.16)
        case .cancelled:
            progressView.progressTintColor = .kidkGray
            progressPercentLabel.textColor = .kidkGray
            progressPercentLabel.backgroundColor = .kidkGray.withAlphaComponent(0.16)
        }

        accessibilityLabel = "\(goal.name), 진행률 \(String(format: "%.1f", goal.progressPercentage))퍼센트"
    }
}

// MARK: - Transaction Cell
private final class WalletTransactionModernCell: UITableViewCell {

    static let identifier = "WalletTransactionModernCell"

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .cardBackground
        view.layer.cornerRadius = CornerRadius.large
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        return view
    }()

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

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s14, .bold)
        label.textColor = .kidkTextWhite
        return label
    }()

    private let subtitleLabel: UILabel = {
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

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .clear

        contentView.addSubview(containerView)
        containerView.addSubview(iconBackgroundView)
        iconBackgroundView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(amountLabel)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16))
        }

        iconBackgroundView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Spacing.sm)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }

        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(20)
        }

        amountLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(Spacing.sm)
            make.centerY.equalToSuperview()
            make.width.greaterThanOrEqualTo(90)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconBackgroundView.snp.top).offset(1)
            make.leading.equalTo(iconBackgroundView.snp.trailing).offset(Spacing.sm)
            make.trailing.lessThanOrEqualTo(amountLabel.snp.leading).offset(-Spacing.sm)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.bottom.equalTo(iconBackgroundView.snp.bottom).offset(-1)
            make.trailing.lessThanOrEqualTo(amountLabel.snp.leading).offset(-Spacing.sm)
        }
    }

    func configure(with transaction: Transaction) {
        titleLabel.text = transaction.description

        if let category = transaction.category {
            subtitleLabel.text = "\(transaction.formattedDate) · \(category.rawValue)"
        } else {
            subtitleLabel.text = transaction.formattedDate
        }

        amountLabel.text = transaction.formattedAmount

        switch transaction.type {
        case .deposit, .missionReward:
            amountLabel.textColor = .kidkGreen
            iconBackgroundView.backgroundColor = .kidkGreen.withAlphaComponent(0.2)
            iconImageView.image = UIImage(systemName: "arrow.down.left.circle.fill")
            iconImageView.tintColor = .kidkGreen
        case .withdrawal:
            amountLabel.textColor = .kidkPink
            iconBackgroundView.backgroundColor = .kidkPink.withAlphaComponent(0.2)
            iconImageView.image = UIImage(systemName: "arrow.up.right.circle.fill")
            iconImageView.tintColor = .kidkPink
        case .transfer:
            amountLabel.textColor = .kidkBlue
            iconBackgroundView.backgroundColor = .kidkBlue.withAlphaComponent(0.2)
            iconImageView.image = UIImage(systemName: "arrow.left.arrow.right.circle.fill")
            iconImageView.tintColor = .kidkBlue
        }

        accessibilityLabel = "\(transaction.description), \(transaction.formattedAmount)"
    }
}

// MARK: - Card Cell
private final class WalletCardModernCell: UITableViewCell {

    static let identifier = "WalletCardModernCell"

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .cardBackground
        view.layer.cornerRadius = CornerRadius.large
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        view.clipsToBounds = true
        return view
    }()

    private let gradientLayer = CAGradientLayer()

    private let iconImageView: UIImageView = {
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

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s14, .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.78)
        return label
    }()

    private let statusBadgeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s12, .bold)
        label.textAlignment = .center
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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
        backgroundColor = .clear

        gradientLayer.colors = [
            UIColor(hex: "#2D2D36").cgColor,
            UIColor(hex: "#303045").cgColor,
            UIColor(hex: "#2A2440").cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)

        contentView.addSubview(containerView)
        containerView.layer.insertSublayer(gradientLayer, at: 0)
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(statusBadgeLabel)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16))
        }

        iconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Spacing.sm)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(70)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView).offset(6)
            make.leading.equalTo(iconImageView.snp.trailing).offset(Spacing.sm)
            make.trailing.equalToSuperview().inset(Spacing.sm)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Spacing.xxs)
            make.leading.trailing.equalTo(titleLabel)
        }

        statusBadgeLabel.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(Spacing.xxs)
            make.leading.equalTo(titleLabel)
            make.height.equalTo(22)
            make.width.greaterThanOrEqualTo(58)
        }
    }

    func configure(with card: Card?) {
        guard let card else {
            iconImageView.image = UIImage(systemName: "creditcard")
            iconImageView.tintColor = .kidkGray
            titleLabel.text = "연결된 카드가 없어요"
            subtitleLabel.text = "카드를 연결하면 더 빠르게 쓸 수 있어요"
            statusBadgeLabel.text = "미연결"
            statusBadgeLabel.textColor = .kidkGray
            statusBadgeLabel.backgroundColor = .kidkGray.withAlphaComponent(0.18)
            accessibilityLabel = "연결된 카드 없음"
            return
        }

        iconImageView.image = UIImage(named: card.characterImageName) ?? UIImage(systemName: "creditcard.fill")
        iconImageView.tintColor = .kidkTextWhite

        let cardTypeText = card.isPhysicalCard ? "실물 카드" : "디지털 카드"
        let cardNumberText = card.lastFourDigits.map { "•••• \($0)" } ?? "번호 미등록"

        titleLabel.text = "\(cardTypeText) · \(cardNumberText)"
        subtitleLabel.text = card.statusDescription

        switch card.status {
        case .active:
            statusBadgeLabel.text = "사용 가능"
            statusBadgeLabel.textColor = .kidkGreen
            statusBadgeLabel.backgroundColor = .kidkGreen.withAlphaComponent(0.18)
        case .suspended:
            statusBadgeLabel.text = "일시 정지"
            statusBadgeLabel.textColor = .kidkPink
            statusBadgeLabel.backgroundColor = .kidkPink.withAlphaComponent(0.18)
        case .expired:
            statusBadgeLabel.text = "만료"
            statusBadgeLabel.textColor = .kidkGray
            statusBadgeLabel.backgroundColor = .kidkGray.withAlphaComponent(0.18)
        }

        accessibilityLabel = "\(cardTypeText), 상태 \(card.status.displayName)"
    }
}
