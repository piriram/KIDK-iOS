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

    // MARK: - Section Types
    private enum Section: Int, CaseIterable {
        case summary
        case accounts
        case quickActions
        case savingsGoals
        case transactions
        case card

        var title: String? {
            switch self {
            case .summary:
                return nil
            case .accounts:
                return "내 계좌"
            case .quickActions:
                return "빠른 액션"
            case .savingsGoals:
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
        tableView.register(TransactionCell.self, forCellReuseIdentifier: TransactionCell.identifier)
        tableView.register(SavingsGoalCell.self, forCellReuseIdentifier: SavingsGoalCell.identifier)
        tableView.register(WalletSummaryCell.self, forCellReuseIdentifier: WalletSummaryCell.identifier)
        tableView.register(WalletAccountCell.self, forCellReuseIdentifier: WalletAccountCell.identifier)
        tableView.register(WalletQuickActionsCell.self, forCellReuseIdentifier: WalletQuickActionsCell.identifier)
        tableView.register(WalletCardCell.self, forCellReuseIdentifier: WalletCardCell.identifier)

        refreshControl.tintColor = .kidkPink
        tableView.refreshControl = refreshControl
    }

    private func bind() {
        refreshControl.rx.controlEvent(.valueChanged)
            .subscribe(onNext: { [weak self] in
                self?.viewModel.refreshData()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    self?.refreshControl.endRefreshing()
                }
            })
            .disposed(by: disposeBag)

        Observable.combineLatest(
            viewModel.accounts.asObservable(),
            viewModel.transactions.asObservable(),
            viewModel.savingsGoals.asObservable(),
            viewModel.card.asObservable()
        )
        .observe(on: MainScheduler.instance)
        .subscribe(onNext: { [weak self] _, _, _, _ in
            self?.tableView.reloadData()
        })
        .disposed(by: disposeBag)
    }

    private func sectionSubtitle(for section: Section) -> String? {
        switch section {
        case .summary:
            return nil
        case .accounts:
            return "총 \(viewModel.accounts.value.count)개"
        case .quickActions:
            return "자주 쓰는 기능"
        case .savingsGoals:
            let count = viewModel.savingsGoals.value.count
            return count == 0 ? "설정된 목표가 없어요" : "진행 중 \(count)개"
        case .transactions:
            let count = viewModel.transactions.value.count
            return count == 0 ? "아직 거래 내역이 없어요" : "최근 \(min(count, 10))건"
        case .card:
            return viewModel.card.value == nil ? "등록된 카드가 없어요" : "카드 상태 확인"
        }
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

    private func makePlaceholderCell(_ tableView: UITableView, text: String) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceholderCell", for: IndexPath(row: 0, section: 0))
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }

        let containerView = UIView()
        containerView.backgroundColor = .cardBackground
        containerView.layer.cornerRadius = CornerRadius.large
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor

        let label = UILabel()
        label.font = .kidkFont(.s14, .medium)
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
        case .summary:
            return 1
        case .accounts:
            return max(viewModel.accounts.value.count, 1)
        case .quickActions:
            return 1
        case .savingsGoals:
            return max(min(viewModel.savingsGoals.value.count, 3), 1)
        case .transactions:
            return max(min(viewModel.transactions.value.count, 10), 1)
        case .card:
            return viewModel.card.value != nil ? 1 : 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sectionType = Section(rawValue: indexPath.section) else {
            return UITableViewCell()
        }

        switch sectionType {
        case .summary:
            return makeSummaryCell(tableView, indexPath: indexPath)
        case .accounts:
            return makeAccountCell(tableView, indexPath: indexPath)
        case .quickActions:
            return makeQuickActionsCell(tableView, indexPath: indexPath)
        case .savingsGoals:
            return makeSavingsGoalCell(tableView, indexPath: indexPath)
        case .transactions:
            return makeTransactionCell(tableView, indexPath: indexPath)
        case .card:
            return makeCardCell(tableView, indexPath: indexPath)
        }
    }

    // MARK: - Cell Makers
    private func makeSummaryCell(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: WalletSummaryCell.identifier,
            for: indexPath
        ) as? WalletSummaryCell else {
            return UITableViewCell()
        }

        let primaryName = viewModel.getPrimaryAccount()?.name ?? "주 계좌 없음"
        cell.configure(
            totalBalance: viewModel.getTotalBalance(),
            primaryAccountName: primaryName,
            accountCount: viewModel.accounts.value.count,
            dailyLimit: viewModel.dailySpendingLimit.value,
            userLevel: viewModel.userLevel.value,
            experience: viewModel.userExperience.value
        )

        return cell
    }

    private func makeAccountCell(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        guard !viewModel.accounts.value.isEmpty else {
            return makePlaceholderCell(tableView, text: "등록된 계좌가 없어요")
        }

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: WalletAccountCell.identifier,
            for: indexPath
        ) as? WalletAccountCell else {
            return UITableViewCell()
        }

        let account = viewModel.accounts.value[indexPath.row]
        cell.configure(with: account)
        return cell
    }

    private func makeQuickActionsCell(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: WalletQuickActionsCell.identifier,
            for: indexPath
        ) as? WalletQuickActionsCell else {
            return UITableViewCell()
        }

        cell.configure { [weak self] action in
            self?.handleQuickAction(action)
        }
        return cell
    }

    private func makeSavingsGoalCell(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        guard !viewModel.savingsGoals.value.isEmpty else {
            return makePlaceholderCell(tableView, text: "저축 목표를 추가해보세요")
        }

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SavingsGoalCell.identifier,
            for: indexPath
        ) as? SavingsGoalCell else {
            return UITableViewCell()
        }

        let goal = viewModel.savingsGoals.value[indexPath.row]
        cell.configure(with: goal)
        cell.backgroundColor = .clear
        return cell
    }

    private func makeTransactionCell(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        guard !viewModel.transactions.value.isEmpty else {
            return makePlaceholderCell(tableView, text: "아직 거래 내역이 없어요")
        }

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: TransactionCell.identifier,
            for: indexPath
        ) as? TransactionCell else {
            return UITableViewCell()
        }

        let transaction = viewModel.transactions.value[indexPath.row]
        cell.configure(with: transaction)
        return cell
    }

    private func makeCardCell(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: WalletCardCell.identifier,
            for: indexPath
        ) as? WalletCardCell else {
            return UITableViewCell()
        }

        if let card = viewModel.card.value {
            cell.configure(with: card)
        }
        return cell
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
        return sectionType == .summary ? 0 : 60
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let sectionType = Section(rawValue: indexPath.section) else {
            return UITableView.automaticDimension
        }

        switch sectionType {
        case .summary:
            return 236
        case .accounts:
            return viewModel.accounts.value.isEmpty ? 72 : 92
        case .quickActions:
            return 144
        case .savingsGoals:
            return viewModel.savingsGoals.value.isEmpty ? 72 : UITableView.automaticDimension
        case .transactions:
            return viewModel.transactions.value.isEmpty ? 72 : 84
        case .card:
            return 148
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
        case .transactions:
            guard !viewModel.transactions.value.isEmpty else { return }
            let transaction = viewModel.transactions.value[indexPath.row]
            showTransactionDetail(transaction)
        case .savingsGoals:
            guard !viewModel.savingsGoals.value.isEmpty else { return }
            let goal = viewModel.savingsGoals.value[indexPath.row]
            showSavingsGoalDetail(goal)
        case .card:
            showCardManagement()
        default:
            break
        }
    }

    // MARK: - Navigation
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
        진행률: \(goal.progressPercentage)%
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

private final class WalletSummaryCell: UITableViewCell {

    static let identifier = "WalletSummaryCell"

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
        view.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        view.layer.cornerRadius = CornerRadius.medium
        return view
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "wallet.pass.fill"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .kidkTextWhite
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .kidkFont(.s16, .bold)
        label.textColor = UIColor.white.withAlphaComponent(0.9)
        label.text = "지갑 요약"
        return label
    }()

    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = .kidkFont(.s32, .bold)
        label.textColor = .kidkTextWhite
        label.text = "0원"
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .kidkFont(.s14, .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.78)
        label.text = "주 계좌 없음"
        return label
    }()

    private let infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = Spacing.xs
        return stackView
    }()

    private let accountCountView = WalletInfoItemView()
    private let dailyLimitView = WalletInfoItemView()
    private let levelView = WalletInfoItemView()

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
            UIColor(hex: "#40305D").cgColor,
            UIColor(hex: "#2A2C4D").cgColor,
            UIColor(hex: "#22252F").cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)

        contentView.addSubview(containerView)
        containerView.layer.insertSublayer(gradientLayer, at: 0)

        containerView.addSubview(iconBackgroundView)
        iconBackgroundView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(amountLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(infoStackView)

        infoStackView.addArrangedSubview(accountCountView)
        infoStackView.addArrangedSubview(dailyLimitView)
        infoStackView.addArrangedSubview(levelView)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
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
            make.top.equalTo(amountLabel.snp.bottom).offset(Spacing.xs)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
        }

        infoStackView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(Spacing.md)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
            make.bottom.equalToSuperview().inset(Spacing.md)
            make.height.equalTo(70)
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

        accountCountView.configure(title: "계좌", value: "\(accountCount)개", accentColor: .kidkBlue)
        dailyLimitView.configure(title: "일일 한도", value: dailyLimit.formattedCurrency, accentColor: .kidkPink)
        levelView.configure(title: "레벨", value: "Lv.\(userLevel) · EXP \(experience)", accentColor: .kidkGreen)

        accessibilityLabel = "총 자산 \(totalBalance.formattedCurrency), 주 계좌 \(primaryAccountName), 계좌 \(accountCount)개"
    }
}

private final class WalletInfoItemView: UIView {

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

    func configure(title: String, value: String, accentColor: UIColor) {
        titleLabel.text = title
        valueLabel.text = value
        valueLabel.textColor = accentColor
    }
}

private final class WalletAccountCell: UITableViewCell {

    static let identifier = "WalletAccountCell"

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
        imageView.tintColor = .kidkTextWhite
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .kidkFont(.s16, .bold)
        label.textColor = .kidkTextWhite
        return label
    }()

    private let typeLabel: UILabel = {
        let label = UILabel()
        label.font = .kidkFont(.s12, .regular)
        label.textColor = .kidkGray
        return label
    }()

    private let primaryBadge: UILabel = {
        let label = UILabel()
        label.font = .kidkFont(.s12, .bold)
        label.textColor = .kidkPink
        label.text = "주 계좌"
        label.textAlignment = .center
        label.backgroundColor = .kidkPink.withAlphaComponent(0.16)
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.isHidden = true
        return label
    }()

    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = .kidkFont(.s18, .bold)
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

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(containerView)
        containerView.addSubview(iconBackgroundView)
        iconBackgroundView.addSubview(iconImageView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(typeLabel)
        containerView.addSubview(primaryBadge)
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
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(Spacing.sm)
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

        primaryBadge.snp.makeConstraints { make in
            make.leading.equalTo(typeLabel.snp.trailing).offset(8)
            make.centerY.equalTo(typeLabel)
            make.height.equalTo(20)
            make.width.greaterThanOrEqualTo(46)
        }
    }

    func configure(with account: Account) {
        nameLabel.text = account.name
        typeLabel.text = account.type.displayName
        amountLabel.text = account.formattedBalance
        amountLabel.textColor = account.isPrimary ? .kidkGreen : .kidkTextWhite

        primaryBadge.isHidden = !account.isPrimary

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

private final class WalletQuickActionsCell: UITableViewCell {

    static let identifier = "WalletQuickActionsCell"

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .cardBackground
        view.layer.cornerRadius = CornerRadius.large
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        return view
    }()

    private let stackView: UIStackView = {
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
        containerView.addSubview(stackView)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16))
        }

        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(Spacing.sm)
        }
    }

    private func setupButtons() {
        actions.enumerated().forEach { index, action in
            let button = QuickActionButton(action: action)
            button.tag = index
            button.addTarget(self, action: #selector(actionTapped(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
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

private final class WalletCardCell: UITableViewCell {

    static let identifier = "WalletCardCell"

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .cardBackground
        view.layer.cornerRadius = CornerRadius.large
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        return view
    }()

    private let cardImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .kidkFont(.s14, .medium)
        label.textColor = .kidkGray
        return label
    }()

    private let cardTypeLabel: UILabel = {
        let label = UILabel()
        label.font = .kidkFont(.s16, .bold)
        label.textColor = .kidkTextWhite
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
        selectionStyle = .none

        contentView.addSubview(containerView)
        containerView.addSubview(cardImageView)
        containerView.addSubview(cardTypeLabel)
        containerView.addSubview(statusLabel)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16))
        }

        cardImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Spacing.sm)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(72)
        }

        cardTypeLabel.snp.makeConstraints { make in
            make.leading.equalTo(cardImageView.snp.trailing).offset(Spacing.sm)
            make.top.equalTo(cardImageView).offset(8)
            make.trailing.equalToSuperview().inset(Spacing.sm)
        }

        statusLabel.snp.makeConstraints { make in
            make.leading.equalTo(cardTypeLabel)
            make.top.equalTo(cardTypeLabel.snp.bottom).offset(6)
            make.trailing.equalTo(cardTypeLabel)
        }
    }

    func configure(with card: Card) {
        cardImageView.image = UIImage(named: card.characterImageName)
        cardTypeLabel.text = card.isPhysicalCard ? "실물 카드 발급 완료" : "디지털 카드"
        statusLabel.text = card.statusDescription
    }
}
