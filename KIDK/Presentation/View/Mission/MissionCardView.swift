import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class MissionCardView: UIView {

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .cardBackground
        view.layer.cornerRadius = CornerRadius.extraLarge
        return view
    }()

    private let headerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Spacing.xxs
        return stackView
    }()

    private let titleRowView = UIView()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .kidkSubtitle
        label.textColor = .kidkTextWhite
        return label
    }()

    private let collapseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.up"), for: .normal)
        button.tintColor = .chevronGray
        return button
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .kidkBody
        label.textColor = .kidkTextWhite.withAlphaComponent(0.7)
        label.numberOfLines = 0
        return label
    }()

    private let participantsRowView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = Spacing.xxs
        stackView.alignment = .center
        return stackView
    }()

    private let participantsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = -6
        stackView.alignment = .center
        return stackView
    }()

    private let participantsLabel: UILabel = {
        let label = UILabel()
        label.font = .kidkBody
        label.textColor = .kidkTextWhite.withAlphaComponent(0.7)
        return label
    }()

    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.alignment = .fill
        return stackView
    }()

    private let progressContainer = UIView()

    private let circularProgressView: CircularProgressView = {
        let view = CircularProgressView()
        return view
    }()

    private let goalPillContainer = UIView()

    private let whatMissionButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .kidkBody
        button.setTitleColor(.kidkPink, for: .normal)
        button.backgroundColor = .kidkDarkBackground
        button.layer.cornerRadius = 16
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return button
    }()

    private let missionSectionView = UIView()

    private let missionTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "미션"
        label.font = .kidkBody
        label.textColor = .kidkTextWhite
        return label
    }()

    private let missionItemView: UIView = {
        let view = UIView()
        view.backgroundColor = .kidkDarkBackground
        view.layer.cornerRadius = CornerRadius.large
        return view
    }()

    private let missionItemIconContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .cardBackground
        view.layer.cornerRadius = CornerRadius.medium
        return view
    }()

    private let missionItemIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "play.rectangle.fill")
        imageView.tintColor = .kidkTextWhite
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let missionItemTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .kidkBody
        label.textColor = .kidkTextWhite
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private let verifyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("인증하기", for: .normal)
        button.titleLabel?.font = .kidkFont(.s14, .bold)
        button.setTitleColor(.kidkTextWhite, for: .normal)
        button.backgroundColor = .kidkPink
        button.layer.cornerRadius = 13
        return button
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
        containerView.addSubview(headerStackView)
        containerView.addSubview(contentStackView)

        headerStackView.addArrangedSubview(titleRowView)
        headerStackView.addArrangedSubview(subtitleLabel)
        headerStackView.addArrangedSubview(participantsRowView)

        titleRowView.addSubview(titleLabel)
        titleRowView.addSubview(collapseButton)

        participantsRowView.addArrangedSubview(participantsStackView)
        participantsRowView.addArrangedSubview(participantsLabel)

        contentStackView.addArrangedSubview(progressContainer)
        contentStackView.addArrangedSubview(goalPillContainer)
        contentStackView.addArrangedSubview(missionSectionView)

        progressContainer.addSubview(circularProgressView)
        goalPillContainer.addSubview(whatMissionButton)

        missionSectionView.addSubview(missionTitleLabel)
        missionSectionView.addSubview(missionItemView)

        missionItemView.addSubview(missionItemIconContainer)
        missionItemView.addSubview(missionItemTitleLabel)
        missionItemView.addSubview(verifyButton)

        missionItemIconContainer.addSubview(missionItemIconView)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        headerStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(22)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
        }

        titleRowView.snp.makeConstraints { make in
            make.height.equalTo(44)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
        }

        collapseButton.snp.makeConstraints { make in
            make.trailing.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }

        contentStackView.snp.makeConstraints { make in
            make.top.equalTo(headerStackView.snp.bottom).offset(Spacing.lg)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(Spacing.md)
        }

        progressContainer.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(326)
        }

        circularProgressView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(12)
        }

        contentStackView.setCustomSpacing(30, after: progressContainer)

        goalPillContainer.snp.makeConstraints { make in
            make.height.equalTo(32)
        }

        whatMissionButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(32)
        }

        contentStackView.setCustomSpacing(24, after: goalPillContainer)

        missionTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(40)
        }

        missionItemView.snp.makeConstraints { make in
            make.top.equalTo(missionTitleLabel.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(40)
            make.height.equalTo(64)
            make.bottom.equalToSuperview().offset(-19)
        }

        missionItemIconContainer.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }

        missionItemIconView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(20)
        }

        verifyButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.width.equalTo(72)
            make.height.equalTo(26)
        }

        missionItemTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(missionItemIconContainer.snp.trailing).offset(12)
            make.trailing.equalTo(verifyButton.snp.leading).offset(-12)
            make.centerY.equalToSuperview()
        }

        showEmptyState()
    }

    func configure(with mission: Mission?, isCollapsed: Bool) {
        guard let mission = mission else {
            showEmptyState()
            updateCollapseState(isCollapsed: isCollapsed)
            return
        }

        showActiveMission(mission: mission)
        updateCollapseState(isCollapsed: isCollapsed)
    }

    private func showEmptyState() {
        titleLabel.text = Strings.Mission.setGoalInKIDKCity
        subtitleLabel.text = Strings.Mission.setGoalWithFriends

        subtitleLabel.isHidden = false
        participantsRowView.isHidden = true

        missionSectionView.isHidden = true

        whatMissionButton.setTitle(Strings.Mission.whatMissionQuestion, for: .normal)
        whatMissionButton.setTitleColor(.kidkPink, for: .normal)
        whatMissionButton.isUserInteractionEnabled = true

        let placeholderImage = UIImage(named: "kidk_city_school")
        circularProgressView.configureEmpty(image: placeholderImage)
    }

    private func showActiveMission(mission: Mission) {
        titleLabel.text = mission.title

        subtitleLabel.isHidden = true
        participantsRowView.isHidden = false

        missionSectionView.isHidden = false

        setupParticipants(mission.participants)

        let schoolImage = UIImage(named: "kidk_city_school")
        circularProgressView.configure(
            currentAmount: mission.currentAmount,
            targetAmount: mission.targetAmount ?? 0,
            image: schoolImage
        )

        let goalText: String
        if let formattedDate = mission.formattedTargetDate,
           let formattedTarget = mission.formattedTargetAmount {
            goalText = "\(formattedDate) \(formattedTarget) 모으기"
        } else {
            goalText = "목표 달성까지 화이팅!"
        }

        let attributedGoal = NSMutableAttributedString(
            string: goalText,
            attributes: [
                .font: UIFont.kidkBody,
                .foregroundColor: UIColor.kidkTextWhite
            ]
        )

        if let formattedTarget = mission.formattedTargetAmount,
           let range = goalText.range(of: formattedTarget) {
            let nsRange = NSRange(range, in: goalText)
            attributedGoal.addAttributes([
                .foregroundColor: UIColor.kidkPink
            ], range: nsRange)
        }

        whatMissionButton.setAttributedTitle(attributedGoal, for: .normal)
        whatMissionButton.isUserInteractionEnabled = false

        missionItemTitleLabel.text = mission.description ?? "미션을 인증해보세요"
    }

    private func setupParticipants(_ participants: [MissionParticipant]) {
        participantsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let displayParticipants = Array(participants.prefix(3))
        for _ in displayParticipants {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.layer.cornerRadius = 9
            imageView.layer.masksToBounds = true
            imageView.layer.borderWidth = 2
            imageView.layer.borderColor = UIColor.cardBackground.cgColor
            imageView.snp.makeConstraints { make in
                make.width.height.equalTo(18)
            }

            imageView.backgroundColor = .kidkPink

            participantsStackView.addArrangedSubview(imageView)
        }

        if participants.count > 3 {
            participantsLabel.text = "와 \(participants.count - 3)명 목표 진행중"
        } else {
            participantsLabel.text = "와 함께 목표 진행중"
        }
    }

    var collapseButtonTapped: Observable<Void> {
        collapseButton.rx.tap.asObservable()
    }

    var verifyButtonTapped: Observable<Void> {
        verifyButton.rx.tap.asObservable()
    }

    var whatMissionButtonTapped: Observable<Void> {
        whatMissionButton.rx.tap.asObservable()
    }

    private func updateCollapseState(isCollapsed: Bool) {
        let chevronImage = isCollapsed ? "chevron.down" : "chevron.up"
        collapseButton.setImage(UIImage(systemName: chevronImage), for: .normal)

        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: { [weak self] in
            guard let self = self else { return }
            self.contentStackView.isHidden = isCollapsed
            self.layoutIfNeeded()
        })
    }
}
