//
//  SavingsSummaryView.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/19/25.
//

import UIKit
import SnapKit

final class SavingsSummaryView: UIView {

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#2C2C2E")
        view.layer.cornerRadius = CornerRadius.large
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "총 저축액"
        label.font = .kidkFont(.s16, .medium)
        label.textColor = .kidkTextWhite.withAlphaComponent(0.8)
        return label
    }()

    private let totalAmountLabel: UILabel = {
        let label = UILabel()
        label.font = .kidkFont(.s32, .bold)
        label.textColor = .kidkTextWhite
        return label
    }()

    private let statsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = Spacing.md
        return stackView
    }()

    private let monthlyStatView = StatItemView(title: "이번 달 저축")
    private let rateStatView = StatItemView(title: "저축률")

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(totalAmountLabel)
        containerView.addSubview(statsStackView)

        statsStackView.addArrangedSubview(monthlyStatView)
        statsStackView.addArrangedSubview(rateStatView)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(Spacing.md)
        }

        totalAmountLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Spacing.xs)
            make.leading.equalToSuperview().offset(Spacing.md)
        }

        statsStackView.snp.makeConstraints { make in
            make.top.equalTo(totalAmountLabel.snp.bottom).offset(Spacing.lg)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
            make.bottom.equalToSuperview().offset(-Spacing.md)
        }
    }

    func configure(total: Int, monthly: Int, rate: Double) {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal

        if let formattedTotal = formatter.string(from: NSNumber(value: total)) {
            totalAmountLabel.text = "\(formattedTotal)원"
        }

        if let formattedMonthly = formatter.string(from: NSNumber(value: monthly)) {
            monthlyStatView.setValue("\(formattedMonthly)원")
        }

        rateStatView.setValue("\(Int(rate))%")
    }
}

private final class StatItemView: UIView {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .kidkFont(.s14, .regular)
        label.textColor = .kidkTextWhite.withAlphaComponent(0.6)
        return label
    }()

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .kidkFont(.s18, .bold)
        label.textColor = .kidkPink
        return label
    }()

    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(titleLabel)
        addSubview(valueLabel)

        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        valueLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Spacing.xxs)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    func setValue(_ value: String) {
        valueLabel.text = value
    }
}
