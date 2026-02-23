import UIKit
import SnapKit

final class TransactionCell: UITableViewCell {

    static let identifier = "TransactionCell"

    private let dayLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s12, .bold)
        label.textColor = .kidkGray
        label.textAlignment = .center
        return label
    }()

    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s10, .regular)
        label.textColor = .kidkGray
        label.textAlignment = .center
        return label
    }()

    private let timelineDotView: UIView = {
        let view = UIView()
        view.backgroundColor = .kidkPink
        view.layer.cornerRadius = 5
        return view
    }()

    private let timelineLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .kidkDarkBackground
        return view
    }()

    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .cardBackground
        view.layer.cornerRadius = CornerRadius.medium
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.kidkTextWhite.withAlphaComponent(0.05).cgColor
        return view
    }()

    private let categoryIconView: IconContainerView = {
        let view = IconContainerView("kidk_icon_wallet", backgroundColor: .kidkGray, size: 36, cornerRadius: 12, iconSize: 22, alpha: 0.2)
        return view
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s14, .bold)
        label.textColor = .kidkTextWhite
        label.numberOfLines = 1
        return label
    }()

    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s12, .regular)
        label.textColor = .kidkGray
        label.numberOfLines = 1
        return label
    }()

    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s18, .bold)
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.82
        return label
    }()

    private let typeBadgeView = ParentTimelineStatusBadgeView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(dayLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(timelineDotView)
        contentView.addSubview(timelineLineView)
        contentView.addSubview(cardView)

        cardView.addSubview(categoryIconView)
        cardView.addSubview(descriptionLabel)
        cardView.addSubview(categoryLabel)
        cardView.addSubview(amountLabel)
        cardView.addSubview(typeBadgeView)

        dayLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Spacing.xs)
            make.leading.equalToSuperview().offset(Spacing.md)
            make.width.equalTo(52)
        }

        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(dayLabel.snp.bottom).offset(2)
            make.leading.trailing.equalTo(dayLabel)
        }

        timelineDotView.snp.makeConstraints { make in
            make.top.equalTo(timeLabel.snp.bottom).offset(Spacing.xxs)
            make.centerX.equalTo(dayLabel)
            make.size.equalTo(10)
        }

        timelineLineView.snp.makeConstraints { make in
            make.top.equalTo(timelineDotView.snp.bottom).offset(2)
            make.centerX.equalTo(timelineDotView)
            make.width.equalTo(2)
            make.bottom.equalToSuperview()
        }

        cardView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Spacing.xs)
            make.leading.equalTo(dayLabel.snp.trailing).offset(Spacing.xs)
            make.trailing.equalToSuperview().offset(-Spacing.md)
            make.bottom.equalToSuperview().offset(-Spacing.xs)
        }

        categoryIconView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Spacing.sm)
            make.centerY.equalToSuperview()
        }

        descriptionLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Spacing.sm)
            make.leading.equalTo(categoryIconView.snp.trailing).offset(Spacing.xs)
            make.trailing.lessThanOrEqualTo(amountLabel.snp.leading).offset(-Spacing.xs)
        }

        categoryLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(4)
            make.leading.equalTo(descriptionLabel)
            make.bottom.equalToSuperview().offset(-Spacing.sm)
        }

        amountLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Spacing.sm)
            make.trailing.equalToSuperview().offset(-Spacing.sm)
            make.width.greaterThanOrEqualTo(80)
        }

        typeBadgeView.snp.makeConstraints { make in
            make.top.equalTo(amountLabel.snp.bottom).offset(Spacing.xxs)
            make.trailing.equalTo(amountLabel)
            make.leading.greaterThanOrEqualTo(categoryLabel.snp.trailing).offset(Spacing.xs)
        }
    }

    func configure(with transaction: Transaction) {
        descriptionLabel.text = transaction.description
        categoryLabel.text = transaction.category?.rawValue ?? transaction.type.displayName
        amountLabel.text = transaction.formattedAmount

        dayLabel.text = transaction.date.formattedMonthDay
        timeLabel.text = transaction.formattedDate

        let isPositive = transaction.type == .deposit || transaction.type == .missionReward
        let tone: ParentTimelineTone = isPositive ? .green : .pink

        amountLabel.textColor = tone.tintColor
        timelineDotView.backgroundColor = tone.tintColor

        typeBadgeView.configure(text: transaction.type.displayName, tone: tone)

        if let category = transaction.category {
            categoryIconView.updateIcon(category.iconName)
            categoryIconView.updateBackgroundColor(category.color)
        } else {
            categoryIconView.updateIcon("kidk_icon_wallet")
            categoryIconView.updateBackgroundColor(.kidkGray)
        }
    }
}
