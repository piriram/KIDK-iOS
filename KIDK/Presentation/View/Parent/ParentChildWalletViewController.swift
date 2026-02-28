import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class ParentChildWalletViewController: BaseViewController, NavigationChromeConfigurable {

    // MARK: - Properties

    private let viewModel: ParentChildWalletViewModel
    private let refreshTrigger = PublishRelay<Void>()
    private let navigationHeaderView = KIDKNavigationHeaderView(title: "아이 지갑")

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

    private let refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.tintColor = .kidkPink
        return control
    }()

    private let childInfoHeaderView = ChildInfoHeaderView()
    private let assetSectionHeader = ParentTimelineSectionHeaderView()

    private let balanceCardView = ParentTimelineCardView(accentColor: .kidkGreen)

    private let balanceTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "총 잔액"
        label.font = UIFont.kidkFont(.s14, .medium)
        label.textColor = .kidkGray
        return label
    }()

    private let totalAmountLabel: UILabel = {
        let label = UILabel()
        label.text = "0원"
        label.font = UIFont.kidkFont(.s32, .bold)
        label.textColor = .kidkGreen
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.78
        return label
    }()

    private let accountDistributionProgressView = ParentTimelineProgressRowView()

    private let accountsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Spacing.xs
        return stackView
    }()

    private let transactionsSectionHeader = ParentTimelineSectionHeaderView()
    private let transactionsCardView = ParentTimelineCardView(accentColor: .kidkPink)

    private let transactionsGuideLabel: UILabel = {
        let label = UILabel()
        label.text = "입출금 흐름을 최신 순으로 확인할 수 있어요"
        label.font = UIFont.kidkFont(.s12, .regular)
        label.textColor = .kidkGray
        return label
    }()

    private let transactionsTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 96
        tableView.register(TransactionCell.self, forCellReuseIdentifier: TransactionCell.identifier)
        return tableView
    }()

    private let emptyTransactionsLabel: UILabel = {
        let label = UILabel()
        label.text = "최근 거래가 아직 없어요"
        label.font = UIFont.kidkFont(.s14, .medium)
        label.textColor = .kidkGray
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    // MARK: - Initialization

    init(viewModel: ParentChildWalletViewModel) {
        self.viewModel = viewModel
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
        let isCompact = view.bounds.width <= 360
        childInfoHeaderView.setCompactLayout(isCompact)
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .kidkDarkBackground

        view.addSubview(navigationHeaderView)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        scrollView.refreshControl = refreshControl

        let balanceContentStack = UIStackView(arrangedSubviews: [balanceTitleLabel, totalAmountLabel, accountDistributionProgressView, accountsStackView])
        balanceContentStack.axis = .vertical
        balanceContentStack.spacing = Spacing.xs
        balanceCardView.contentView.addSubview(balanceContentStack)

        transactionsCardView.contentView.addSubview(transactionsGuideLabel)
        transactionsCardView.contentView.addSubview(transactionsTableView)
        transactionsCardView.contentView.addSubview(emptyTransactionsLabel)

        stackView.addArrangedSubview(childInfoHeaderView)
        stackView.addArrangedSubview(assetSectionHeader)
        stackView.addArrangedSubview(balanceCardView)
        stackView.addArrangedSubview(transactionsSectionHeader)
        stackView.addArrangedSubview(transactionsCardView)

        stackView.setCustomSpacing(Spacing.sm, after: assetSectionHeader)
        stackView.setCustomSpacing(Spacing.sm, after: transactionsSectionHeader)

        assetSectionHeader.configure(
            step: "STEP 2",
            title: "자산 타임라인",
            subtitle: "잔액 변화를 계좌별로 나눠서 확인해요"
        )

        transactionsSectionHeader.configure(
            step: "STEP 3",
            title: "최근 거래 타임라인",
            subtitle: "아이 지갑에서 일어난 변화를 시간순으로 읽어보세요"
        )

        navigationHeaderView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(KIDKNavigationHeaderView.height)
        }

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(navigationHeaderView.snp.bottom)
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }

        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(Spacing.md)
        }

        balanceContentStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        transactionsGuideLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        transactionsTableView.snp.makeConstraints { make in
            make.top.equalTo(transactionsGuideLabel.snp.bottom).offset(Spacing.xs)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(0)
            make.bottom.equalToSuperview()
        }

        emptyTransactionsLabel.snp.makeConstraints { make in
            make.top.equalTo(transactionsGuideLabel.snp.bottom).offset(Spacing.sm)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-Spacing.xs)
        }
    }

    // MARK: - Binding

    private func bindViewModel() {
        let input = ParentChildWalletViewModel.Input(
            viewDidLoad: Observable.just(()),
            refreshTriggered: refreshTrigger.asObservable()
        )

        let output = viewModel.transform(input: input)

        output.childInfo
            .drive(onNext: { [weak self] childInfo in
                self?.updateChildInfo(childInfo)
            })
            .disposed(by: disposeBag)

        output.accounts
            .drive(onNext: { [weak self] accounts in
                self?.updateAccounts(accounts)
            })
            .disposed(by: disposeBag)

        output.recentTransactions
            .drive(transactionsTableView.rx.items(cellIdentifier: TransactionCell.identifier, cellType: TransactionCell.self)) { _, transaction, cell in
                cell.configure(with: transaction)
            }
            .disposed(by: disposeBag)

        output.recentTransactions
            .drive(onNext: { [weak self] transactions in
                guard let self = self else { return }
                self.emptyTransactionsLabel.isHidden = !transactions.isEmpty
                self.transactionsTableView.isHidden = transactions.isEmpty

                DispatchQueue.main.async {
                    self.transactionsTableView.layoutIfNeeded()
                    let measuredHeight = transactions.isEmpty ? 0 : self.transactionsTableView.contentSize.height
                    self.transactionsTableView.snp.updateConstraints { make in
                        make.height.equalTo(measuredHeight)
                    }
                    self.view.layoutIfNeeded()
                }
            })
            .disposed(by: disposeBag)

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

        output.error
            .drive(onNext: { [weak self] error in
                self?.showError(message: error.localizedDescription)
            })
            .disposed(by: disposeBag)

        refreshControl.rx.controlEvent(.valueChanged)
            .bind(to: refreshTrigger)
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
        totalAmountLabel.text = childInfo.formattedBalance
    }

    private func updateAccounts(_ accounts: [Account]) {
        accountsStackView.arrangedSubviews.forEach { view in
            accountsStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        for account in accounts {
            let accountRow = createAccountRow(account: account)
            accountsStackView.addArrangedSubview(accountRow)
        }

        let savingsAmount = accounts
            .filter { $0.type == .savings || $0.type == .goal }
            .reduce(0) { $0 + $1.balance }
        let totalAmount = max(accounts.reduce(0) { $0 + $1.balance }, 1)
        let ratio = CGFloat(savingsAmount) / CGFloat(totalAmount)

        accountDistributionProgressView.configure(
            title: "저축 비중",
            valueText: "\(Int((ratio * 100).rounded()))%",
            progress: ratio,
            tintColor: .kidkGreen
        )
    }

    private func createAccountRow(account: Account) -> UIView {
        let containerView = UIView()

        let dotView = UIView()
        dotView.layer.cornerRadius = 4
        dotView.backgroundColor = account.type == .spending ? .kidkPink : .kidkGreen

        let nameLabel = UILabel()
        nameLabel.text = account.type.displayName
        nameLabel.font = UIFont.kidkFont(.s14, .medium)
        nameLabel.textColor = .kidkTextWhite

        let balanceLabel = UILabel()
        balanceLabel.text = account.formattedBalance
        balanceLabel.font = UIFont.kidkFont(.s16, .bold)
        balanceLabel.textColor = .kidkTextWhite
        balanceLabel.textAlignment = .right

        let statusBadge = ParentTimelineStatusBadgeView()
        statusBadge.configure(text: account.type == .spending ? "사용" : "저축", tone: account.type == .spending ? .pink : .green)

        containerView.addSubview(dotView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(balanceLabel)
        containerView.addSubview(statusBadge)

        dotView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.size.equalTo(8)
        }

        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(dotView.snp.trailing).offset(Spacing.xs)
            make.top.equalToSuperview().offset(Spacing.xxs)
        }

        balanceLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel)
            make.trailing.equalToSuperview()
            make.leading.greaterThanOrEqualTo(nameLabel.snp.trailing).offset(Spacing.xs)
        }

        statusBadge.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.leading.equalTo(nameLabel)
            make.bottom.equalToSuperview().offset(-Spacing.xxs)
        }

        containerView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(58)
        }

        return containerView
    }
}
