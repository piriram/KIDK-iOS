//
//  SavingsGoalCell.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/19/25.
//

import UIKit
import SnapKit

final class SavingsGoalCell: UITableViewCell {

    static let identifier = "SavingsGoalCell"

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#2C2C2E")
        view.layer.cornerRadius = 12
        return view
    }()

    private let goalNameLabel: UILabel = {
        let label = UILabel()
        label.font = .spoqaHanSansNeo(size: 18, weight: .bold)
        label.textColor = .kidkTextWhite
        return label
    }()

    private let progressBar: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.trackTintColor = UIColor(hex: "#1C1C1E")
        progressView.progressTintColor = .kidkGreen
        progressView.layer.cornerRadius = 4
        progressView.clipsToBounds = true
        return progressView
    }()

    private let progressLabel: UILabel = {
        let label = UILabel()
        label.font = .spoqaHanSansNeo(size: 14, weight: .bold)
        label.textColor = .kidkGreen
        return label
    }()

    private let amountStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        return stackView
    }()

    private let currentAmountLabel: UILabel = {
        let label = UILabel()
        label.font = .spoqaHanSansNeo(size: 14, weight: .medium)
        label.textColor = .kidkGray
        return label
    }()

    private let targetAmountLabel: UILabel = {
        let label = UILabel()
        label.font = .spoqaHanSansNeo(size: 14, weight: .medium)
        label.textColor = .kidkGray
        return label
    }()

    private let targetDateLabel: UILabel = {
        let label = UILabel()
        label.font = .spoqaHanSansNeo(size: 12, weight: .medium)
        label.textColor = .kidkGray
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(containerView)
        containerView.addSubview(goalNameLabel)
        containerView.addSubview(progressBar)
        containerView.addSubview(progressLabel)
        containerView.addSubview(amountStackView)
        containerView.addSubview(targetDateLabel)

        amountStackView.addArrangedSubview(currentAmountLabel)
        amountStackView.addArrangedSubview(targetAmountLabel)

        containerView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(6)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        goalNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        progressBar.snp.makeConstraints { make in
            make.top.equalTo(goalNameLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(8)
        }

        progressLabel.snp.makeConstraints { make in
            make.top.equalTo(progressBar.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(16)
        }

        amountStackView.snp.makeConstraints { make in
            make.top.equalTo(progressLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        targetDateLabel.snp.makeConstraints { make in
            make.top.equalTo(amountStackView.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-16)
        }
    }

    func configure(with goal: SavingsGoal) {
        goalNameLabel.text = goal.name
        progressBar.progress = Float(goal.progress)
        progressLabel.text = "\(goal.progressPercentage)% 달성"
        currentAmountLabel.text = "현재: \(goal.formattedCurrentAmount)"
        targetAmountLabel.text = "목표: \(goal.formattedTargetAmount)"

        if let targetDate = goal.formattedTargetDate {
            targetDateLabel.text = "목표일: \(targetDate)"
            targetDateLabel.isHidden = false
        } else {
            targetDateLabel.isHidden = true
        }
    }
}
