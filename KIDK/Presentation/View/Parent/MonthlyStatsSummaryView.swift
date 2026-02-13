import UIKit
import SnapKit

final class MonthlyStatsSummaryView: UIView {

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .cardBackground
        view.layer.cornerRadius = CornerRadius.medium
        return view
    }()

    private let sectionHeader = SectionHeaderView()

    private let statsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = Spacing.md
        stackView.distribution = .fillEqually
        return stackView
    }()

    private let spendingView = StatItemView(title: "총 지출", color: .kidkPink)
    private let savingsView = StatItemView(title: "총 저축", color: .kidkGreen)

    private let progressView = CircularProgressView()

    private let limitLabel: UILabel = {
        let label = UILabel()
        label.font = .kidkFont(.s14, .medium)
        label.textColor = .kidkGray
        label.textAlignment = .center
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
        containerView.addSubview(progressView)
        containerView.addSubview(limitLabel)

        statsStackView.addArrangedSubview(spendingView)
        statsStackView.addArrangedSubview(savingsView)

        sectionHeader.configure(title: "📊 이번 달")

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

        progressView.snp.makeConstraints { make in
            make.top.equalTo(statsStackView.snp.bottom).offset(Spacing.md)
            make.centerX.equalToSuperview()
            make.size.equalTo(200)
        }

        limitLabel.snp.makeConstraints { make in
            make.top.equalTo(progressView.snp.bottom).offset(Spacing.sm)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
            make.bottom.equalToSuperview().offset(-Spacing.md)
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

        limitLabel.text = "한도: \(formatAmount(dailyLimit))"

        // CircularProgressView 설정
        let image = UIImage(systemName: "chart.bar.fill")
        progressView.configure(
            currentAmount: totalSpending,
            targetAmount: dailyLimit,
            image: image,
            arcPercentage: 0.7
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
        addSubview(titleLabel)
        addSubview(amountLabel)

        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        amountLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Spacing.xxs)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    func configure(amount: Int) {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formatted = formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
        amountLabel.text = "\(formatted)원"
    }
}
