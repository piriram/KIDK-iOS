//
//  ParentChildWalletViewController.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/19/25.
//

import UIKit
import SnapKit

/// Phase 1: 목업 데이터로 아이 지갑 표시
/// Phase 2: 실제 Repository 연동
final class ParentChildWalletViewController: BaseViewController {

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()

    private let contentView = UIView()

    // MARK: - Header Section

    private let headerCard: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#2C2C2E")
        view.layer.cornerRadius = CornerRadius.large
        return view
    }()

    private let profileImageView = ProfileImageView(
        assetName: "kidk_profile_one",
        size: 50,
        bgColor: .white,
        iconRatio: 0.7
    )

    private let childNameLabel: UILabel = {
        let label = UILabel()
        label.text = "김시아"
        label.font = .kidkFont(.s20, .bold)
        label.textColor = .kidkTextWhite
        return label
    }()

    private let levelBadge: UILabel = {
        let label = UILabel()
        label.text = "Lv. 5"
        label.font = .kidkFont(.s14, .bold)
        label.textColor = .white
        label.backgroundColor = .kidkPink
        label.textAlignment = .center
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        return label
    }()

    // MARK: - Total Balance Section

    private let totalBalanceLabel: UILabel = {
        let label = UILabel()
        label.text = "총 잔액"
        label.font = .kidkFont(.s14, .regular)
        label.textColor = .kidkGray
        return label
    }()

    private let totalAmountLabel: UILabel = {
        let label = UILabel()
        label.text = "42,450원"
        label.font = .kidkFont(.s32, .bold)
        label.textColor = .kidkGreen
        return label
    }()

    // MARK: - Accounts Section

    private let accountsSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "계좌 목록"
        label.font = .kidkFont(.s18, .bold)
        label.textColor = .kidkTextWhite
        return label
    }()

    private let accountsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Spacing.sm
        return stackView
    }()

    // MARK: - Recent Transactions Section

    private let transactionsSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "최근 거래"
        label.font = .kidkFont(.s18, .bold)
        label.textColor = .kidkTextWhite
        return label
    }()

    private let transactionsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Spacing.xs
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        loadMockData()
    }

    private func setupNavigationBar() {
        title = "아이 지갑"
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    private func setupUI() {
        view.backgroundColor = .kidkDarkBackground

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(headerCard)
        headerCard.addSubview(profileImageView)
        headerCard.addSubview(childNameLabel)
        headerCard.addSubview(levelBadge)
        headerCard.addSubview(totalBalanceLabel)
        headerCard.addSubview(totalAmountLabel)

        contentView.addSubview(accountsSectionLabel)
        contentView.addSubview(accountsStackView)

        contentView.addSubview(transactionsSectionLabel)
        contentView.addSubview(transactionsStackView)

        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }

        headerCard.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Spacing.md)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
        }

        profileImageView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(Spacing.md)
        }

        childNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(profileImageView.snp.trailing).offset(Spacing.sm)
            make.centerY.equalTo(profileImageView).offset(-8)
        }

        levelBadge.snp.makeConstraints { make in
            make.leading.equalTo(childNameLabel.snp.trailing).offset(Spacing.xs)
            make.centerY.equalTo(childNameLabel)
            make.width.equalTo(50)
            make.height.equalTo(20)
        }

        totalBalanceLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(Spacing.lg)
            make.leading.equalToSuperview().offset(Spacing.md)
        }

        totalAmountLabel.snp.makeConstraints { make in
            make.top.equalTo(totalBalanceLabel.snp.bottom).offset(Spacing.xxs)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
            make.bottom.equalToSuperview().offset(-Spacing.md)
        }

        accountsSectionLabel.snp.makeConstraints { make in
            make.top.equalTo(headerCard.snp.bottom).offset(Spacing.xl)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
        }

        accountsStackView.snp.makeConstraints { make in
            make.top.equalTo(accountsSectionLabel.snp.bottom).offset(Spacing.sm)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
        }

        transactionsSectionLabel.snp.makeConstraints { make in
            make.top.equalTo(accountsStackView.snp.bottom).offset(Spacing.xl)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
        }

        transactionsStackView.snp.makeConstraints { make in
            make.top.equalTo(transactionsSectionLabel.snp.bottom).offset(Spacing.sm)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
            make.bottom.equalToSuperview().offset(-Spacing.xl)
        }
    }

    private func loadMockData() {
        // Mock Accounts
        let accounts = [
            ("용돈 통장", "30,000원", true),
            ("저축 통장", "12,450원", false)
        ]

        for (name, balance, isPrimary) in accounts {
            let accountView = createAccountView(name: name, balance: balance, isPrimary: isPrimary)
            accountsStackView.addArrangedSubview(accountView)
        }

        // Mock Transactions
        let transactions = [
            ("용돈 받음", "+10,000원", "오늘", .kidkGreen),
            ("문구점", "-3,500원", "어제", .systemRed),
            ("저축", "-5,000원", "2일 전", .systemRed),
            ("미션 보상", "+2,000원", "3일 전", .kidkGreen),
            ("아이스크림", "-2,500원", "4일 전", .systemRed)
        ]

        for (title, amount, date, color) in transactions {
            let transactionView = createTransactionView(title: title, amount: amount, date: date, amountColor: color)
            transactionsStackView.addArrangedSubview(transactionView)
        }
    }

    private func createAccountView(name: String, balance: String, isPrimary: Bool) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = UIColor(hex: "#2C2C2E")
        containerView.layer.cornerRadius = CornerRadius.medium

        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.font = .kidkFont(.s16, .medium)
        nameLabel.textColor = .kidkTextWhite

        let balanceLabel = UILabel()
        balanceLabel.text = balance
        balanceLabel.font = .kidkFont(.s18, .bold)
        balanceLabel.textColor = isPrimary ? .kidkGreen : .kidkTextWhite

        containerView.addSubview(nameLabel)
        containerView.addSubview(balanceLabel)

        if isPrimary {
            let badge = UILabel()
            badge.text = "주"
            badge.font = .kidkFont(.s10, .bold)
            badge.textColor = .white
            badge.backgroundColor = .kidkPink
            badge.textAlignment = .center
            badge.layer.cornerRadius = 8
            badge.clipsToBounds = true

            containerView.addSubview(badge)

            badge.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(Spacing.md)
                make.centerY.equalToSuperview()
                make.width.height.equalTo(20)
            }

            nameLabel.snp.makeConstraints { make in
                make.leading.equalTo(badge.snp.trailing).offset(Spacing.xs)
                make.centerY.equalToSuperview()
            }
        } else {
            nameLabel.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(Spacing.md)
                make.centerY.equalToSuperview()
            }
        }

        balanceLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-Spacing.md)
            make.centerY.equalToSuperview()
        }

        containerView.snp.makeConstraints { make in
            make.height.equalTo(60)
        }

        return containerView
    }

    private func createTransactionView(title: String, amount: String, date: String, amountColor: UIColor) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = UIColor(hex: "#2C2C2E")
        containerView.layer.cornerRadius = CornerRadius.small

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .kidkFont(.s16, .medium)
        titleLabel.textColor = .kidkTextWhite

        let dateLabel = UILabel()
        dateLabel.text = date
        dateLabel.font = .kidkFont(.s12, .regular)
        dateLabel.textColor = .kidkGray

        let amountLabel = UILabel()
        amountLabel.text = amount
        amountLabel.font = .kidkFont(.s16, .bold)
        amountLabel.textColor = amountColor

        containerView.addSubview(titleLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(amountLabel)

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Spacing.md)
            make.top.equalToSuperview().offset(Spacing.sm)
        }

        dateLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
            make.bottom.equalToSuperview().offset(-Spacing.sm)
        }

        amountLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-Spacing.md)
            make.centerY.equalToSuperview()
        }

        containerView.snp.makeConstraints { make in
            make.height.equalTo(60)
        }

        return containerView
    }
}
