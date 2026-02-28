import UIKit
import SnapKit

final class ChildInfoHeaderView: UIView {

    private let cardView = ParentTimelineCardView(accentColor: .kidkBlue)

    private let profileImageView = ProfileImageView(
        assetName: "kidk_profile_one",
        size: 60,
        bgColor: .white,
        iconRatio: 0.7
    )

    private let profileTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "아이 성장 현황"
        label.font = .kidkFont(.s12, .medium)
        label.textColor = .kidkGray
        return label
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .kidkFont(.s22, .bold)
        label.textColor = .kidkTextWhite
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.82
        return label
    }()

    private let growthStatusBadgeView = ParentTimelineStatusBadgeView()

    private let infoTextStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 2
        return stackView
    }()

    private let headerInfoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = Spacing.xs
        stackView.alignment = .center
        return stackView
    }()

    private let statsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = Spacing.xs
        stackView.distribution = .fillEqually
        return stackView
    }()

    private let levelInfoView = ChildInfoMetricView(title: "레벨", accentColor: .kidkPink)
    private let pointsInfoView = ChildInfoMetricView(title: "보유 KP", accentColor: .kidkGreen)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(cardView)

        cardView.contentView.addSubview(headerInfoStackView)
        cardView.contentView.addSubview(statsStackView)

        headerInfoStackView.addArrangedSubview(profileImageView)
        headerInfoStackView.addArrangedSubview(infoTextStackView)
        headerInfoStackView.addArrangedSubview(growthStatusBadgeView)

        infoTextStackView.addArrangedSubview(profileTitleLabel)
        infoTextStackView.addArrangedSubview(nameLabel)

        statsStackView.addArrangedSubview(levelInfoView)
        statsStackView.addArrangedSubview(pointsInfoView)

        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        headerInfoStackView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        growthStatusBadgeView.snp.makeConstraints { make in
            make.width.greaterThanOrEqualTo(72)
        }

        statsStackView.snp.makeConstraints { make in
            make.top.equalTo(headerInfoStackView.snp.bottom).offset(Spacing.sm)
            make.leading.trailing.bottom.equalToSuperview()
        }

        cardView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(156)
        }

        growthStatusBadgeView.configure(text: "성장중", tone: .blue)
    }

    func configure(name: String, level: Int, points: Int, profileImageURL: String? = nil) {
        nameLabel.text = name
        levelInfoView.configure(value: "Lv.\(level)")
        pointsInfoView.configure(value: "\(points) KP")

        let tone: ParentTimelineTone = level >= 10 ? .green : .blue
        let statusText = level >= 10 ? "안정 성장" : "성장중"
        growthStatusBadgeView.configure(text: statusText, tone: tone)

        // TODO: profileImageURL이 있으면 이미지 로드 로직 추가
        _ = profileImageURL
    }

    func setCompactLayout(_ isCompact: Bool) {
        statsStackView.axis = isCompact ? .vertical : .horizontal
        statsStackView.distribution = .fillEqually
    }
}

private final class ChildInfoMetricView: UIView {

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .kidkDarkBackground.withAlphaComponent(0.42)
        view.layer.cornerRadius = CornerRadius.medium
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .kidkFont(.s12, .medium)
        label.textColor = .kidkGray
        return label
    }()

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .kidkFont(.s16, .bold)
        label.textColor = .kidkTextWhite
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.85
        return label
    }()

    private let accentBarView = UIView()

    init(title: String, accentColor: UIColor) {
        super.init(frame: .zero)
        titleLabel.text = title
        accentBarView.backgroundColor = accentColor
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(containerView)
        containerView.addSubview(accentBarView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(valueLabel)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        accentBarView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Spacing.xs)
            make.centerY.equalToSuperview()
            make.width.equalTo(4)
            make.height.equalTo(24)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Spacing.xs)
            make.leading.equalTo(accentBarView.snp.trailing).offset(Spacing.xs)
            make.trailing.equalToSuperview().offset(-Spacing.xs)
        }

        valueLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Spacing.xxs)
            make.leading.trailing.equalTo(titleLabel)
            make.bottom.equalToSuperview().offset(-Spacing.xs)
        }

        containerView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(72)
        }
    }

    func configure(value: String) {
        valueLabel.text = value
    }
}
