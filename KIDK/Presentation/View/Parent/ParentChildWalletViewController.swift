import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class ParentChildWalletViewController: BaseViewController {

    // MARK: - Properties

    private let viewModel: ParentChildWalletViewModel
    private let refreshTrigger = PublishRelay<Void>()

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
        stackView.spacing = Spacing.lg
        return stackView
    }()

    private let refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.tintColor = .kidkPink
        return control
    }()

    private let childInfoHeaderView = ChildInfoHeaderView()

    private let balanceCardView: AccountCardView = {
        let cardView = AccountCardView()
        return cardView
    }()

    private let balanceContentView = UIView()

    private let balanceTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "💰 총 잔액"
        label.font = .kidkFont(.s18, .bold)
        label.textColor = .kidkTextWhite
        return label
    }()

    private let totalAmountLabel: UILabel = {
        let label = UILabel()
        label.text = "0원"
        label.font = .kidkFont(.s32, .bold)
        label.textColor = .kidkGreen
        return label
    }()

    private let accountsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Spacing.xs
        return stackView
    }()

    private let transactionsSectionHeader = SectionHeaderView()

    private let transactionsTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.register(TransactionCell.self, forCellReuseIdentifier: TransactionCell.identifier)
        return tableView
    }()

    // MARK: - Initialization

    init(viewModel: ParentChildWalletViewModel) {
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
        bindViewModel()
    }

    // MARK: - Setup

    private func setupNavigationBar() {
        title = "아이 지갑"
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        scrollView.refreshControl = refreshControl

        // Add views to stack
        stackView.addArrangedSubview(childInfoHeaderView)
        stackView.addArrangedSubview(balanceCardView)
        stackView.addArrangedSubview(transactionsSectionHeader)
        stackView.addArrangedSubview(transactionsTableView)

        // Setup balance card content
        balanceContentView.addSubview(balanceTitleLabel)
        balanceContentView.addSubview(totalAmountLabel)
        balanceContentView.addSubview(accountsStackView)
        balanceCardView.configure(with: balanceContentView)

        // Configure section header
        transactionsSectionHeader.configure(title: "📋 최근 거래")

        // Layout
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }

        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(Spacing.md)
        }

        balanceTitleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        totalAmountLabel.snp.makeConstraints { make in
            make.top.equalTo(balanceTitleLabel.snp.bottom).offset(Spacing.xs)
            make.leading.trailing.equalToSuperview()
        }

        accountsStackView.snp.makeConstraints { make in
            make.top.equalTo(totalAmountLabel.snp.bottom).offset(Spacing.md)
            make.leading.trailing.bottom.equalToSuperview()
        }

        transactionsTableView.snp.makeConstraints { make in
            make.height.equalTo(0)
        }
    }

    // MARK: - Binding

    private func bindViewModel() {
        let input = ParentChildWalletViewModel.Input(
            viewDidLoad: Observable.just(()),
            refreshTriggered: refreshTrigger.asObservable()
        )

        let output = viewModel.transform(input: input)

        // Child Info
        output.childInfo
            .drive(onNext: { [weak self] childInfo in
                self?.updateChildInfo(childInfo)
            })
            .disposed(by: disposeBag)

        // Accounts
        output.accounts
            .drive(onNext: { [weak self] accounts in
                self?.updateAccounts(accounts)
            })
            .disposed(by: disposeBag)

        // Transactions
        output.recentTransactions
            .drive(transactionsTableView.rx.items(cellIdentifier: TransactionCell.identifier, cellType: TransactionCell.self)) { _, transaction, cell in
                cell.configure(with: transaction)
            }
            .disposed(by: disposeBag)

        output.recentTransactions
            .drive(onNext: { [weak self] transactions in
                let height = CGFloat(transactions.count) * 70
                self?.transactionsTableView.snp.updateConstraints { make in
                    make.height.equalTo(height)
                }
            })
            .disposed(by: disposeBag)

        // Loading
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

        // Error
        output.error
            .drive(onNext: { [weak self] error in
                self?.showError(message: error.localizedDescription)
            })
            .disposed(by: disposeBag)

        // Refresh Control
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
        accountsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for account in accounts {
            let accountRow = createAccountRow(account: account)
            accountsStackView.addArrangedSubview(accountRow)
        }
    }

    private func createAccountRow(account: Account) -> UIView {
        let containerView = UIView()

        let nameLabel = UILabel()
        nameLabel.text = account.type.displayName
        nameLabel.font = .kidkFont(.s14, .medium)
        nameLabel.textColor = .kidkGray

        let balanceLabel = UILabel()
        balanceLabel.text = account.formattedBalance
        balanceLabel.font = .kidkFont(.s16, .bold)
        balanceLabel.textColor = .kidkTextWhite

        containerView.addSubview(nameLabel)
        containerView.addSubview(balanceLabel)

        nameLabel.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
        }

        balanceLabel.snp.makeConstraints { make in
            make.trailing.top.bottom.equalToSuperview()
            make.leading.greaterThanOrEqualTo(nameLabel.snp.trailing).offset(Spacing.sm)
        }

        containerView.snp.makeConstraints { make in
            make.height.equalTo(24)
        }

        return containerView
    }
}
