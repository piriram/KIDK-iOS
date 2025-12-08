//
//  TransferViewController.swift
//  KIDK
//
//  송금하기 화면
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class TransferViewController: BaseViewController {

    // MARK: - Properties
    private let transactionRepository: TransactionRepositoryProtocol
    private let accountRepository: AccountRepositoryProtocol
    private var accounts: [Account] = []
    private var fromAccount: Account?
    private var toAccount: Account?

    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.keyboardDismissMode = .interactive
        return scrollView
    }()

    private let contentView = UIView()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "송금하기"
        label.font = .kidkFont(.s24, .bold)
        label.textColor = .kidkTextWhite
        return label
    }()

    // 보내는 계좌 선택
    private let fromAccountLabel: UILabel = {
        let label = UILabel()
        label.text = "보내는 계좌"
        label.font = .kidkFont(.s16, .medium)
        label.textColor = .kidkGray
        return label
    }()

    private let fromAccountButton: UIButton = {
        let button = UIButton()
        button.setTitle("계좌 선택", for: .normal)
        button.setTitleColor(.kidkTextWhite, for: .normal)
        button.titleLabel?.font = .kidkFont(.s16, .medium)
        button.backgroundColor = UIColor(hex: "#2C2C2E")
        button.layer.cornerRadius = 12
        button.contentHorizontalAlignment = .left
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return button
    }()

    // 받는 계좌 선택
    private let toAccountLabel: UILabel = {
        let label = UILabel()
        label.text = "받는 계좌"
        label.font = .kidkFont(.s16, .medium)
        label.textColor = .kidkGray
        return label
    }()

    private let toAccountButton: UIButton = {
        let button = UIButton()
        button.setTitle("계좌 선택", for: .normal)
        button.setTitleColor(.kidkTextWhite, for: .normal)
        button.titleLabel?.font = .kidkFont(.s16, .medium)
        button.backgroundColor = UIColor(hex: "#2C2C2E")
        button.layer.cornerRadius = 12
        button.contentHorizontalAlignment = .left
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return button
    }()

    // 금액 입력
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.text = "송금 금액"
        label.font = .kidkFont(.s16, .medium)
        label.textColor = .kidkGray
        return label
    }()

    private let amountTextField: UITextField = {
        let textField = UITextField()
        textField.font = .kidkFont(.s24, .bold)
        textField.textColor = .kidkPink
        textField.textAlignment = .right
        textField.keyboardType = .numberPad
        textField.placeholder = "0"
        textField.backgroundColor = UIColor(hex: "#2C2C2E")
        textField.layer.cornerRadius = 12

        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.rightView = paddingView
        textField.rightViewMode = .always

        return textField
    }()

    private let wonLabel: UILabel = {
        let label = UILabel()
        label.text = "원"
        label.font = .kidkFont(.s16, .medium)
        label.textColor = .kidkGray
        return label
    }()

    // 메모 입력
    private let memoLabel: UILabel = {
        let label = UILabel()
        label.text = "메모 (선택)"
        label.font = .kidkFont(.s16, .medium)
        label.textColor = .kidkGray
        return label
    }()

    private let memoTextField: UITextField = {
        let textField = UITextField()
        textField.font = .kidkFont(.s16, .regular)
        textField.textColor = .kidkTextWhite
        textField.placeholder = "메모를 입력하세요"
        textField.backgroundColor = UIColor(hex: "#2C2C2E")
        textField.layer.cornerRadius = 12

        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.rightView = paddingView
        textField.rightViewMode = .always

        return textField
    }()

    // 송금 버튼
    private let transferButton: UIButton = {
        let button = UIButton()
        button.setTitle("송금하기", for: .normal)
        button.setTitleColor(.kidkTextWhite, for: .normal)
        button.titleLabel?.font = .kidkFont(.s18, .bold)
        button.backgroundColor = .kidkPink
        button.layer.cornerRadius = 12
        button.isEnabled = false
        button.alpha = 0.5
        return button
    }()

    // MARK: - Initialization
    init(
        transactionRepository: TransactionRepositoryProtocol = TransactionRepository.shared,
        accountRepository: AccountRepositoryProtocol = AccountRepository.shared
    ) {
        self.transactionRepository = transactionRepository
        self.accountRepository = accountRepository
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadAccounts()
        setupActions()
    }

    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = UIColor(hex: "#1C1C1E")
        title = "송금하기"

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        [titleLabel, fromAccountLabel, fromAccountButton,
         toAccountLabel, toAccountButton, amountLabel,
         amountTextField, wonLabel, memoLabel, memoTextField,
         transferButton].forEach {
            contentView.addSubview($0)
        }

        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        fromAccountLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        fromAccountButton.snp.makeConstraints { make in
            make.top.equalTo(fromAccountLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }

        toAccountLabel.snp.makeConstraints { make in
            make.top.equalTo(fromAccountButton.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        toAccountButton.snp.makeConstraints { make in
            make.top.equalTo(toAccountLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }

        amountLabel.snp.makeConstraints { make in
            make.top.equalTo(toAccountButton.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        amountTextField.snp.makeConstraints { make in
            make.top.equalTo(amountLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().inset(20)
            make.trailing.equalTo(wonLabel.snp.leading).offset(-8)
            make.height.equalTo(60)
        }

        wonLabel.snp.makeConstraints { make in
            make.centerY.equalTo(amountTextField)
            make.trailing.equalToSuperview().inset(20)
            make.width.equalTo(30)
        }

        memoLabel.snp.makeConstraints { make in
            make.top.equalTo(amountTextField.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        memoTextField.snp.makeConstraints { make in
            make.top.equalTo(memoLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }

        transferButton.snp.makeConstraints { make in
            make.top.equalTo(memoTextField.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(56)
            make.bottom.equalToSuperview().offset(-24)
        }
    }

    private func setupActions() {
        fromAccountButton.addTarget(self, action: #selector(selectFromAccount), for: .touchUpInside)
        toAccountButton.addTarget(self, action: #selector(selectToAccount), for: .touchUpInside)
        transferButton.addTarget(self, action: #selector(performTransfer), for: .touchUpInside)

        // 금액 입력 감지
        amountTextField.addTarget(self, action: #selector(amountChanged), for: .editingChanged)
    }

    // MARK: - Data Loading
    private func loadAccounts() {
        accountRepository.getAllAccounts()
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] accounts in
                self?.accounts = accounts
                debugLog("Loaded \(accounts.count) accounts for transfer")
            }, onFailure: { error in
                debugError("Failed to load accounts", error: error)
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Actions
    @objc private func selectFromAccount() {
        let alert = UIAlertController(title: "보내는 계좌 선택", message: nil, preferredStyle: .actionSheet)

        for account in accounts {
            let action = UIAlertAction(title: "\(account.name) (\(account.balance.formattedWithComma)원)", style: .default) { [weak self] _ in
                self?.fromAccount = account
                self?.fromAccountButton.setTitle("\(account.name) (\(account.balance.formattedWithComma)원)", for: .normal)
                self?.validateForm()
            }
            alert.addAction(action)
        }

        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }

    @objc private func selectToAccount() {
        let alert = UIAlertController(title: "받는 계좌 선택", message: nil, preferredStyle: .actionSheet)

        for account in accounts where account.id != fromAccount?.id {
            let action = UIAlertAction(title: "\(account.name) (\(account.balance.formattedWithComma)원)", style: .default) { [weak self] _ in
                self?.toAccount = account
                self?.toAccountButton.setTitle("\(account.name)", for: .normal)
                self?.validateForm()
            }
            alert.addAction(action)
        }

        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }

    @objc private func amountChanged() {
        validateForm()
    }

    @objc private func performTransfer() {
        guard let fromAccount = fromAccount,
              let toAccount = toAccount,
              let amountText = amountTextField.text,
              let amount = Int(amountText),
              amount > 0 else {
            return
        }

        // 잔액 확인
        if fromAccount.balance < amount {
            showAlert(title: "잔액 부족", message: "보내는 계좌의 잔액이 부족합니다.")
            return
        }

        // 확인 알림
        let message = "\(fromAccount.name)에서 \(toAccount.name)으로\n\(amount.formattedWithComma)원을 송금하시겠습니까?"
        let alert = UIAlertController(title: "송금 확인", message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "송금", style: .default) { [weak self] _ in
            self?.executeTransfer(from: fromAccount, to: toAccount, amount: amount)
        })

        present(alert, animated: true)
    }

    private func executeTransfer(from: Account, to: Account, amount: Int) {
        let description = memoTextField.text?.isEmpty == false ? memoTextField.text! : "송금"

        showLoading()

        transactionRepository.transfer(
            fromAccountId: from.id,
            toAccountId: to.id,
            amount: amount,
            description: description
        )
        .observe(on: MainScheduler.instance)
        .subscribe(onSuccess: { [weak self] _ in
            self?.hideLoading()
            self?.showSuccessAndDismiss(amount: amount)
        }, onFailure: { [weak self] error in
            self?.hideLoading()
            self?.showAlert(title: "송금 실패", message: "송금 중 오류가 발생했습니다.\n\(error.localizedDescription)")
        })
        .disposed(by: disposeBag)
    }

    private func showSuccessAndDismiss(amount: Int) {
        let alert = UIAlertController(
            title: "송금 완료",
            message: "\(amount.formattedWithComma)원이 송금되었습니다.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })

        present(alert, animated: true)
    }

    // MARK: - Validation
    private func validateForm() {
        let hasFromAccount = fromAccount != nil
        let hasToAccount = toAccount != nil
        let hasValidAmount = {
            guard let text = amountTextField.text,
                  let amount = Int(text) else {
                return false
            }
            return amount > 0
        }()

        let isValid = hasFromAccount && hasToAccount && hasValidAmount

        transferButton.isEnabled = isValid
        transferButton.alpha = isValid ? 1.0 : 0.5
    }
}

// MARK: - Int Extension for Formatting
private extension Int {
    var formattedWithComma: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
