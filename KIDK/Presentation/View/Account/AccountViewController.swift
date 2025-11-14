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

final class AccountViewController: UIViewController {
    
    private let viewModel: AccountViewModel
    private let disposeBag = DisposeBag()
    
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
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "kidk_profile_avatar")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
//        label.setTextWithLineHeight(text: "김시아", font: .spoqaHanSansNeo(size: 24, weight: .bold), lineHeight: 14)
        label.setTextWithLineHeight(text: "김시아", font: .spoqaHanSansNeo(size: 24, weight: .bold), lineHeightPercentage: 140)
        return label
    }()
    
    private let cardsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Spacing.medium
        return stackView
    }()
    
    private lazy var newMissionCard = createNewMissionCard()
    private lazy var spendingAccountCard = createSpendingAccountCard()
    private lazy var savingsAccountCard = createSavingsAccountCard()
    private lazy var monthlyReportCard = createMonthlyReportCard()
    
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
        bind()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(hex: "#1C1C1E")
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(profileView)
        profileView.addSubview(profileImageView)
        profileView.addSubview(nameLabel)
        
        contentView.addSubview(cardsStackView)
        
        cardsStackView.addArrangedSubview(newMissionCard)
        cardsStackView.addArrangedSubview(spendingAccountCard)
        cardsStackView.addArrangedSubview(savingsAccountCard)
        cardsStackView.addArrangedSubview(monthlyReportCard)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }
        
        profileView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Spacing.medium)
            make.leading.trailing.equalToSuperview().inset(Spacing.medium)
            make.height.equalTo(50)
        }
        
        profileImageView.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(profileImageView.snp.trailing).offset(Spacing.small)
            make.centerY.equalToSuperview()
        }
        
        cardsStackView.snp.makeConstraints { make in
            make.top.equalTo(profileView.snp.bottom).offset(Spacing.medium)
            make.leading.trailing.equalToSuperview().inset(Spacing.medium)
            make.bottom.equalToSuperview().offset(-Spacing.medium)
        }
    }
    
    private func bind() {
        newMissionCard.closeButtonTapped
            .subscribe(onNext: { [weak self] in
                self?.removeCard(self?.newMissionCard)
            })
            .disposed(by: disposeBag)
        
        newMissionCard.cardTapped
            .subscribe(onNext: {
                print("New mission card tapped")
            })
            .disposed(by: disposeBag)
        
        spendingAccountCard.cardTapped
            .subscribe(onNext: {
                print("Spending account tapped")
            })
            .disposed(by: disposeBag)
        
        savingsAccountCard.cardTapped
            .subscribe(onNext: {
                print("Savings account tapped")
            })
            .disposed(by: disposeBag)
        
        monthlyReportCard.cardTapped
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
    
    private func createNewMissionCard() -> AccountCardView {
        let card = AccountCardView()
        
        let contentView = UIView()
        
        let iconImageView = UIImageView()
        iconImageView.image = UIImage(named: "kidk_icon_mission_new")
        iconImageView.contentMode = .scaleAspectFit
        
        let titleLabel = UILabel()
        titleLabel.text = "새로운 미션이 있어요!"
        titleLabel.font = .kidkSubtitle
        titleLabel.textColor = .kidkTextWhite
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "책 30분 읽고 1000원 받기"
        subtitleLabel.font = .kidkBody
        subtitleLabel.textColor = .kidkGray
        
        let button = KIDKButton(
            title: "미션 하러 가기",
            backgroundColor: .kidkPink,
            titleColor: .kidkTextWhite,
            fontSize: 16,
            fontWeight: .semibold
        )
        button.isUserInteractionEnabled = false
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(button)
        
        iconImageView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(Spacing.small)
            make.top.equalToSuperview()
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
        }
        
        button.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(subtitleLabel.snp.bottom).offset(Spacing.medium)
            make.bottom.equalToSuperview()
            make.height.equalTo(44)
        }
        
        card.configure(with: contentView, showCloseButton: true)
        return card
    }
    
    private func createSpendingAccountCard() -> AccountCardView {
        let card = AccountCardView()
        
        let contentView = UIView()
        
        let iconImageView = UIImageView()
        iconImageView.image = UIImage(named: "kidk_icon_wallet")
        iconImageView.contentMode = .scaleAspectFit
        
        let titleLabel = UILabel()
        titleLabel.text = "내 지갑"
        titleLabel.font = .kidkBody
        titleLabel.textColor = .kidkGray
        
        let amountLabel = UILabel()
        amountLabel.text = "12,450원"
        amountLabel.font = .kidkTitle
        amountLabel.textColor = .kidkTextWhite
        
        let arrowImageView = UIImageView()
        arrowImageView.image = UIImage(systemName: "chevron.right")
        arrowImageView.tintColor = .kidkGray
        arrowImageView.contentMode = .scaleAspectFit
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(amountLabel)
        contentView.addSubview(arrowImageView)
        
        iconImageView.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(Spacing.small)
            make.top.equalToSuperview()
        }
        
        amountLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.bottom.equalToSuperview()
        }
        
        arrowImageView.snp.makeConstraints { make in
            make.trailing.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        card.configure(with: contentView, showCloseButton: false)
        return card
    }
    
    private func createSavingsAccountCard() -> AccountCardView {
        let card = AccountCardView()
        
        let contentView = UIView()
        
        let iconImageView = UIImageView()
        iconImageView.image = UIImage(named: "kidk_icon_piggy")
        iconImageView.contentMode = .scaleAspectFit
        
        let titleLabel = UILabel()
        titleLabel.text = "내 저금통"
        titleLabel.font = .kidkBody
        titleLabel.textColor = .kidkGray
        
        let amountLabel = UILabel()
        amountLabel.text = "50,000원"
        amountLabel.font = .kidkTitle
        amountLabel.textColor = .kidkTextWhite
        
        let arrowImageView = UIImageView()
        arrowImageView.image = UIImage(systemName: "chevron.right")
        arrowImageView.tintColor = .kidkGray
        arrowImageView.contentMode = .scaleAspectFit
        
        let messageContainer = UIView()
        messageContainer.backgroundColor = UIColor(hex: "#242426")
        messageContainer.layer.cornerRadius = 10
        
        let messageLabel = UILabel()
        messageLabel.text = "친구들과 함께 저축 목표를 설정해보세요!"
        messageLabel.font = .kidkBody
        messageLabel.textColor = .kidkGreen
        messageLabel.numberOfLines = 0
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(amountLabel)
        contentView.addSubview(arrowImageView)
        contentView.addSubview(messageContainer)
        messageContainer.addSubview(messageLabel)
        
        iconImageView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(Spacing.small)
            make.top.equalToSuperview()
        }
        
        amountLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
        }
        
        arrowImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalTo(amountLabel)
            make.width.height.equalTo(20)
        }
        
        messageContainer.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(amountLabel.snp.bottom).offset(Spacing.medium)
            make.bottom.equalToSuperview()
        }
        
        messageLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(Spacing.medium)
        }
        
        card.configure(with: contentView, showCloseButton: false)
        return card
    }
    
    private func createMonthlyReportCard() -> AccountCardView {
        let card = AccountCardView()
        
        let contentView = UIView()
        
        let headerView = UIView()
        
        let questionLabel = UILabel()
        questionLabel.text = "어버덤은 어디에 돈을 많이 사용했을까요?"
        questionLabel.font = .kidkBody
        questionLabel.textColor = .kidkGray
        
        let titleStackView = UIStackView()
        titleStackView.axis = .horizontal
        titleStackView.spacing = 4
        
        let monthLabel = UILabel()
        monthLabel.text = "5월"
        monthLabel.font = .kidkTitle
        monthLabel.textColor = .kidkPink
        
        let spendingLabel = UILabel()
        spendingLabel.text = "소비"
        spendingLabel.font = .kidkTitle
        spendingLabel.textColor = .kidkTextWhite
        
        let totalAmountView = AmountLabelView()
        totalAmountView.configure(amount: "총 20,000원")
        
        let arrowImageView = UIImageView()
        arrowImageView.image = UIImage(systemName: "chevron.right")
        arrowImageView.tintColor = .kidkGray
        arrowImageView.contentMode = .scaleAspectFit
        
        let progressView = UIView()
        
        let progressBar1 = UIView()
        progressBar1.backgroundColor = .kidkPink
        progressBar1.layer.cornerRadius = 4
        
        let progressBar2 = UIView()
        progressBar2.backgroundColor = .kidkGreen
        progressBar2.layer.cornerRadius = 4
        
        let progressBar3 = UIView()
        progressBar3.backgroundColor = UIColor(hex: "#00A8FF")
        progressBar3.layer.cornerRadius = 4
        
        let category1View = createCategoryView(icon: "kidk_category_food", title: "음식", amount: "12,000원", color: .kidkPink)
        let category2View = createCategoryView(icon: "kidk_category_shopping", title: "쇼핑", amount: "5,000원", color: .kidkGreen)
        let category3View = createCategoryView(icon: "kidk_category_transport", title: "교통", amount: "3,000원", color: UIColor(hex: "#00A8FF"))
        
        titleStackView.addArrangedSubview(monthLabel)
        titleStackView.addArrangedSubview(spendingLabel)
        
        contentView.addSubview(headerView)
        headerView.addSubview(questionLabel)
        headerView.addSubview(titleStackView)
        headerView.addSubview(totalAmountView)
        headerView.addSubview(arrowImageView)
        
        contentView.addSubview(progressView)
        progressView.addSubview(progressBar1)
        progressView.addSubview(progressBar2)
        progressView.addSubview(progressBar3)
        
        contentView.addSubview(category1View)
        contentView.addSubview(category2View)
        contentView.addSubview(category3View)
        
        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        questionLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        titleStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalTo(questionLabel.snp.bottom).offset(Spacing.small)
            make.bottom.equalToSuperview()
        }
        
        totalAmountView.snp.makeConstraints { make in
            make.leading.equalTo(titleStackView.snp.trailing).offset(24)
            make.centerY.equalTo(titleStackView)
            make.height.equalTo(36)
        }
        
        arrowImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalTo(titleStackView)
            make.width.height.equalTo(20)
        }
        
        progressView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(Spacing.medium)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(8)
        }
        
        progressBar1.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.6)
        }
        
        progressBar2.snp.makeConstraints { make in
            make.leading.equalTo(progressBar1.snp.trailing)
            make.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.25)
        }
        
        progressBar3.snp.makeConstraints { make in
            make.leading.equalTo(progressBar2.snp.trailing)
            make.top.bottom.trailing.equalToSuperview()
        }
        
        category1View.snp.makeConstraints { make in
            make.top.equalTo(progressView.snp.bottom).offset(Spacing.medium)
            make.leading.trailing.equalToSuperview()
        }
        
        category2View.snp.makeConstraints { make in
            make.top.equalTo(category1View.snp.bottom).offset(Spacing.small)
            make.leading.trailing.equalToSuperview()
        }
        
        category3View.snp.makeConstraints { make in
            make.top.equalTo(category2View.snp.bottom).offset(Spacing.small)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        card.configure(with: contentView, showCloseButton: false)
        return card
    }
    
    private func createCategoryView(icon: String, title: String, amount: String, color: UIColor) -> UIView {
        let view = UIView()
        
        let iconImageView = UIImageView()
        iconImageView.image = UIImage(named: icon)
        iconImageView.contentMode = .scaleAspectFit
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .kidkSubtitle
        titleLabel.textColor = .kidkTextWhite
        
        let amountView = AmountLabelView()
        amountView.configure(amount: amount)
        
        view.addSubview(iconImageView)
        view.addSubview(titleLabel)
        view.addSubview(amountView)
        
        iconImageView.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.width.height.equalTo(32)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(Spacing.small)
            make.centerY.equalToSuperview()
        }
        
        amountView.snp.makeConstraints { make in
            make.trailing.centerY.equalToSuperview()
            make.height.equalTo(36)
        }
        
        view.snp.makeConstraints { make in
            make.height.equalTo(40)
        }
        
        return view
    }
}
