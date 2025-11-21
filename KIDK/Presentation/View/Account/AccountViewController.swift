//
//  AccountViewController.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/14/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class AccountViewController: BaseViewController {

    private let viewModel: AccountViewModel

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()

    private let contentView = UIView()

    private let profileView: UIView = {
        let view = UIView()
        return view
    }()

    private let profileImageView = ProfileImageView(
        assetName: "kidk_profile_one",
        size: 40,
        bgColor: .white,
        iconRatio: 0.7
    )

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(
            text: "김시아",
            size: .s24,
            weight: .bold,
            color: .kidkTextWhite,
            lineHeight: 140
        )
        return label
    }()

    private let cardsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Spacing.md
        return stackView
    }()

    private var newMissionCard: AccountCardView?
    private var spendingAccountCard: AccountCardView?
    private var savingsAccountCard: AccountCardView?
    private var monthlyReportCard: AccountCardView?
    private let monthlyProgressBar = CategoryProgressBarView()

    private var reportData: MonthlyReportCardData?

    init(viewModel: AccountViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCards()
        bind()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureProgressBar()
    }

    private func setupUI() {
        view.backgroundColor = UIColor(hex: "#1C1C1E")

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(profileView)
        profileView.addSubview(profileImageView)
        profileView.addSubview(nameLabel)

        contentView.addSubview(cardsStackView)

        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }

        profileView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Spacing.md)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
            make.height.equalTo(50)
        }

        profileImageView.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }

        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(profileImageView.snp.trailing).offset(Spacing.xs)
            make.centerY.equalToSuperview()
        }

        cardsStackView.snp.makeConstraints { make in
            make.top.equalTo(profileView.snp.bottom).offset(Spacing.md)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
            make.bottom.equalToSuperview().offset(-Spacing.md)
        }
    }

    private func setupCards() {
        let missionData = MissionCardData(
            iconName: "kidk_icon_mission_new",
            title: "새로운 미션이 있어요!",
            subtitle: "책 30분 읽고 1000원 받기",
            buttonTitle: "미션 하러 가기"
        )
        newMissionCard = AccountCardFactory.makeNewMissionCard(data: missionData)

        let spendingData = AccountCardData(
            iconName: "kidk_icon_wallet",
            title: "내 지갑",
            amount: 12450,
            message: nil
        )
        spendingAccountCard = AccountCardFactory.makeSpendingAccountCard(data: spendingData)

        let savingsData = AccountCardData(
            iconName: "kidk_icon_piggy",
            title: "내 저금통",
            amount: 50000,
            message: "친구들과 함께 저축 목표를 설정해보세요!"
        )
        savingsAccountCard = AccountCardFactory.makeSavingsAccountCard(data: savingsData)

        let categories = [
            CategorySpending(category: "음식", amount: 12000, totalAmount: 20000, color: .kidkPink),
            CategorySpending(category: "쇼핑", amount: 5000, totalAmount: 20000, color: .kidkGreen),
            CategorySpending(category: "교통", amount: 3000, totalAmount: 20000, color: .kidkBlue)
        ]
        reportData = MonthlyReportCardData(
            month: 5,
            totalAmount: 20000,
            categories: categories
        )
        monthlyReportCard = AccountCardFactory.makeMonthlyReportCard(
            data: reportData!,
            progressBarView: monthlyProgressBar
        )

        if let card = newMissionCard {
            cardsStackView.addArrangedSubview(card)
        }
        if let card = spendingAccountCard {
            cardsStackView.addArrangedSubview(card)
        }
        if let card = savingsAccountCard {
            cardsStackView.addArrangedSubview(card)
        }
        if let card = monthlyReportCard {
            cardsStackView.addArrangedSubview(card)
        }
    }

    private func configureProgressBar() {
        guard let data = reportData else { return }
        monthlyProgressBar.configure(with: data.categories, animated: true)
    }

    private func bind() {
        newMissionCard?.closeButtonTapped
            .subscribe(onNext: { [weak self] in
                self?.removeCard(self?.newMissionCard)
            })
            .disposed(by: disposeBag)

        newMissionCard?.cardTapped
            .subscribe(onNext: {
                print("New mission card tapped")
            })
            .disposed(by: disposeBag)

        spendingAccountCard?.cardTapped
            .subscribe(onNext: { [weak self] in
                self?.navigateToWallet()
            })
            .disposed(by: disposeBag)

        savingsAccountCard?.cardTapped
            .subscribe(onNext: { [weak self] in
                self?.navigateToSavings()
            })
            .disposed(by: disposeBag)

        monthlyReportCard?.cardTapped
            .subscribe(onNext: {
                print("Monthly report tapped")
            })
            .disposed(by: disposeBag)
    }

    private func removeCard(_ card: AccountCardView?) {
        guard let card = card else { return }

        UIView.animate(withDuration: 0.3, animations: {
            card.alpha = 0
            card.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in
            self.cardsStackView.removeArrangedSubview(card)
            card.removeFromSuperview()
        }
    }

    private func navigateToWallet() {
        let walletViewModel = WalletViewModel()
        let walletVC = WalletViewController(viewModel: walletViewModel)
        navigationController?.pushViewController(walletVC, animated: true)
    }

    private func navigateToSavings() {
        let savingsViewModel = SavingsViewModel(user: viewModel.user)
        let savingsVC = SavingsViewController(viewModel: savingsViewModel)
        navigationController?.pushViewController(savingsVC, animated: true)
    }
}
