//
//  SavingsGoalCardView.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/21/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class SavingsGoalCardView: UIView {

    let cardTapped = PublishRelay<SavingsGoal>()

    private var goal: SavingsGoal?
    private let disposeBag = DisposeBag()

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .cardBackground
        view.layer.cornerRadius = 16
        return view
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .kidkPink.withAlphaComponent(0.2)
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        imageView.tintColor = .kidkPink
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(
            text: "",
            size: .s18,
            weight: .bold,
            color: .kidkTextWhite,
            lineHeight: 140
        )
        return label
    }()

    private let progressLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(
            text: "",
            size: .s14,
            weight: .medium,
            color: .kidkGray,
            lineHeight: 140
        )
        return label
    }()

    private let progressBar: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.progressTintColor = .kidkPink
        progressView.trackTintColor = UIColor.white.withAlphaComponent(0.1)
        progressView.layer.cornerRadius = 4
        progressView.clipsToBounds = true
        progressView.layer.sublayers?.forEach { layer in
            layer.cornerRadius = 4
            layer.masksToBounds = true
        }
        return progressView
    }()

    private let amountStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = Spacing.sm
        return stackView
    }()

    private let currentAmountView = AmountInfoView()
    private let targetAmountView = AmountInfoView()
    private let remainingAmountView = AmountInfoView()

    private let badgeStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = Spacing.xs
        return stackView
    }()

    private let statusBadge: UILabel = {
        let label = UILabel()
        label.applyTextStyle(
            text: "",
            size: .s12,
            weight: .medium,
            color: .kidkTextWhite,
            lineHeight: 140
        )
        label.backgroundColor = .kidkGreen
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    private let dDayLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(
            text: "",
            size: .s12,
            weight: .bold,
            color: .kidkPink,
            lineHeight: 140
        )
        label.backgroundColor = .kidkPink.withAlphaComponent(0.2)
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        bind()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(progressLabel)
        containerView.addSubview(progressBar)
        containerView.addSubview(amountStackView)
        containerView.addSubview(badgeStackView)

        amountStackView.addArrangedSubview(currentAmountView)
        amountStackView.addArrangedSubview(remainingAmountView)
        amountStackView.addArrangedSubview(targetAmountView)

        badgeStackView.addArrangedSubview(statusBadge)
        badgeStackView.addArrangedSubview(dDayLabel)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        iconImageView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(Spacing.md)
            make.width.height.equalTo(50)
        }

        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(Spacing.md)
            make.leading.equalTo(iconImageView.snp.trailing).offset(Spacing.sm)
            make.trailing.equalToSuperview().inset(Spacing.md)
        }

        badgeStackView.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(Spacing.xs)
            make.leading.equalTo(iconImageView.snp.trailing).offset(Spacing.sm)
        }

        statusBadge.snp.makeConstraints { make in
            make.width.greaterThanOrEqualTo(60)
            make.height.equalTo(24)
        }

        dDayLabel.snp.makeConstraints { make in
            make.width.greaterThanOrEqualTo(50)
            make.height.equalTo(24)
        }

        progressLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(Spacing.md)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
        }

        progressBar.snp.makeConstraints { make in
            make.top.equalTo(progressLabel.snp.bottom).offset(Spacing.xs)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
            make.height.equalTo(8)
        }

        amountStackView.snp.makeConstraints { make in
            make.top.equalTo(progressBar.snp.bottom).offset(Spacing.md)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
            make.bottom.equalToSuperview().inset(Spacing.md)
        }
    }

    private func bind() {
        let tapGesture = UITapGestureRecognizer()
        containerView.addGestureRecognizer(tapGesture)

        tapGesture.rx.event
            .compactMap { [weak self] _ in self?.goal }
            .bind(to: cardTapped)
            .disposed(by: disposeBag)
    }

    func configure(with goal: SavingsGoal) {
        self.goal = goal

        nameLabel.text = goal.name

        if let imageName = goal.imageName {
            iconImageView.image = UIImage(systemName: imageName) ?? UIImage(systemName: "dollarsign.circle.fill")
        } else {
            iconImageView.image = UIImage(systemName: "dollarsign.circle.fill")
        }

        let progressPercentage = goal.progressPercentage
        progressLabel.text = String(format: "%.1f%% 달성", progressPercentage)
        progressBar.setProgress(Float(progressPercentage / 100), animated: true)

        currentAmountView.configure(title: "현재 금액", value: goal.formattedCurrentAmount, color: .kidkGreen)
        remainingAmountView.configure(title: "남은 금액", value: goal.formattedRemainingAmount, color: .kidkGray)
        targetAmountView.configure(title: "목표 금액", value: goal.formattedTargetAmount, color: .kidkPink)

        switch goal.status {
        case .inProgress:
            statusBadge.isHidden = false
            statusBadge.text = "진행 중"
            statusBadge.backgroundColor = .kidkGreen
        case .completed:
            statusBadge.isHidden = false
            statusBadge.text = "달성"
            statusBadge.backgroundColor = .kidkPink
        case .cancelled:
            statusBadge.isHidden = false
            statusBadge.text = "취소"
            statusBadge.backgroundColor = .kidkGray
        }

        if let daysRemaining = goal.daysRemaining {
            dDayLabel.isHidden = false
            if daysRemaining > 0 {
                dDayLabel.text = "D-\(daysRemaining)"
            } else if daysRemaining == 0 {
                dDayLabel.text = "D-Day"
            } else {
                dDayLabel.text = "D+\(-daysRemaining)"
            }
        } else {
            dDayLabel.isHidden = true
        }
    }
}

private final class AmountInfoView: UIView {

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
            size: .s14,
            weight: .bold,
            color: .kidkTextWhite,
            lineHeight: 140
        )
        label.textAlignment = .center
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
        addSubview(titleLabel)
        addSubview(valueLabel)

        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        valueLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    func configure(title: String, value: String, color: UIColor) {
        titleLabel.text = title
        valueLabel.text = value
        valueLabel.textColor = color
    }
}

