import UIKit
import SnapKit

enum ParentTimelineTone {
    case pink
    case green
    case blue
    case gray
    case red

    var tintColor: UIColor {
        switch self {
        case .pink:
            return .kidkPink
        case .green:
            return .kidkGreen
        case .blue:
            return .kidkBlue
        case .gray:
            return .kidkGray
        case .red:
            return .systemRed
        }
    }

    var backgroundColor: UIColor {
        tintColor.withAlphaComponent(0.16)
    }
}

final class ParentTimelineSectionHeaderView: UIView {

    private let stepContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .kidkPink.withAlphaComponent(0.18)
        view.layer.cornerRadius = CornerRadius.small
        return view
    }()

    private let stepLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s10, .bold)
        label.textColor = .kidkPinkLight
        label.textAlignment = .center
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s20, .bold)
        label.textColor = .kidkTextWhite
        label.numberOfLines = 0
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s14, .regular)
        label.textColor = .kidkGray
        label.numberOfLines = 0
        return label
    }()

    private let textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()

    private var stepHeightConstraint: Constraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(stepContainerView)
        addSubview(textStackView)

        stepContainerView.addSubview(stepLabel)

        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(subtitleLabel)

        stepContainerView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            stepHeightConstraint = make.height.equalTo(24).constraint
        }

        stepLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: Spacing.xs, bottom: 4, right: Spacing.xs))
        }

        textStackView.snp.makeConstraints { make in
            make.top.equalTo(stepContainerView.snp.bottom).offset(Spacing.xs)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    func configure(step: String? = nil, title: String, subtitle: String? = nil) {
        if let step, !step.isEmpty {
            stepLabel.text = step
            stepContainerView.isHidden = false
            stepHeightConstraint?.update(offset: 24)
        } else {
            stepContainerView.isHidden = true
            stepHeightConstraint?.update(offset: 0)
        }

        titleLabel.text = title

        if let subtitle, !subtitle.isEmpty {
            subtitleLabel.text = subtitle
            subtitleLabel.isHidden = false
        } else {
            subtitleLabel.isHidden = true
        }
    }
}

final class ParentTimelineCardView: UIView {

    let contentView = UIView()

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .cardBackground
        view.layer.cornerRadius = CornerRadius.large
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.kidkTextWhite.withAlphaComponent(0.06).cgColor
        return view
    }()

    private let accentBarView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = CornerRadius.small
        return view
    }()

    init(accentColor: UIColor = .kidkPink) {
        super.init(frame: .zero)
        accentBarView.backgroundColor = accentColor
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(containerView)
        containerView.addSubview(accentBarView)
        containerView.addSubview(contentView)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        accentBarView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Spacing.xs)
            make.leading.equalToSuperview().offset(Spacing.md)
            make.width.equalTo(44)
            make.height.equalTo(4)
        }

        contentView.snp.makeConstraints { make in
            make.top.equalTo(accentBarView.snp.bottom).offset(Spacing.sm)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
            make.bottom.equalToSuperview().offset(-Spacing.md)
        }
    }

    func setAccentColor(_ color: UIColor) {
        accentBarView.backgroundColor = color
    }
}

final class ParentTimelineStatusBadgeView: UIView {

    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = CornerRadius.small
        return view
    }()

    private let textLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s12, .bold)
        label.textAlignment = .center
        label.numberOfLines = 1
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
        containerView.addSubview(textLabel)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        textLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 6, left: Spacing.xs, bottom: 6, right: Spacing.xs))
        }

        snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(28)
        }
    }

    func configure(text: String, tone: ParentTimelineTone) {
        textLabel.text = text
        textLabel.textColor = tone.tintColor
        containerView.backgroundColor = tone.backgroundColor
    }
}

final class ParentTimelineProgressRowView: UIView {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s14, .medium)
        label.textColor = .kidkGray
        return label
    }()

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s12, .bold)
        label.textColor = .kidkTextWhite
        label.textAlignment = .right
        return label
    }()

    private let trackView: UIView = {
        let view = UIView()
        view.backgroundColor = .kidkDarkBackground.withAlphaComponent(0.7)
        view.layer.cornerRadius = 4
        return view
    }()

    private let progressView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4
        return view
    }()

    private var progressWidthConstraint: Constraint?

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
        addSubview(trackView)
        trackView.addSubview(progressView)

        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
        }

        valueLabel.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalToSuperview()
            make.leading.greaterThanOrEqualTo(titleLabel.snp.trailing).offset(Spacing.xs)
        }

        trackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Spacing.xxs)
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(8)
        }

        progressView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            progressWidthConstraint = make.width.equalTo(0).constraint
        }
    }

    func configure(title: String, valueText: String, progress: CGFloat, tintColor: UIColor) {
        titleLabel.text = title
        valueLabel.text = valueText
        progressView.backgroundColor = tintColor

        let clamped = max(0, min(progress, 1))
        progressView.snp.remakeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            progressWidthConstraint = make.width.equalTo(trackView.snp.width).multipliedBy(clamped).constraint
        }
        layoutIfNeeded()
    }
}
