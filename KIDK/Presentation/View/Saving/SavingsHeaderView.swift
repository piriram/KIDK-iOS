//
//  SavingsHeaderView.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/21/25.
//

import UIKit
import SnapKit

final class SavingsHeaderView: UIView {
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .cardBackground
        view.layer.cornerRadius = 16
        return view
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
            color: .kidkPink,
            lineHeight: 140
        )
        return label
    }()
    
    private let statsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = Spacing.sm
        return stackView
    }()
    
    private let savingsRateView = StatItemView()
    private let thisMonthView = StatItemView()
    private let streakView = StatItemView()
    
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
        
        statsStackView.addArrangedSubview(savingsRateView)
        statsStackView.addArrangedSubview(thisMonthView)
        statsStackView.addArrangedSubview(streakView)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(Spacing.md)
        }
        
        totalAmountLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Spacing.sm)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
        }
        
        statsStackView.snp.makeConstraints { make in
            make.top.equalTo(totalAmountLabel.snp.bottom).offset(Spacing.md)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
            make.bottom.equalToSuperview().inset(Spacing.md)
            make.height.equalTo(60)
        }
    }
    
    func configure(with stats: SavingsStats) {
        totalAmountLabel.text = stats.formattedTotalSavings
        savingsRateView.configure(title: "저축률", value: stats.formattedSavingsRate, color: .kidkGreen)
        thisMonthView.configure(title: "이번 달", value: stats.formattedThisMonthSavings, color: .kidkBlue)
        streakView.configure(title: "연속 저축", value: "\(stats.currentStreak)일", color: .kidkPink)
    }
}

private final class StatItemView: UIView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(
            text: "",
            size: .s12,
            weight: .regular,
            color: .kidkGray,
            lineHeight: 140
        )
        label.textAlignment = .center
        return label
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(
            text: "",
            size: .s16,
            weight: .bold,
            color: .kidkTextWhite,
            lineHeight: 140
        )
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
        backgroundColor = UIColor.white.withAlphaComponent(0.05)
        layer.cornerRadius = 8
        
        addSubview(titleLabel)
        addSubview(valueLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(Spacing.xs)
            make.leading.trailing.equalToSuperview().inset(Spacing.xs)
        }
        
        valueLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(Spacing.xs)
            make.bottom.lessThanOrEqualToSuperview().inset(Spacing.xs)
        }
    }
    
    func configure(title: String, value: String, color: UIColor) {
        titleLabel.text = title
        valueLabel.text = value
        valueLabel.textColor = color
    }
}

