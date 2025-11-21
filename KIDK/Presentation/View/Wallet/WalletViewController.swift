
  WalletViewController.swift
  KIDK

  Created by 잠만보김쥬디 on 11/19/25.


import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class WalletViewController: BaseViewController {
    
    // MARK: - Properties
    private let viewModel: WalletViewModel
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = UIColor(hex: "#1C1C1E")
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
    
    private let refreshControl = UIRefreshControl()
    
    // MARK: - Section Types
    private enum Section: Int, CaseIterable {
        case header
        case accounts
        case quickActions
        case savingsGoals
        case transactions
        case card
        
        var title: String? {
            switch self {
            case .header:
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
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.register(TransactionCell.self, forCellReuseIdentifier: TransactionCell.identifier)
        tableView.register(SavingsGoalCell.self, forCellReuseIdentifier: SavingsGoalCell.identifier)
        
        refreshControl.tintColor = .kidkPink
        tableView.refreshControl = refreshControl
    }
    
    private func bind() {
        // Refresh Control
        refreshControl.rx.controlEvent(.valueChanged)
            .subscribe(onNext: { [weak self] in
                self?.viewModel.refreshData()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self?.refreshControl.endRefreshing()
                    self?.tableView.reloadData()
                }
            })
            .disposed(by: disposeBag)
        
        // ViewModel 데이터 변경 감지
        Observable.combineLatest(
            viewModel.accounts.asObservable(),
            viewModel.transactions.asObservable(),
            viewModel.savingsGoals.asObservable()
        )
        .observe(on: MainScheduler.instance)
        .subscribe(onNext: { [weak self] _, _, _ in
            self?.tableView.reloadData()
        })
        .disposed(by: disposeBag)
    }
    
    // MARK: - Actions
    @objc private func quickActionTapped(_ sender: UIButton) {
        let actionType: QuickActionType
        switch sender.tag {
        case 0:
            actionType = .deposit
        case 1:
            actionType = .withdraw
        case 2:
            actionType = .transfer
        case 3:
            actionType = .scanReceipt
        default:
            return
        }
        
        showAlert(title: actionType.title, message: "\(actionType.title) 기능은 준비중입니다.")
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
        case .header:
            return 1
        case .accounts:
            return viewModel.accounts.value.count
        case .quickActions:
            return 1
        case .savingsGoals:
            return min(viewModel.savingsGoals.value.count, 3) // 최대 3개만 표시
        case .transactions:
            return min(viewModel.transactions.value.count, 10) // 최대 10개만 표시
        case .card:
            return viewModel.card.value != nil ? 1 : 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sectionType = Section(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        
        switch sectionType {
        case .header:
            return makeHeaderCell(tableView, indexPath: indexPath)
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
    private func makeHeaderCell(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "HeaderCell")
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        let headerView = UIView()
        
        let profileImageView = ProfileImageView(
            assetName: "kidk_profile_one",
            size: 60,
            bgColor: .white,
            iconRatio: 0.7
        )
        
        let nameLabel = UILabel()
        nameLabel.applyTextStyle(
            text: "김시아",
            size: .s24,
            weight: .bold,
            color: .kidkTextWhite,
            lineHeight: 140
        )
        
        let levelLabel = UILabel()
        levelLabel.text = "Lv. \(viewModel.userLevel.value)"
        levelLabel.font = .spoqaHanSansNeo(size: 16, weight: .bold)
        levelLabel.textColor = .kidkPink
        
        let expProgressView = UIProgressView(progressViewStyle: .default)
        expProgressView.trackTintColor = UIColor(hex: "#2C2C2E")
        expProgressView.progressTintColor = .kidkPink
        expProgressView.progress = Float(viewModel.userExperience.value) / 1000.0
        expProgressView.layer.cornerRadius = 4
        expProgressView.clipsToBounds = true
        
        headerView.addSubview(profileImageView)
        headerView.addSubview(nameLabel)
        headerView.addSubview(levelLabel)
        headerView.addSubview(expProgressView)
        
        cell.contentView.addSubview(headerView)
        
        headerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        
        profileImageView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
            make.width.height.equalTo(60)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(profileImageView.snp.trailing).offset(12)
            make.top.equalToSuperview().offset(8)
        }
        
        levelLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel.snp.trailing).offset(8)
            make.centerY.equalTo(nameLabel)
        }
        
        expProgressView.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel)
            make.trailing.equalToSuperview()
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.height.equalTo(8)
            make.bottom.equalToSuperview()
        }
        
        return cell
    }
    
    private func makeAccountCell(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "AccountCell")
        cell.backgroundColor = UIColor(hex: "#2C2C2E")
        cell.selectionStyle = .none
        
        let account = viewModel.accounts.value[indexPath.row]
        
        cell.textLabel?.text = account.name
        cell.textLabel?.font = .spoqaHanSansNeo(size: 16, weight: .bold)
        cell.textLabel?.textColor = .kidkTextWhite
        
        cell.detailTextLabel?.text = account.formattedBalance
        cell.detailTextLabel?.font = .spoqaHanSansNeo(size: 18, weight: .bold)
        cell.detailTextLabel?.textColor = account.isPrimary ? .kidkGreen : .kidkTextWhite
        
        if account.isPrimary {
            let badge = UILabel()
            badge.text = "주"
            badge.font = .spoqaHanSansNeo(size: 10, weight: .bold)
            badge.textColor = .white
            badge.backgroundColor = .kidkPink
            badge.textAlignment = .center
            badge.layer.cornerRadius = 8
            badge.clipsToBounds = true
            
            cell.contentView.addSubview(badge)
            badge.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(16)
                make.centerY.equalToSuperview()
                make.width.height.equalTo(20)
            }
            
            cell.textLabel?.snp.remakeConstraints { make in
                make.leading.equalTo(badge.snp.trailing).offset(8)
                make.centerY.equalToSuperview()
            }
        }
        
        return cell
    }
    
    private func makeQuickActionsCell(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "QuickActionsCell")
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 12
        
        let actions: [QuickActionType] = [.deposit, .withdraw, .transfer, .scanReceipt]
        
        for (index, action) in actions.enumerated() {
            let button = QuickActionButton(action: action)
            button.tag = index
            button.addTarget(self, action: #selector(quickActionTapped(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }
        
        cell.contentView.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
            make.height.equalTo(100)
        }
        
        return cell
    }
    
    private func makeSavingsGoalCell(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
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
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "CardCell")
        cell.backgroundColor = UIColor(hex: "#2C2C2E")
        cell.selectionStyle = .none
        
        guard let card = viewModel.card.value else { return cell }
        
        let cardView = UIView()
        cardView.backgroundColor = .kidkPink.withAlphaComponent(0.2)
        cardView.layer.cornerRadius = 12
        
        let cardImageView = UIImageView()
        cardImageView.image = UIImage(named: card.characterImageName)
        cardImageView.contentMode = .scaleAspectFit
        
        let statusLabel = UILabel()
        statusLabel.text = card.statusDescription
        statusLabel.font = .spoqaHanSansNeo(size: 14, weight: .medium)
        statusLabel.textColor = .kidkGray
        
        let physicalCardLabel = UILabel()
        physicalCardLabel.text = card.isPhysicalCard ? "실물 카드 발급됨" : "디지털 카드"
        physicalCardLabel.font = .spoqaHanSansNeo(size: 14, weight: .medium)
        physicalCardLabel.textColor = .kidkTextWhite
        
        cell.contentView.addSubview(cardView)
        cardView.addSubview(cardImageView)
        cardView.addSubview(statusLabel)
        cardView.addSubview(physicalCardLabel)
        
        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
            make.height.equalTo(120)
        }
        
        cardImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(80)
        }
        
        physicalCardLabel.snp.makeConstraints { make in
            make.leading.equalTo(cardImageView.snp.trailing).offset(16)
            make.top.equalToSuperview().offset(24)
        }
        
        statusLabel.snp.makeConstraints { make in
            make.leading.equalTo(physicalCardLabel)
            make.top.equalTo(physicalCardLabel.snp.bottom).offset(8)
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
        
        let headerView = SectionHeaderView()
        headerView.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 44)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let sectionType = Section(rawValue: section) else {
            return 0
        }
        
        return sectionType == .header ? 0 : 44
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let sectionType = Section(rawValue: indexPath.section) else {
            return UITableView.automaticDimension
        }
        
        switch sectionType {
        case .header:
            return UITableView.automaticDimension
        case .accounts:
            return 60
        case .quickActions:
            return 116
        case .savingsGoals:
            return UITableView.automaticDimension
        case .transactions:
            return 76
        case .card:
            return 136
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let sectionType = Section(rawValue: indexPath.section) else { return }
        
        switch sectionType {
        case .transactions:
            let transaction = viewModel.transactions.value[indexPath.row]
            showTransactionDetail(transaction)
        case .savingsGoals:
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
