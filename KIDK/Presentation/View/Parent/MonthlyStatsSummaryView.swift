import UIKit
import SnapKit

final class MonthlyStatsSummaryView: UIView {

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .cardBackground
        view.layer.cornerRadius = CornerRadius.large
        return view
    }()

    private let sectionHeader = SectionHeaderView()

    private let statsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = Spacing.xs
        stackView.distribution = .fillEqually
        return stackView
    }()

    private let spendingView = StatItemView(title: "총 지출", color: .kidkPink)
    private let savingsView = StatItemView(title: "총 저축", color: .kidkGreen)

    private let progressTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "월 한도 사용 현황"
        label.font = .kidkFont(.s14, .medium)
        label.textColor = .kidkGray
        label.textAlignment = .center
        return label
    }()

    private let progressView = CircularProgressView()

    private let usageRateLabel: UILabel = {
        let label = UILabel()
        label.font = .kidkFont(.s12, .regular)
        label.textColor = .kidkGray
        label.textAlignment = .center
        return label
    }()

    private let limitContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .kidkDarkBackground.withAlphaComponent(0.4)
        view.layer.cornerRadius = CornerRadius.medium
        return view
    }()

    private let limitTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "일일 사용 한도"
        label.font = .kidkFont(.s12, .medium)
        label.textColor = .kidkGray
        return label
    }()

    private let limitLabel: UILabel = {
        let label = UILabel()
        label.font = .kidkFont(.s16, .bold)
        label.textColor = .kidkTextWhite
        label.textAlignment = .right
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
        addSubview(containerView)
        containerView.addSubview(sectionHeader)
        containerView.addSubview(statsStackView)
        containerView.addSubview(progressTitleLabel)
        containerView.addSubview(progressView)
        containerView.addSubview(usageRateLabel)
        containerView.addSubview(limitContainerView)

        limitContainerView.addSubview(limitTitleLabel)
        limitContainerView.addSubview(limitLabel)

        statsStackView.addArrangedSubview(spendingView)
        statsStackView.addArrangedSubview(savingsView)

        sectionHeader.configure(
            title: "📊 이번 달",
            subtitle: "지출·저축 흐름과 한도 사용률"
        )

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        sectionHeader.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(Spacing.md)
        }

        statsStackView.snp.makeConstraints { make in
            make.top.equalTo(sectionHeader.snp.bottom).offset(Spacing.md)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
        }

        progressTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(statsStackView.snp.bottom).offset(Spacing.md)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
        }

        progressView.snp.makeConstraints { make in
            make.top.equalTo(progressTitleLabel.snp.bottom).offset(Spacing.sm)
            make.centerX.equalToSuperview()
            make.size.equalTo(200)
        }

        usageRateLabel.snp.makeConstraints { make in
            make.top.equalTo(progressView.snp.bottom).offset(Spacing.xxs)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
        }

        limitContainerView.snp.makeConstraints { make in
            make.top.equalTo(usageRateLabel.snp.bottom).offset(Spacing.sm)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
            make.bottom.equalToSuperview().offset(-Spacing.md)
        }

        limitTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Spacing.sm)
            make.centerY.equalToSuperview()
        }

        limitLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(Spacing.sm)
            make.leading.greaterThanOrEqualTo(limitTitleLabel.snp.trailing).offset(Spacing.xs)
            make.trailing.equalToSuperview().offset(-Spacing.sm)
        }
    }

    func configure(
        totalSpending: Int,
        totalSavings: Int,
        dailyLimit: Int,
        usagePercentage: Double
    ) {
        spendingView.configure(amount: totalSpending)
        savingsView.configure(amount: totalSavings)

        let percentage = max(0, min(Int((usagePercentage * 100).rounded()), 100))
        usageRateLabel.text = "이번 달 한도 사용률 \(percentage)%"
        limitLabel.text = formatAmount(dailyLimit)

        // CircularProgressView 설정
        let image = UIImage(systemName: "chart.bar.fill")
        progressView.configure(
            currentAmount: totalSpending,
            targetAmount: max(dailyLimit * 30, 1),
            image: image
        )
    }

    private func formatAmount(_ amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formatted = formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
        return "\(formatted)원"
    }
}

// MARK: - StatItemView

private final class StatItemView: UIView {

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .kidkDarkBackground.withAlphaComponent(0.4)
        view.layer.cornerRadius = CornerRadius.medium
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .kidkFont(.s12, .medium)
        label.textColor = .kidkGray
        label.textAlignment = .center
        return label
    }()

    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = .kidkFont(.s18, .bold)
        label.textAlignment = .center
        return label
    }()

    init(title: String, color: UIColor) {
        super.init(frame: .zero)
        titleLabel.text = title
        amountLabel.textColor = color
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(amountLabel)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Spacing.xs)
            make.leading.trailing.equalToSuperview().inset(Spacing.xs)
        }

        amountLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Spacing.xxs)
            make.leading.trailing.equalToSuperview().inset(Spacing.xs)
            make.bottom.equalToSuperview().offset(-Spacing.xs)
        }

        containerView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(72)
        }
    }

    func configure(amount: Int) {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formatted = formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
        amountLabel.text = "\(formatted)원"
    }
}
