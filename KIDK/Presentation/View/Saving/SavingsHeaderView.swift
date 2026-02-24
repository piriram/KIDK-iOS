import UIKit
import SnapKit

final class SavingsHeaderView: UIView {

    private let headerGradientLayer = CAGradientLayer()

    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = CornerRadius.large
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        view.clipsToBounds = true
        return view
    }()

    private let iconBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.14)
        view.layer.cornerRadius = CornerRadius.medium
        return view
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "banknote.fill"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .kidkTextWhite
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(
            text: "총 저축 현황",
            size: .s16,
            weight: .bold,
            color: .kidkTextWhite,
            lineHeight: 140
        )
        return label
    }()

    private let totalAmountLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(
            text: "0원",
            size: .s32,
            weight: .bold,
            color: .kidkTextWhite,
            lineHeight: 130
        )
        return label
    }()

    private let summaryLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(
            text: "이번 달도 차곡차곡 모으는 중",
            size: .s14,
            weight: .medium,
            color: UIColor.white.withAlphaComponent(0.78),
            lineHeight: 140
        )
        return label
    }()

    private let statsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = Spacing.xs
        return stackView
    }()

    private let savingsRateView = StatItemView()
    private let thisMonthView = StatItemView()
    private let completedView = StatItemView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        headerGradientLayer.frame = containerView.bounds
    }

    private func setupUI() {
        addSubview(containerView)
        containerView.layer.insertSublayer(headerGradientLayer, at: 0)

        headerGradientLayer.colors = [
            UIColor(hex: "#3A2A45").cgColor,
            UIColor(hex: "#2B2B33").cgColor,
            UIColor(hex: "#26262D").cgColor
        ]
        headerGradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        headerGradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)

        containerView.addSubview(iconBackgroundView)
        iconBackgroundView.addSubview(iconImageView)

        containerView.addSubview(titleLabel)
        containerView.addSubview(totalAmountLabel)
        containerView.addSubview(summaryLabel)
        containerView.addSubview(statsStackView)

        statsStackView.addArrangedSubview(savingsRateView)
        statsStackView.addArrangedSubview(thisMonthView)
        statsStackView.addArrangedSubview(completedView)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        iconBackgroundView.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(Spacing.md)
            make.width.height.equalTo(36)
        }

        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(20)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(Spacing.md)
            make.trailing.lessThanOrEqualTo(iconBackgroundView.snp.leading).offset(-Spacing.sm)
        }

        totalAmountLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Spacing.xs)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
        }

        summaryLabel.snp.makeConstraints { make in
            make.top.equalTo(totalAmountLabel.snp.bottom).offset(Spacing.xs)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
        }

        statsStackView.snp.makeConstraints { make in
            make.top.equalTo(summaryLabel.snp.bottom).offset(Spacing.md)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
            make.bottom.equalToSuperview().inset(Spacing.md)
            make.height.equalTo(68)
        }
    }

    func configure(with stats: SavingsStats) {
        totalAmountLabel.text = stats.formattedTotalSavings
        summaryLabel.text = "이번 달 저축 +\(stats.formattedThisMonthSavings)"

        savingsRateView.configure(
            title: "저축률",
            value: stats.formattedSavingsRate,
            color: .kidkGreen,
            iconName: "chart.bar.fill"
        )
        thisMonthView.configure(
            title: "이번 달",
            value: stats.formattedThisMonthSavings,
            color: .kidkBlue,
            iconName: "calendar"
        )
        completedView.configure(
            title: "달성 목표",
            value: "\(stats.completedGoalsCount)개",
            color: .kidkPink,
            iconName: "checkmark.seal.fill"
        )

        accessibilityLabel = "총 저축 \(stats.formattedTotalSavings), 이번 달 저축 \(stats.formattedThisMonthSavings), 저축률 \(stats.formattedSavingsRate)"
    }
}

private final class StatItemView: UIView {

    private let iconBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.16)
        view.layer.cornerRadius = CornerRadius.small
        return view
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .kidkTextWhite
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(
            text: "",
            size: .s12,
            weight: .regular,
            color: UIColor.white.withAlphaComponent(0.75),
            lineHeight: 140
        )
        return label
    }()

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(
            text: "",
            size: .s14,
            weight: .bold,
            color: .kidkTextWhite,
            lineHeight: 135
        )
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = UIColor.white.withAlphaComponent(0.08)
        layer.cornerRadius = CornerRadius.medium

        addSubview(iconBackgroundView)
        iconBackgroundView.addSubview(iconImageView)
        addSubview(titleLabel)
        addSubview(valueLabel)

        iconBackgroundView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(Spacing.xs)
            make.width.height.equalTo(22)
        }

        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(12)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(Spacing.xs)
            make.leading.equalTo(iconBackgroundView.snp.trailing).offset(6)
            make.trailing.equalToSuperview().inset(Spacing.xs)
        }

        valueLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(Spacing.xs)
            make.bottom.lessThanOrEqualToSuperview().inset(Spacing.xs)
        }
    }

    func configure(title: String, value: String, color: UIColor, iconName: String) {
        titleLabel.text = title
        valueLabel.text = value
        valueLabel.textColor = color
        iconImageView.image = UIImage(systemName: iconName)
        iconBackgroundView.backgroundColor = color.withAlphaComponent(0.24)
    }
}
