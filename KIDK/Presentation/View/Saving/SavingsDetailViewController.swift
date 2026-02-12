//
//  SavingsDetailViewController.swift
//  KIDK
//
//  저축 목표 상세 화면
//  - 목표 진행률 시각화
//  - 입금/출금 기능
//  - 거래 내역 표시
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class SavingsDetailViewController: BaseViewController {

    // MARK: - Properties

    private let viewModel: SavingsDetailViewModel
    weak var coordinator: SavingsCoordinator?

    // MARK: - UI Components

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()

    private let contentView = UIView()

    // Header Section
    private let headerContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .kidkPink
        view.layer.cornerRadius = CornerRadius.large
        return view
    }()

    private let goalNameLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(
            text: "",
            size: .s24,
            weight: .bold,
            color: .white,
            lineHeight: 140
        )
        return label
    }()

    private let targetDateLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(
            text: "",
            size: .s14,
            weight: .medium,
            color: .white.withAlphaComponent(0.8),
            lineHeight: 140
        )
        return label
    }()

    // Progress Section
    private let progressContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .cardBackground
        view.layer.cornerRadius = CornerRadius.large
        return view
    }()

    private let currentAmountLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(
            text: "0원",
            size: .s32,
            weight: .bold,
            color: .kidkTextWhite,
            lineHeight: 140
        )
        return label
    }()

    private let targetAmountLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(
            text: "목표: 0원",
            size: .s16,
            weight: .medium,
            color: .kidkGray,
            lineHeight: 140
        )
        return label
    }()

    private let progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.progressTintColor = .kidkPink
        progressView.trackTintColor = .kidkGray.withAlphaComponent(0.3)
        progressView.layer.cornerRadius = 4
        progressView.clipsToBounds = true
        return progressView
    }()

    private let progressPercentageLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(
            text: "0%",
            size: .s16,
            weight: .bold,
            color: .kidkPink,
            lineHeight: 140
        )
        return label
    }()

    private let remainingAmountLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(
            text: "남은 금액: 0원",
            size: .s14,
            weight: .medium,
            color: .kidkGray,
            lineHeight: 140
        )
        return label
    }()

    // Action Buttons
    private lazy var depositButton = KIDKButton(
        title: "입금하기",
        backgroundColor: .kidkGreen,
        titleColor: .kidkTextWhite,
        font: .kidkFont(.s16, .bold)
    )

    private lazy var withdrawButton = KIDKButton(
        title: "출금하기",
        backgroundColor: .kidkBlue,
        titleColor: .kidkTextWhite,
        font: .kidkFont(.s16, .bold)
    )

    // Transactions Section
    private let transactionsSectionHeader = SectionHeaderView()

    private let transactionsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Spacing.xs
        return stackView
    }()

    private let emptyTransactionsLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(
            text: "아직 거래 내역이 없어요",
            size: .s16,
            weight: .regular,
            color: .kidkGray,
            lineHeight: 140
        )
        label.textAlignment = .center
        return label
    }()

    // MARK: - Initialization

    init(viewModel: SavingsDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
    }

    // MARK: - Setup UI

    private func setupUI() {
        title = "저축 목표"
        view.backgroundColor = .kidkBackground

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(headerContainer)
        headerContainer.addSubview(goalNameLabel)
        headerContainer.addSubview(targetDateLabel)

        contentView.addSubview(progressContainer)
        progressContainer.addSubview(currentAmountLabel)
        progressContainer.addSubview(targetAmountLabel)
        progressContainer.addSubview(progressView)
        progressContainer.addSubview(progressPercentageLabel)
        progressContainer.addSubview(remainingAmountLabel)

        contentView.addSubview(depositButton)
        contentView.addSubview(withdrawButton)

        contentView.addSubview(transactionsSectionHeader)
        contentView.addSubview(transactionsStackView)
        contentView.addSubview(emptyTransactionsLabel)

        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }

        headerContainer.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Spacing.md)
            make.leading.trailing.equalToSuperview().inset(Spacing.lg)
        }

        goalNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Spacing.lg)
            make.leading.trailing.equalToSuperview().inset(Spacing.lg)
        }

        targetDateLabel.snp.makeConstraints { make in
            make.top.equalTo(goalNameLabel.snp.bottom).offset(Spacing.xs)
            make.leading.trailing.equalToSuperview().inset(Spacing.lg)
            make.bottom.equalToSuperview().offset(-Spacing.lg)
        }

        progressContainer.snp.makeConstraints { make in
            make.top.equalTo(headerContainer.snp.bottom).offset(Spacing.md)
            make.leading.trailing.equalToSuperview().inset(Spacing.lg)
        }

        currentAmountLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Spacing.lg)
            make.leading.equalToSuperview().inset(Spacing.lg)
        }

        targetAmountLabel.snp.makeConstraints { make in
            make.top.equalTo(currentAmountLabel.snp.bottom).offset(Spacing.xxs)
            make.leading.equalToSuperview().inset(Spacing.lg)
        }

        progressView.snp.makeConstraints { make in
            make.top.equalTo(targetAmountLabel.snp.bottom).offset(Spacing.md)
            make.leading.trailing.equalToSuperview().inset(Spacing.lg)
            make.height.equalTo(8)
        }

        progressPercentageLabel.snp.makeConstraints { make in
            make.top.equalTo(progressView.snp.bottom).offset(Spacing.xs)
            make.leading.equalToSuperview().inset(Spacing.lg)
        }

        remainingAmountLabel.snp.makeConstraints { make in
            make.centerY.equalTo(progressPercentageLabel)
            make.trailing.equalToSuperview().inset(Spacing.lg)
            make.bottom.equalToSuperview().offset(-Spacing.lg)
        }

        depositButton.snp.makeConstraints { make in
            make.top.equalTo(progressContainer.snp.bottom).offset(Spacing.md)
            make.leading.equalToSuperview().inset(Spacing.lg)
            make.trailing.equalTo(view.snp.centerX).offset(-Spacing.xs)
            make.height.equalTo(56)
        }

        withdrawButton.snp.makeConstraints { make in
            make.top.equalTo(depositButton)
            make.leading.equalTo(view.snp.centerX).offset(Spacing.xs)
            make.trailing.equalToSuperview().inset(Spacing.lg)
            make.height.equalTo(56)
        }

        transactionsSectionHeader.snp.makeConstraints { make in
            make.top.equalTo(depositButton.snp.bottom).offset(Spacing.lg)
            make.leading.trailing.equalToSuperview().inset(Spacing.lg)
        }

        transactionsStackView.snp.makeConstraints { make in
            make.top.equalTo(transactionsSectionHeader.snp.bottom).offset(Spacing.md)
            make.leading.trailing.equalToSuperview().inset(Spacing.lg)
        }

        emptyTransactionsLabel.snp.makeConstraints { make in
            make.top.equalTo(transactionsStackView.snp.bottom).offset(Spacing.md)
            make.leading.trailing.equalToSuperview().inset(Spacing.lg)
            make.bottom.equalToSuperview().offset(-Spacing.lg)
            make.height.equalTo(100)
        }

        transactionsSectionHeader.configure(title: "거래 내역", subtitle: nil)
    }

    // MARK: - Bind

    private func bind() {
        let viewDidLoadTrigger = rx.sentMessage(#selector(UIViewController.viewDidLoad))
            .map { _ in () }
            .asObservable()

        let input = SavingsDetailViewModel.Input(
            viewDidLoad: viewDidLoadTrigger,
            depositTapped: depositButton.rx.tap.asObservable(),
            withdrawTapped: withdrawButton.rx.tap.asObservable()
        )

        let output = viewModel.transform(input: input)

        // 목표 정보 표시
        output.savingsGoal
            .drive(onNext: { [weak self] goal in
                self?.updateGoalInfo(goal)
            })
            .disposed(by: disposeBag)

        // 거래 내역 표시
        output.transactions
            .drive(onNext: { [weak self] transactions in
                self?.updateTransactions(transactions)
            })
            .disposed(by: disposeBag)

        // 로딩 상태
        output.isLoading
            .drive(onNext: { [weak self] isLoading in
                if isLoading {
                    self?.showLoading()
                } else {
                    self?.hideLoading()
                }
            })
            .disposed(by: disposeBag)

        // 에러 처리
        output.error
            .drive(onNext: { [weak self] error in
                self?.showError(message: error)
            })
            .disposed(by: disposeBag)

        // 입금 성공
        viewModel.depositSuccess
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] amount in
                self?.showSuccess(message: "\(amount.formattedCurrency)원이 입금되었습니다!")
            })
            .disposed(by: disposeBag)

        // 출금 성공
        viewModel.withdrawSuccess
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] amount in
                self?.showSuccess(message: "\(amount.formattedCurrency)원이 출금되었습니다!")
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Private Methods

    private func updateGoalInfo(_ goal: SavingsGoal) {
        goalNameLabel.text = goal.name
        currentAmountLabel.text = goal.formattedCurrentAmount
        targetAmountLabel.text = "목표: \(goal.formattedTargetAmount)"
        remainingAmountLabel.text = "남은 금액: \(goal.formattedRemainingAmount)"

        progressView.setProgress(Float(goal.progress), animated: true)
        progressPercentageLabel.text = String(format: "%.1f%%", goal.progressPercentage)

        if let targetDate = goal.formattedTargetDate {
            if let daysRemaining = goal.daysRemaining {
                targetDateLabel.text = "\(targetDate) (D-\(daysRemaining))"
            } else {
                targetDateLabel.text = targetDate
            }
        } else {
            targetDateLabel.text = "목표 날짜 없음"
        }

        // 완료된 목표면 출금 버튼 비활성화
        withdrawButton.isEnabled = goal.currentAmount > 0
        depositButton.isEnabled = goal.status == .inProgress
    }

    private func updateTransactions(_ transactions: [SavingsTransaction]) {
        transactionsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        if transactions.isEmpty {
            emptyTransactionsLabel.isHidden = false
        } else {
            emptyTransactionsLabel.isHidden = true

            transactions.forEach { transaction in
                let transactionView = createTransactionView(transaction)
                transactionsStackView.addArrangedSubview(transactionView)
            }
        }
    }

    private func createTransactionView(_ transaction: SavingsTransaction) -> UIView {
        let container = UIView()
        container.backgroundColor = .cardBackground
        container.layer.cornerRadius = CornerRadius.medium

        let dateLabel = UILabel()
        dateLabel.applyTextStyle(
            text: transaction.date.formattedFullDate,
            size: .s14,
            weight: .medium,
            color: .kidkGray,
            lineHeight: 140
        )

        let sourceLabel = UILabel()
        sourceLabel.applyTextStyle(
            text: transaction.source,
            size: .s16,
            weight: .medium,
            color: .kidkTextWhite,
            lineHeight: 140
        )

        let amountLabel = UILabel()
        amountLabel.applyTextStyle(
            text: transaction.formattedAmount,
            size: .s16,
            weight: .bold,
            color: .kidkGreen,
            lineHeight: 140
        )

        container.addSubview(dateLabel)
        container.addSubview(sourceLabel)
        container.addSubview(amountLabel)

        dateLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(Spacing.md)
        }

        sourceLabel.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(Spacing.xxs)
            make.leading.equalToSuperview().inset(Spacing.md)
            make.bottom.equalToSuperview().offset(-Spacing.md)
        }

        amountLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(Spacing.md)
        }

        return container
    }

    private func showSuccess(message: String) {
        let alert = UIAlertController(
            title: "성공",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}
