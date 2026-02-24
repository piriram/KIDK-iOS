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
        view.layer.cornerRadius = CornerRadius.large
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        return view
    }()

    private let iconContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .kidkPink.withAlphaComponent(0.18)
        view.layer.cornerRadius = CornerRadius.medium
        return view
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
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
            lineHeight: 135
        )
        label.numberOfLines = 1
        return label
    }()

    private let chevronImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .kidkGray
        return imageView
    }()

    private let badgeStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = Spacing.xs
        stackView.alignment = .leading
        return stackView
    }()

    private let statusBadge = BadgeLabel()
    private let dDayLabel = BadgeLabel()
    private let progressBadge = BadgeLabel()

    private let progressLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(
            text: "",
            size: .s14,
            weight: .medium,
            color: .kidkTextWhite,
            lineHeight: 140
        )
        return label
    }()

    private let progressBar: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.progressTintColor = .kidkPink
        progressView.trackTintColor = UIColor.white.withAlphaComponent(0.12)
        progressView.transform = CGAffineTransform(scaleX: 1, y: 1.9)
        progressView.layer.cornerRadius = 6
        progressView.clipsToBounds = true
        progressView.layer.sublayers?.forEach { layer in
            layer.cornerRadius = 6
            layer.masksToBounds = true
        }
        return progressView
    }()

    private let amountStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = Spacing.xs
        return stackView
    }()

    private let currentAmountView = AmountInfoView()
    private let remainingAmountView = AmountInfoView()
    private let targetAmountView = AmountInfoView()

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

        containerView.addSubview(iconContainerView)
        iconContainerView.addSubview(iconImageView)

        containerView.addSubview(nameLabel)
        containerView.addSubview(chevronImageView)
        containerView.addSubview(badgeStackView)
        containerView.addSubview(progressLabel)
        containerView.addSubview(progressBadge)
        containerView.addSubview(progressBar)
        containerView.addSubview(amountStackView)

        amountStackView.addArrangedSubview(currentAmountView)
        amountStackView.addArrangedSubview(remainingAmountView)
        amountStackView.addArrangedSubview(targetAmountView)

        badgeStackView.addArrangedSubview(statusBadge)
        badgeStackView.addArrangedSubview(dDayLabel)

        statusBadge.isHidden = true
        dDayLabel.isHidden = true

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        iconContainerView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(Spacing.md)
            make.width.height.equalTo(56)
        }

        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(26)
        }

        chevronImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(Spacing.md)
            make.centerY.equalTo(nameLabel.snp.centerY)
            make.width.equalTo(8)
            make.height.equalTo(14)
        }

        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(Spacing.md)
            make.leading.equalTo(iconContainerView.snp.trailing).offset(Spacing.sm)
            make.trailing.equalTo(chevronImageView.snp.leading).offset(-Spacing.sm)
        }

        badgeStackView.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(Spacing.xxs)
            make.leading.equalTo(iconContainerView.snp.trailing).offset(Spacing.sm)
        }

        progressLabel.snp.makeConstraints { make in
            make.top.equalTo(iconContainerView.snp.bottom).offset(Spacing.md)
            make.leading.equalToSuperview().inset(Spacing.md)
            make.trailing.lessThanOrEqualTo(progressBadge.snp.leading).offset(-Spacing.sm)
        }

        progressBadge.snp.makeConstraints { make in
            make.centerY.equalTo(progressLabel)
            make.trailing.equalToSuperview().inset(Spacing.md)
            make.height.greaterThanOrEqualTo(24)
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

        accessibilityTraits = [.button]
    }

    private func bind() {
        let tapGesture = UITapGestureRecognizer()
        containerView.addGestureRecognizer(tapGesture)

        tapGesture.rx.event
            .subscribe(onNext: { [weak self] _ in
                guard let self, let goal = self.goal else { return }

                UIView.animate(withDuration: 0.12, animations: {
                    self.containerView.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
                }, completion: { _ in
                    UIView.animate(withDuration: 0.15) {
                        self.containerView.transform = .identity
                    }
                })

                UISelectionFeedbackGenerator().selectionChanged()
                self.cardTapped.accept(goal)
            })
            .disposed(by: disposeBag)
    }

    func configure(with goal: SavingsGoal) {
        self.goal = goal

        nameLabel.text = goal.name

        if let imageName = goal.imageName {
            iconImageView.image = UIImage(systemName: imageName) ?? UIImage(systemName: "banknote.fill")
        } else {
            iconImageView.image = UIImage(systemName: "banknote.fill")
        }

        let progressPercentage = goal.progressPercentage
        progressLabel.text = "\(goal.formattedCurrentAmount) / \(goal.formattedTargetAmount)"
        progressBadge.text = String(format: "%.1f%%", progressPercentage)
        progressBar.setProgress(Float(progressPercentage / 100), animated: true)

        currentAmountView.configure(title: "현재", value: goal.formattedCurrentAmount, color: .kidkGreen)
        remainingAmountView.configure(title: "남은", value: goal.formattedRemainingAmount, color: .kidkTextWhite)
        targetAmountView.configure(title: "목표", value: goal.formattedTargetAmount, color: .kidkPink)

        switch goal.status {
        case .inProgress:
            statusBadge.isHidden = false
            statusBadge.text = "진행 중"
            statusBadge.backgroundColor = .kidkGreen.withAlphaComponent(0.2)
            statusBadge.textColor = .kidkGreen
            progressBar.progressTintColor = .kidkPink
            iconContainerView.backgroundColor = .kidkPink.withAlphaComponent(0.18)
            iconImageView.tintColor = .kidkPink
        case .completed:
            statusBadge.isHidden = false
            statusBadge.text = "달성"
            statusBadge.backgroundColor = .kidkGreen.withAlphaComponent(0.2)
            statusBadge.textColor = .kidkGreen
            progressBar.progressTintColor = .kidkGreen
            iconContainerView.backgroundColor = .kidkGreen.withAlphaComponent(0.18)
            iconImageView.tintColor = .kidkGreen
        case .cancelled:
            statusBadge.isHidden = false
            statusBadge.text = "취소"
            statusBadge.backgroundColor = .kidkGray.withAlphaComponent(0.2)
            statusBadge.textColor = .kidkGray
            progressBar.progressTintColor = .kidkGray
            iconContainerView.backgroundColor = .kidkGray.withAlphaComponent(0.2)
            iconImageView.tintColor = .kidkGray
        }

        if let daysRemaining = goal.daysRemaining {
            dDayLabel.isHidden = false
            if daysRemaining > 0 {
                dDayLabel.text = "D-\(daysRemaining)"
                dDayLabel.backgroundColor = .kidkBlue.withAlphaComponent(0.2)
                dDayLabel.textColor = .kidkBlue
            } else if daysRemaining == 0 {
                dDayLabel.text = "D-Day"
                dDayLabel.backgroundColor = .kidkPink.withAlphaComponent(0.22)
                dDayLabel.textColor = .kidkPink
            } else {
                dDayLabel.text = "D+\(-daysRemaining)"
                dDayLabel.backgroundColor = .kidkGray.withAlphaComponent(0.2)
                dDayLabel.textColor = .kidkGray
            }
        } else {
            dDayLabel.isHidden = true
        }

        accessibilityLabel = "\(goal.name), 진행률 \(String(format: "%.1f", progressPercentage))퍼센트, 현재 \(goal.formattedCurrentAmount), 목표 \(goal.formattedTargetAmount)"
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
            lineHeight: 130
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
            lineHeight: 130
        )
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.75
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
        layer.cornerRadius = CornerRadius.small

        addSubview(titleLabel)
        addSubview(valueLabel)

        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(6)
        }

        valueLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(6)
            make.bottom.equalToSuperview().inset(6)
        }

        snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(58)
        }
    }

    func configure(title: String, value: String, color: UIColor) {
        titleLabel.text = title
        valueLabel.text = value
        valueLabel.textColor = color
    }
}

private final class BadgeLabel: UILabel {

    private let horizontalPadding: CGFloat = 10
    private let verticalPadding: CGFloat = 4

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(
            top: verticalPadding,
            left: horizontalPadding,
            bottom: verticalPadding,
            right: horizontalPadding
        )
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + horizontalPadding * 2,
            height: size.height + verticalPadding * 2
        )
    }

    private func configureUI() {
        applyTextStyle(
            text: "",
            size: .s12,
            weight: .bold,
            color: .kidkTextWhite,
            lineHeight: 120
        )
        textAlignment = .center
        layer.cornerRadius = 12
        clipsToBounds = true
        setContentCompressionResistancePriority(.required, for: .horizontal)
    }
}
