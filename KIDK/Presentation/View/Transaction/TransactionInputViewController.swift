//
//  TransactionInputViewController.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/19/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class TransactionInputViewController: BaseViewController {

    private let viewModel: TransactionInputViewModel
    private let transactionType: TransactionType
    private let accounts: [Account]

    private let selectedAccountRelay: BehaviorRelay<Account>
    private let memoRelay = BehaviorRelay<String?>(value: nil)

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.keyboardDismissMode = .interactive
        return scrollView
    }()

    private let contentView = UIView()

    private lazy var amountInputView: AmountInputView = {
        let view = AmountInputView()
        return view
    }()

    private lazy var categorySelectorView: CategorySelectorView = {
        let view = CategorySelectorView()
        return view
    }()

    private let accountSelectorLabel: UILabel = {
        let label = UILabel()
        label.text = "계좌 선택"
        label.font = .kidkFont(.s16, .bold)
        label.textColor = .kidkTextWhite
        return label
    }()

    private let accountStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Spacing.xs
        return stackView
    }()

    private let memoTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "메모 (선택)"
        textField.font = .kidkFont(.s16, .regular)
        textField.textColor = .kidkTextWhite
        textField.backgroundColor = UIColor(hex: "#2C2C2E")
        textField.layer.cornerRadius = CornerRadius.medium
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: Spacing.md, height: 0))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: Spacing.md, height: 0))
        textField.rightViewMode = .always
        textField.attributedPlaceholder = NSAttributedString(
            string: "예: 떡볶이, 연필 3자루",
            attributes: [.foregroundColor: UIColor.kidkGray]
        )
        return textField
    }()

    private let keypadView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#1C1C1E")
        return view
    }()

    private lazy var confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("확인", for: .normal)
        button.titleLabel?.font = .kidkFont(.s18, .bold)
        button.setTitleColor(.kidkTextWhite, for: .normal)
        button.backgroundColor = .kidkPink
        button.layer.cornerRadius = CornerRadius.large
        button.isEnabled = false
        return button
    }()

    init(
        viewModel: TransactionInputViewModel,
        transactionType: TransactionType,
        accounts: [Account]
    ) {
        self.viewModel = viewModel
        self.transactionType = transactionType
        self.accounts = accounts

        let primaryAccount = accounts.first(where: { $0.isPrimary }) ?? accounts.first!
        self.selectedAccountRelay = BehaviorRelay<Account>(value: primaryAccount)

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeypad()
        setupAccountSelector()
        bind()
    }

    private func setupUI() {
        view.backgroundColor = .kidkDarkBackground
        title = transactionType.displayName

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "닫기",
            style: .plain,
            target: self,
            action: #selector(closeTapped)
        )

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        view.addSubview(keypadView)
        view.addSubview(confirmButton)

        contentView.addSubview(amountInputView)
        contentView.addSubview(accountSelectorLabel)
        contentView.addSubview(accountStackView)
        contentView.addSubview(memoTextField)

        if transactionType == .withdrawal {
            contentView.addSubview(categorySelectorView)
        }

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(keypadView.snp.top)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }

        amountInputView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Spacing.lg)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(100)
        }

        if transactionType == .withdrawal {
            categorySelectorView.snp.makeConstraints { make in
                make.top.equalTo(amountInputView.snp.bottom).offset(Spacing.xl)
                make.leading.trailing.equalToSuperview().inset(Spacing.md)
                make.height.equalTo(200)
            }

            accountSelectorLabel.snp.makeConstraints { make in
                make.top.equalTo(categorySelectorView.snp.bottom).offset(Spacing.xl)
                make.leading.trailing.equalToSuperview().inset(Spacing.md)
            }
        } else {
            accountSelectorLabel.snp.makeConstraints { make in
                make.top.equalTo(amountInputView.snp.bottom).offset(Spacing.xl)
                make.leading.trailing.equalToSuperview().inset(Spacing.md)
            }
        }

        accountStackView.snp.makeConstraints { make in
            make.top.equalTo(accountSelectorLabel.snp.bottom).offset(Spacing.md)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
        }

        memoTextField.snp.makeConstraints { make in
            make.top.equalTo(accountStackView.snp.bottom).offset(Spacing.xl)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
            make.height.equalTo(48)
            make.bottom.equalToSuperview().offset(-Spacing.xl)
        }

        keypadView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(confirmButton.snp.top).offset(-Spacing.md)
            make.height.equalTo(280)
        }

        confirmButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-Spacing.md)
            make.height.equalTo(56)
        }
    }

    private func setupKeypad() {
        let buttonTitles = [
            ["1", "2", "3"],
            ["4", "5", "6"],
            ["7", "8", "9"],
            ["00", "0", "⌫"]
        ]

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Spacing.sm
        stackView.distribution = .fillEqually

        for row in buttonTitles {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = Spacing.sm
            rowStack.distribution = .fillEqually

            for title in row {
                let button = makeKeypadButton(title: title)
                rowStack.addArrangedSubview(button)
            }

            stackView.addArrangedSubview(rowStack)
        }

        keypadView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(Spacing.md)
        }
    }

    private func makeKeypadButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 24, weight: .medium)
        button.setTitleColor(.kidkTextWhite, for: .normal)
        button.backgroundColor = UIColor(hex: "#2C2C2E")
        button.layer.cornerRadius = CornerRadius.medium

        button.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.handleKeypadTap(title: title)
            })
            .disposed(by: disposeBag)

        return button
    }

    private func handleKeypadTap(title: String) {
        switch title {
        case "⌫":
            amountInputView.deleteDigit()
        case "00":
            amountInputView.addDigit(0)
            amountInputView.addDigit(0)
        default:
            if let digit = Int(title) {
                amountInputView.addDigit(digit)
            }
        }

        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func setupAccountSelector() {
        for (index, account) in accounts.enumerated() {
            let button = makeAccountButton(account: account, index: index)
            accountStackView.addArrangedSubview(button)
        }
    }

    private func makeAccountButton(account: Account, index: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(hex: "#2C2C2E")
        button.layer.cornerRadius = CornerRadius.medium
        button.contentHorizontalAlignment = .left

        let radioView = UIView()
        radioView.layer.cornerRadius = 10
        radioView.layer.borderWidth = 2
        radioView.layer.borderColor = UIColor.kidkGray.cgColor
        radioView.isUserInteractionEnabled = false

        let nameLabel = UILabel()
        nameLabel.text = account.name
        nameLabel.font = .kidkFont(.s16, .medium)
        nameLabel.textColor = .kidkTextWhite
        nameLabel.isUserInteractionEnabled = false

        let balanceLabel = UILabel()
        balanceLabel.text = account.formattedBalance
        balanceLabel.font = .kidkFont(.s14, .regular)
        balanceLabel.textColor = .kidkGray
        balanceLabel.isUserInteractionEnabled = false

        button.addSubview(radioView)
        button.addSubview(nameLabel)
        button.addSubview(balanceLabel)

        radioView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Spacing.md)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }

        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(radioView.snp.trailing).offset(Spacing.sm)
            make.centerY.equalToSuperview()
        }

        balanceLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-Spacing.md)
            make.centerY.equalToSuperview()
        }

        button.snp.makeConstraints { make in
            make.height.equalTo(56)
        }

        button.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.selectAccount(account)
            })
            .disposed(by: disposeBag)

        if account.id == selectedAccountRelay.value.id {
            radioView.backgroundColor = .kidkPink
            radioView.layer.borderColor = UIColor.kidkPink.cgColor
        }

        return button
    }

    private func selectAccount(_ account: Account) {
        selectedAccountRelay.accept(account)

        accountStackView.arrangedSubviews.enumerated().forEach { index, view in
            guard let button = view as? UIButton else { return }
            let radioView = button.subviews.first(where: { $0.layer.cornerRadius == 10 })

            if accounts[index].id == account.id {
                radioView?.backgroundColor = .kidkPink
                radioView?.layer.borderColor = UIColor.kidkPink.cgColor
            } else {
                radioView?.backgroundColor = .clear
                radioView?.layer.borderColor = UIColor.kidkGray.cgColor
            }
        }
    }

    private func bind() {
        let input = TransactionInputViewModel.Input(
            amount: amountInputView.amount,
            category: transactionType == .withdrawal ? categorySelectorView.selectedCategory : .just(nil),
            account: selectedAccountRelay.asObservable(),
            memo: memoTextField.rx.text.asObservable(),
            confirmTapped: confirmButton.rx.tap.asObservable()
        )

        let output = viewModel.transform(input: input)

        output.isConfirmEnabled
            .drive(onNext: { [weak self] isEnabled in
                self?.confirmButton.isEnabled = isEnabled
                self?.confirmButton.alpha = isEnabled ? 1.0 : 0.5
            })
            .disposed(by: disposeBag)

        output.validationError
            .compactMap { $0 }
            .drive(onNext: { [weak self] error in
                self?.showAlert(title: "오류", message: error)
            })
            .disposed(by: disposeBag)

        output.balanceInsufficient
            .compactMap { $0 }
            .drive(onNext: { [weak self] balance in
                let message = "잔액이 부족해요. 저축 통장에서 가져올까요?\n(부족액: \(balance.required - balance.current)원)"
                self?.showAlert(title: "잔액 부족", message: message)
            })
            .disposed(by: disposeBag)

        output.transactionCreated
            .drive(onNext: { [weak self] transaction in
                self?.showSuccessAndDismiss(transaction: transaction)
            })
            .disposed(by: disposeBag)
    }

    private func showSuccessAndDismiss(transaction: Transaction) {
        let message: String
        if transaction.type == .deposit {
            message = "입금이 완료되었어요!"
        } else {
            let comments = ["현명한 소비네요!", "잘 기록했어요!", "계획적인 지출이에요!"]
            message = comments.randomElement() ?? "출금이 완료되었어요!"
        }

        UINotificationFeedbackGenerator().notificationOccurred(.success)

        let alert = UIAlertController(title: "완료", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
        })
        present(alert, animated: true)
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}
