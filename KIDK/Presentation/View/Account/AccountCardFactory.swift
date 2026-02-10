import UIKit
import SnapKit

enum AccountCardFactory {
    
    static func makeNewMissionCard(data: MissionCardData) -> AccountCardView {
        let card = AccountCardView()
        let contentView = UIView()
        
        let iconContainer = IconContainerView(data.iconName, size: 60, iconSize: 44)
        
        let titleLabel = UILabel()
        titleLabel.applyTextStyle(
            text: data.title,
            size: .s20,
            weight: .bold,
            color: .kidkTextWhite,
            lineHeight: 140
        )
        
        let subtitleLabel = UILabel()
        subtitleLabel.applyTextStyle(
            text: data.subtitle,
            size: .s16,
            weight: .medium,
            color: .kidkGray
        )
        
        let button = KIDKButton(
            title: data.buttonTitle,
            backgroundColor: .kidkPink,
            titleColor: .kidkTextWhite,
            font: .spoqaHanSansNeo(size: 16, weight: .bold)
        )
        button.isUserInteractionEnabled = false
        
        contentView.addSubview(iconContainer)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(button)
        
        iconContainer.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
            make.width.height.equalTo(60)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconContainer.snp.trailing).offset(Spacing.xs)
            make.top.equalTo(iconContainer.snp.top)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
        }
        
        button.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(iconContainer.snp.bottom).offset(Spacing.md)
            make.bottom.equalToSuperview()
            make.height.equalTo(48)
        }
        
        card.configure(with: contentView, showCloseButton: true)
        return card
    }
    
    static func makeSpendingAccountCard(data: AccountCardData) -> AccountCardView {
        let card = AccountCardView()
        let contentView = UIView()
        
        let iconImageView = IconContainerView(data.iconName)
        
        let titleLabel = UILabel()
        titleLabel.text = data.title
        titleLabel.font = .kidkSubtitle
        titleLabel.textColor = .kidkGray
        
        let amountLabel = UILabel()
        amountLabel.text = data.formattedAmount
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
            make.leading.equalTo(iconImageView.snp.trailing).offset(Spacing.xs)
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
    
    static func makeSavingsAccountCard(data: AccountCardData) -> AccountCardView {
        let card = AccountCardView()
        let contentView = UIView()
        
        let iconImageView = IconContainerView(data.iconName)
        
        let titleLabel = UILabel()
        titleLabel.text = data.title
        titleLabel.font = .kidkBody
        titleLabel.textColor = .kidkGray
        
        let amountLabel = UILabel()
        amountLabel.text = data.formattedAmount
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
            make.leading.top.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(Spacing.xs)
            make.top.equalToSuperview()
        }
        
        amountLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
        }
        
        arrowImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom)
            make.width.height.equalTo(20)
        }
        
        if let message = data.message {
            let messageContainer = UIView()
            messageContainer.backgroundColor = .kidkDarkBackground
            messageContainer.layer.cornerRadius = 10
            
            let messageLabel = UILabel()
            messageLabel.text = message
            messageLabel.font = .spoqaHanSansNeo(size: 14, weight: .bold)
            messageLabel.textColor = .kidkGreen
            messageLabel.textAlignment = .center
            messageLabel.numberOfLines = 0
            
            contentView.addSubview(messageContainer)
            messageContainer.addSubview(messageLabel)
            
            messageContainer.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.top.equalTo(amountLabel.snp.bottom).offset(Spacing.md)
                make.bottom.equalToSuperview()
            }
            
            messageLabel.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(Spacing.md)
            }
        } else {
            amountLabel.snp.makeConstraints { make in
                make.bottom.equalToSuperview()
            }
        }
        
        card.configure(with: contentView, showCloseButton: false)
        return card
    }
    
    static func makeMonthlyReportCard(
        data: MonthlyReportCardData,
        progressBarView: CategoryProgressBarView
    ) -> AccountCardView {
        let card = AccountCardView()
        let contentView = UIView()
        
        let headerView = UIView()
        
        let questionLabel = UILabel()
        questionLabel.text = "이번달은 어디에 돈을 많이 사용했을까요?"
        questionLabel.font = .kidkBody
        questionLabel.textColor = .kidkTextWhite.withAlphaComponent(0.8)
        
        let titleStackView = UIStackView()
        titleStackView.axis = .horizontal
        titleStackView.spacing = 4
        
        let monthLabel = UILabel()
        monthLabel.text = data.monthText
        monthLabel.font = .kidkTitle
        monthLabel.textColor = .kidkPink
        
        let spendingLabel = UILabel()
        spendingLabel.text = "소비"
        spendingLabel.font = .kidkTitle
        spendingLabel.textColor = .kidkTextWhite
        
        let totalAmountView = AmountLabelView()
        totalAmountView.configure(amount: data.formattedTotalAmount)
        
        let arrowImageView = UIImageView()
        arrowImageView.image = UIImage(systemName: "chevron.right")
        arrowImageView.tintColor = .kidkGray
        arrowImageView.contentMode = .scaleAspectFit
        
        titleStackView.addArrangedSubview(monthLabel)
        titleStackView.addArrangedSubview(spendingLabel)
        
        contentView.addSubview(headerView)
        headerView.addSubview(questionLabel)
        headerView.addSubview(titleStackView)
        headerView.addSubview(totalAmountView)
        headerView.addSubview(arrowImageView)
        
        contentView.addSubview(progressBarView)
        
        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        questionLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        titleStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalTo(questionLabel.snp.bottom).offset(Spacing.xs)
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
        
        progressBarView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(Spacing.md)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(ProgressBarConfig.barHeight)
        }
        
        var previousView: UIView = progressBarView
        
        for category in data.categories {
            let categoryView = makeCategorySpendingView(for: category)
            contentView.addSubview(categoryView)
            
            categoryView.snp.makeConstraints { make in
                make.top.equalTo(previousView.snp.bottom).offset(Spacing.xs)
                make.leading.trailing.equalToSuperview()
            }
            
            previousView = categoryView
        }
        
        previousView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
        }
        
        card.configure(with: contentView, showCloseButton: false)
        return card
    }
    
    private static func makeCategorySpendingView(for category: CategorySpending) -> CategorySpendingView {
        let iconName: String
        let backgroundColor: UIColor
        
        switch category.category {
        case "음식":
            iconName = "kidk_category_food"
            backgroundColor = .kidkPink
        case "쇼핑":
            iconName = "kidk_category_shopping"
            backgroundColor = .kidkGreen
        case "교통":
            iconName = "kidk_category_transport"
            backgroundColor = .kidkBlue
        default:
            iconName = "kidk_category_etc"
            backgroundColor = .kidkGray
        }
        
        let view = CategorySpendingView(iconName: iconName, backgroundColor: backgroundColor)
        view.configure(title: category.category, amount: category.amount)
        return view
    }
}
