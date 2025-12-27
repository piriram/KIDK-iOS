import UIKit
import SnapKit
import RxSwift
import RxCocoa

enum TransactionInputType {
    case deposit
    case withdraw

    var title: String {
        switch self {
        case .deposit: return "입금하기"
        case .withdraw: return "출금하기"
        }
    }

    var transactionType: TransactionType {
        switch self {
        case .deposit: return .deposit
        case .withdraw: return .withdrawal
        }
    }
}

final class TransactionInputViewController: BaseViewController {

    // MARK: - Properties
    private let inputType: TransactionInputType
    private let accountRepository: AccountRepositoryProtocol
    private let transactionRepository: TransactionRepositoryProtocol

    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.keyboardDismissMode = .interactive
        return scrollView
    }()

    private let contentView = UIView()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .kidkFont(.s24, .bold)
        label.textColor = .kidkTextWhite
        return label
    }()

    private let amountTextField: UITextField = {
        let textField = UITextField()
        textField.font = .kidkFont(.s32, .bold)
        textField.textColor = .kidkGreen
        textField.textAlignment = .center
        textField.keyboardType = .numberPad
        textField.placeholder = "0"
        textField.backgroundColor = UIColor(hex: "#2C2C2E")
        textField.layer.cornerRadius = CornerRadius.medium
        return textField
    }()

    private let wonLabel: UILabel = {
        let label = UILabel()
        label.text = "원"
        label.font = .kidkFont(.s24, .bold)
        label.textColor = .kidkTextWhite
        return label
    }()

    private let descriptionTextField: UITextField = {
        let textField = UITextField()
        textField.font = .kidkFont(.s16, .regular)
        textField.textColor = .kidkTextWhite
        textField.placeholder = "내용 (선택)"
        textField.backgroundColor = UIColor(hex: "#2C2C2E")
        textField.layer.cornerRadius = CornerRadius.medium
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: Spacing.md, height: 0))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: Spacing.md, height: 0))
        textField.rightViewMode = .always
        return textField
    }()

    private let memoTextField: UITextField = {
        let textField = UITextField()
        textField.font = .kidkFont(.s16, .regular)
        textField.textColor = .kidkTextWhite
        textField.placeholder = "메모 (선택)"
        textField.backgroundColor = UIColor(hex: "#2C2C2E")
        textField.layer.cornerRadius = CornerRadius.medium
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: Spacing.md, height: 0))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: Spacing.md, height: 0))
        textField.rightViewMode = .always
        return textField
    }()

    // 카테고리 선택 (출금 시에만 표시)
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.text = "카테고리 선택"
        label.font = .kidkFont(.s16, .medium)
        label.textColor = .kidkGray
        return label
    }()

    private let categoryScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    private let categoryStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        return stackView
    }()

    private var selectedCategory: TransactionCategory?

    private lazy var confirmButton = KIDKButton(
        title: inputType.title,
        backgroundColor: .kidkPink,
        titleColor: .white,
        font: .kidkFont(.s18, .bold)
    )

    private lazy var cancelButton = KIDKButton(
        title: "취소",
        backgroundColor: .kidkGray,
        titleColor: .white,
        font: .kidkFont(.s18, .bold)
    )

    private let quickAmountStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = Spacing.sm
        return stackView
    }()

    // MARK: - Initialization
    init(
        inputType: TransactionInputType,
        accountRepository: AccountRepositoryProtocol = AccountRepository.shared,
        transactionRepository: TransactionRepositoryProtocol = TransactionRepository.shared
    ) {
        self.inputType = inputType
        self.accountRepository = accountRepository
        self.transactionRepository = transactionRepository
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupQuickAmounts()
        bind()
    }

    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .kidkDarkBackground

        titleLabel.text = inputType.title

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(titleLabel)
        contentView.addSubview(amountTextField)
        contentView.addSubview(wonLabel)
        contentView.addSubview(quickAmountStackView)
        contentView.addSubview(descriptionTextField)
        contentView.addSubview(categoryLabel)
        contentView.addSubview(categoryScrollView)
        categoryScrollView.addSubview(categoryStackView)
        contentView.addSubview(memoTextField)
        contentView.addSubview(confirmButton)
        contentView.addSubview(cancelButton)

        // 출금이 아닐 때는 카테고리 숨김
        categoryLabel.isHidden = (inputType != .withdraw)
        categoryScrollView.isHidden = (inputType != .withdraw)

        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Spacing.lg)
            make.centerX.equalToSuperview()
        }

        amountTextField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Spacing.xl)
            make.leading.trailing.equalToSuperview().inset(Spacing.xl)
            make.height.equalTo(80)
        }

        wonLabel.snp.makeConstraints { make in
            make.trailing.equalTo(amountTextField).offset(-Spacing.md)
            make.centerY.equalTo(amountTextField)
        }

        quickAmountStackView.snp.makeConstraints { make in
            make.top.equalTo(amountTextField.snp.bottom).offset(Spacing.md)
            make.leading.trailing.equalToSuperview().inset(Spacing.xl)
            make.height.equalTo(44)
        }

        descriptionTextField.snp.makeConstraints { make in
            make.top.equalTo(quickAmountStackView.snp.bottom).offset(Spacing.xl)
            make.leading.trailing.equalToSuperview().inset(Spacing.xl)
            make.height.equalTo(56)
        }

        categoryLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionTextField.snp.bottom).offset(Spacing.lg)
            make.leading.equalToSuperview().inset(Spacing.xl)
        }

        categoryScrollView.snp.makeConstraints { make in
            make.top.equalTo(categoryLabel.snp.bottom).offset(Spacing.sm)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(80)
        }

        categoryStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: Spacing.xl, bottom: 0, right: Spacing.xl))
            make.height.equalTo(80)
        }

        memoTextField.snp.makeConstraints { make in
            let topView = inputType == .withdraw ? categoryScrollView : descriptionTextField
            make.top.equalTo(topView.snp.bottom).offset(Spacing.md)
            make.leading.trailing.equalToSuperview().inset(Spacing.xl)
            make.height.equalTo(56)
        }

        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(memoTextField.snp.bottom).offset(Spacing.xxl)
            make.leading.trailing.equalToSuperview().inset(Spacing.xl)
            make.height.equalTo(56)
        }

        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(confirmButton.snp.bottom).offset(Spacing.md)
            make.leading.trailing.equalToSuperview().inset(Spacing.xl)
            make.height.equalTo(56)
            make.bottom.equalToSuperview().offset(-Spacing.xl)
        }
    }

    private func setupQuickAmounts() {
        let amounts: [Int] = [1000, 5000, 10000, 50000]

        for amount in amounts {
            let button = UIButton(type: .system)
            button.setTitle("+\(amount.formattedCurrency)", for: .normal)
            button.titleLabel?.font = .kidkFont(.s14, .medium)
            button.setTitleColor(.kidkTextWhite, for: .normal)
            button.backgroundColor = UIColor(hex: "#2C2C2E")
            button.layer.cornerRadius = CornerRadius.small
            button.tag = amount
            button.addTarget(self, action: #selector(quickAmountTapped(_:)), for: .touchUpInside)
            quickAmountStackView.addArrangedSubview(button)
        }

        // 출금일 때 카테고리 버튼 생성
        if inputType == .withdraw {
            setupCategoryButtons()
        }
    }

    private func setupCategoryButtons() {
        let categories = TransactionCategory.allCases

        for category in categories {
            let button = UIButton(type: .system)
            button.backgroundColor = UIColor(hex: "#2C2C2E")
            button.layer.cornerRadius = CornerRadius.medium
            button.layer.borderWidth = 2
            button.layer.borderColor = UIColor.clear.cgColor

            // 버튼 내용 구성
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = 4
            stackView.alignment = .center
            stackView.isUserInteractionEnabled = false

            let emojiLabel = UILabel()
            emojiLabel.text = category.emoji
            emojiLabel.font = .systemFont(ofSize: 28)

            let nameLabel = UILabel()
            nameLabel.text = category.rawValue
            nameLabel.font = .kidkFont(.s12, .medium)
            nameLabel.textColor = .kidkTextWhite

            stackView.addArrangedSubview(emojiLabel)
            stackView.addArrangedSubview(nameLabel)

            button.addSubview(stackView)
            stackView.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }

            button.tag = categories.firstIndex(of: category) ?? 0
            button.addTarget(self, action: #selector(categoryButtonTapped(_:)), for: .touchUpInside)

            button.snp.makeConstraints { make in
                make.width.equalTo(70)
            }

            categoryStackView.addArrangedSubview(button)
        }
    }

    private func bind() {
        confirmButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.handleConfirm()
            })
            .disposed(by: disposeBag)

        cancelButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Actions
    @objc private func quickAmountTapped(_ sender: UIButton) {
        let amount = sender.tag
        let currentAmount = Int(amountTextField.text ?? "0") ?? 0
        let newAmount = currentAmount + amount
        amountTextField.text = "\(newAmount)"
    }

    @objc private func categoryButtonTapped(_ sender: UIButton) {
        let categories = TransactionCategory.allCases
        selectedCategory = categories[sender.tag]

        // 모든 버튼 초기화
        for case let button as UIButton in categoryStackView.arrangedSubviews {
            button.layer.borderColor = UIColor.clear.cgColor
        }

        // 선택된 버튼 강조
        sender.layer.borderColor = UIColor.kidkPink.cgColor
    }

    private func handleConfirm() {
        guard let amountText = amountTextField.text,
              let amount = Int(amountText),
              amount > 0 else {
            showAlert(title: "오류", message: "금액을 입력해주세요.")
            return
        }

        // 출금일 때 카테고리 필수 선택 체크
        if inputType == .withdraw && selectedCategory == nil {
            showAlert(title: "카테고리 선택", message: "어디에 쓴 돈인지 카테고리를 선택해주세요.")
            return
        }

        // Get primary account
        accountRepository.getPrimaryAccount()
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] account in
                guard let self = self, let account = account else {
                    self?.showAlert(title: "오류", message: "계좌를 찾을 수 없습니다.")
                    return
                }

                // Check balance for withdrawal
                if self.inputType == .withdraw && account.balance < amount {
                    self.showAlert(title: "잔액 부족", message: "출금 가능한 금액이 부족합니다.")
                    return
                }

                self.createTransaction(account: account, amount: amount)
            }, onFailure: { [weak self] error in
                self?.showAlert(title: "오류", message: "계좌 정보를 가져올 수 없습니다.")
            })
            .disposed(by: disposeBag)
    }

    private func createTransaction(account: Account, amount: Int) {
        let descriptionText = descriptionTextField.text?.isEmpty == false ? descriptionTextField.text : nil
        let memo = memoTextField.text?.isEmpty == false ? memoTextField.text : nil

        let newBalance: Int
        if inputType == .deposit {
            newBalance = account.balance + amount
        } else {
            newBalance = account.balance - amount
        }

        transactionRepository.createTransaction(
            accountId: account.id,
            type: inputType.transactionType,
            amount: amount,
            category: selectedCategory,
            description: descriptionText ?? inputType.title,
            memo: memo
        )
        .observe(on: MainScheduler.instance)
        .subscribe(onSuccess: { [weak self] _ in
            guard let self = self else { return }

            // Update account balance
            self.accountRepository.updateAccountBalance(accountId: account.id, newBalance: newBalance)
                .observe(on: MainScheduler.instance)
                .subscribe(onSuccess: { _ in
                    // Post notification
                    NotificationCenter.default.post(name: .transactionCreated, object: nil)

                    self.dismiss(animated: true) {
                        // Show success message
                        if let presentingVC = self.presentingViewController {
                            let alert = UIAlertController(
                                title: "완료",
                                message: "\(self.inputType.title)가 완료되었습니다.",
                                preferredStyle: .alert
                            )
                            alert.addAction(UIAlertAction(title: "확인", style: .default))
                            presentingVC.present(alert, animated: true)
                        }
                    }
                }, onFailure: { [weak self] (error: Error) in
                    self?.showAlert(title: "오류", message: "잔액 업데이트에 실패했습니다.")
                })
                .disposed(by: self.disposeBag)

        }, onFailure: { [weak self] (error: Error) in
            self?.showAlert(title: "오류", message: "거래 생성에 실패했습니다.")
        })
        .disposed(by: disposeBag)
    }
}
