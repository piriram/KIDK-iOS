import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class MissionCardView: UIView {

    private enum CardVisualState {
        case beforeMission
        case afterMissionCreated
        case inProgress
        case completed
    }

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
        label.numberOfLines = 2
        return label
    }()

    private let statusBadgeLabel: UILabel = {
        let label = UILabel()
        label.font = .kidkFont(.s10, .bold)
        label.textAlignment = .center
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        label.isHidden = true
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
        label.textColor = .kidkTextWhite.withAlphaComponent(0.78)
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
        button.layer.cornerRadius = 18
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 18, bottom: 6, right: 18)
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
        titleRowView.addSubview(statusBadgeLabel)
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
            make.height.greaterThanOrEqualTo(44)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualTo(statusBadgeLabel.snp.leading).offset(-Spacing.xs)
        }

        statusBadgeLabel.snp.makeConstraints { make in
            make.trailing.equalTo(collapseButton.snp.leading).offset(-8)
            make.centerY.equalToSuperview()
            make.height.equalTo(20)
            make.width.greaterThanOrEqualTo(48)
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
            make.height.equalTo(352)
        }

        circularProgressView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(8)
        }

        contentStackView.setCustomSpacing(26, after: progressContainer)

        goalPillContainer.snp.makeConstraints { make in
            make.height.equalTo(36)
        }

        whatMissionButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(36)
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
        guard let mission else {
            showEmptyState()
            updateCollapseState(isCollapsed: false)
            return
        }

        let state = visualState(for: mission)
        showMissionState(mission: mission, state: state)
        updateCollapseState(isCollapsed: isCollapsed)
    }

    private func visualState(for mission: Mission) -> CardVisualState {
        if mission.status == .completed || mission.progressPercentage >= 100 {
            return .completed
        }

        if mission.currentAmount <= 0 {
            return .afterMissionCreated
        }

        return .inProgress
    }

    private func showMissionState(mission: Mission, state: CardVisualState) {
        titleLabel.text = mission.title

        subtitleLabel.isHidden = true
        participantsRowView.isHidden = false
        missionSectionView.isHidden = false
        collapseButton.isHidden = false
        collapseButton.isEnabled = true

        setupParticipants(mission.participants)
        missionItemIconView.image = missionIcon(for: mission.missionType)
        missionItemIconView.tintColor = .kidkTextWhite
        missionItemIconContainer.backgroundColor = .cardBackground
        whatMissionButton.isUserInteractionEnabled = false

        switch state {
        case .beforeMission:
            showEmptyState()

        case .afterMissionCreated:
            statusBadgeLabel.isHidden = false
            statusBadgeLabel.text = "시작 전"
            statusBadgeLabel.textColor = .kidkPink
            statusBadgeLabel.backgroundColor = .kidkPink.withAlphaComponent(0.16)

            subtitleLabel.isHidden = false
            subtitleLabel.text = "미션이 만들어졌어요. 첫 저축을 시작해봐요!"

            circularProgressView.configure(
                currentAmount: mission.currentAmount,
                targetAmount: mission.targetAmount ?? 0,
                image: UIImage(named: "kidk_city_school"),
                accentColor: .kidkPink,
                showsCompletionBadge: false
            )

            applyFilledGoalPill(text: "\(mission.title) GO", color: .kidkPink)
            missionItemTitleLabel.text = mission.description ?? "첫 미션 인증을 시작해보세요"
            applyVerifyButton(title: "시작", backgroundColor: .kidkPink, textColor: .kidkTextWhite, enabled: true)

        case .inProgress:
            statusBadgeLabel.isHidden = false
            statusBadgeLabel.text = "진행 중"
            statusBadgeLabel.textColor = .kidkPink
            statusBadgeLabel.backgroundColor = .kidkPink.withAlphaComponent(0.16)

            circularProgressView.configure(
                currentAmount: mission.currentAmount,
                targetAmount: mission.targetAmount ?? 0,
                image: UIImage(named: "kidk_city_school"),
                accentColor: .kidkPink,
                showsCompletionBadge: false
            )

            let goalText: String
            if let formattedDate = mission.formattedTargetDate,
               let formattedTarget = mission.formattedTargetAmount {
                goalText = "\(formattedDate) \(formattedTarget) 모으기"
            } else {
                goalText = "목표 달성까지 화이팅!"
            }

            applyOutlinedGoalPill(text: goalText, color: .kidkPink)
            missionItemTitleLabel.text = mission.description ?? "미션을 인증해보세요"
            applyVerifyButton(title: "인증하기", backgroundColor: .kidkPink, textColor: .kidkTextWhite, enabled: true)

        case .completed:
            statusBadgeLabel.isHidden = false
            statusBadgeLabel.text = "완료"
            statusBadgeLabel.textColor = .kidkGreen
            statusBadgeLabel.backgroundColor = .kidkGreen.withAlphaComponent(0.18)

            subtitleLabel.isHidden = false
            subtitleLabel.text = "목표를 달성했어요! 정말 잘했어요 🎉"

            circularProgressView.configure(
                currentAmount: mission.targetAmount ?? mission.currentAmount,
                targetAmount: mission.targetAmount ?? mission.currentAmount,
                image: UIImage(named: "kidk_city_school"),
                accentColor: .kidkGreen,
                showsCompletionBadge: true
            )

            applyFilledGoalPill(text: "미션 완료!", color: .kidkGreen)
            missionItemTitleLabel.text = mission.description ?? "성공적으로 미션을 완료했어요"
            missionItemIconView.image = UIImage(systemName: "checkmark.seal.fill")
            missionItemIconView.tintColor = .kidkGreen
            missionItemIconContainer.backgroundColor = .kidkGreen.withAlphaComponent(0.16)
            applyVerifyButton(
                title: "완료",
                backgroundColor: .kidkGreen.withAlphaComponent(0.2),
                textColor: .kidkGreen,
                enabled: false
            )
        }
    }

    private func showEmptyState() {
        titleLabel.text = Strings.Mission.setGoalInKIDKCity
        subtitleLabel.text = Strings.Mission.setGoalWithFriends

        subtitleLabel.isHidden = false
        participantsRowView.isHidden = true
        missionSectionView.isHidden = true

        collapseButton.isHidden = true
        collapseButton.isEnabled = false
        statusBadgeLabel.isHidden = true

        applyOutlinedGoalPill(text: Strings.Mission.whatMissionQuestion, color: .kidkPink)
        whatMissionButton.isUserInteractionEnabled = true

        let placeholderImage = UIImage(named: "kidk_city_school")
        circularProgressView.configureEmpty(image: placeholderImage)
    }

    private func applyOutlinedGoalPill(text: String, color: UIColor) {
        whatMissionButton.backgroundColor = .kidkBlack
        whatMissionButton.setAttributedTitle(
            NSAttributedString(
                string: text,
                attributes: [
                    .font: UIFont.kidkBody,
                    .foregroundColor: color
                ]
            ),
            for: .normal
        )
    }

    private func applyFilledGoalPill(text: String, color: UIColor) {
        whatMissionButton.backgroundColor = color
        whatMissionButton.setAttributedTitle(
            NSAttributedString(
                string: text,
                attributes: [
                    .font: UIFont.kidkBody,
                    .foregroundColor: UIColor.kidkTextWhite
                ]
            ),
            for: .normal
        )
    }

    private func applyVerifyButton(title: String, backgroundColor: UIColor, textColor: UIColor, enabled: Bool) {
        verifyButton.setTitle(title, for: .normal)
        verifyButton.backgroundColor = backgroundColor
        verifyButton.setTitleColor(textColor, for: .normal)
        verifyButton.isEnabled = enabled
        verifyButton.alpha = enabled ? 1.0 : 0.95
    }

    private func missionIcon(for missionType: MissionType) -> UIImage? {
        switch missionType {
        case .video:
            return preferredImage(named: "kidk_mission_video", fallbackSystemName: "play.rectangle.fill")
        case .study:
            return preferredImage(named: "kidk_mission_study", fallbackSystemName: "pencil")
        case .quiz:
            return preferredImage(named: "kidk_mission_quiz", fallbackSystemName: "character.book.closed")
        case .savings:
            return preferredImage(named: "kidk_mission_savings", fallbackSystemName: "wallet.pass.fill")
        case .custom:
            return preferredImage(named: "kidk_icon_mission_new", fallbackSystemName: "flag.fill")
        }
    }

    private func preferredImage(named assetName: String, fallbackSystemName: String) -> UIImage? {
        if let assetImage = UIImage(named: assetName) {
            return assetImage
        }
        return UIImage(systemName: fallbackSystemName)
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

            imageView.image = UIImage(named: "kidk_profile_one")
            if imageView.image == nil {
                imageView.image = UIImage(systemName: "person.fill")
                imageView.tintColor = .kidkTextWhite.withAlphaComponent(0.8)
                imageView.backgroundColor = .kidkTextSecondary
                imageView.contentMode = .center
            }

            participantsStackView.addArrangedSubview(imageView)
        }

        if participants.isEmpty {
            participantsLabel.text = "나의 목표 진행중"
        } else if participants.count > 3 {
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
        guard !collapseButton.isHidden else {
            contentStackView.isHidden = false
            return
        }

        let chevronImage = isCollapsed ? "chevron.down" : "chevron.up"
        collapseButton.setImage(UIImage(systemName: chevronImage), for: .normal)

        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: { [weak self] in
            guard let self = self else { return }
            self.contentStackView.isHidden = isCollapsed
            self.layoutIfNeeded()
        })
    }
}
