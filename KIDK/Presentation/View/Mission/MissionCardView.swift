import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class MissionCardView: UIView {
    
    private let disposeBag = DisposeBag()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .cardBackground
        view.layer.cornerRadius = CornerRadius.large
        return view
    }()
    
    private let rootStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Spacing.xs
        return stackView
    }()
    
    private let headerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let contentContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .kidkFont(.s20, .bold)
        label.textColor = .kidkTextWhite
        return label
    }()
    
    private let collapseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.up"), for: .normal)
        button.tintColor = UIColor(hex: "#7F7F7F")
        return button
    }()
    
    private let participantsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = -Spacing.xxs
        stackView.alignment = .center
        return stackView
    }()
    
    private let participantsLabel: UILabel = {
        let label = UILabel()
        label.font = .kidkFont(.s12, .regular)
        label.textColor = .kidkTextWhite.withAlphaComponent(0.8)
        return label
    }()
    
    private let circularProgressView: CircularProgressView = {
        let view = CircularProgressView()
        return view
    }()
    
    private let deadlineLabel: UILabel = {
        let label = UILabel()
        label.font = .kidkFont(.s14, .bold)
        label.textColor = .kidkPink
        label.textAlignment = .center
        return label
    }()
    
    private let missionSectionView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let missionTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "미션"
        label.font = .kidkFont(.s14, .bold)
        label.textColor = .kidkTextWhite
        return label
    }()
    
    private let missionInputContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .kidkDarkBackground
        view.layer.cornerRadius = CornerRadius.medium
        return view
    }()
    
    private let missionIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "pencil")
        imageView.tintColor = .kidkTextWhite.withAlphaComponent(0.6)
        imageView.backgroundColor = .kidkTextWhite.withAlphaComponent(0.1)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let missionPlaceholderLabel: UILabel = {
        let label = UILabel()
        label.text = "[지속적 줄거리] 영상 시청하기"
        label.font = .kidkFont(.s14, .bold)
        label.textColor = .kidkTextWhite
        return label
    }()
    
    private let verifyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("인증하기", for: .normal)
        button.titleLabel?.font = .kidkFont(.s14, .bold)
        button.setTitleColor(.kidkTextWhite.withAlphaComponent(0.8), for: .normal)
        button.backgroundColor = .kidkPink
        button.layer.cornerRadius = CornerRadius.large
        return button
    }()
    
    private let emptyStateView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let emptySubtitleLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.Mission.setGoalWithFriends
        label.font = .kidkBody
        label.textColor = .kidkTextWhite.withAlphaComponent(0.8)
        label.numberOfLines = 0
        return label
    }()
    
    private let emptyProgressCircleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#1C1C1E")
        view.layer.cornerRadius = 100
        return view
    }()
    
    private let treasureIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "star.fill")
        imageView.tintColor = .kidkGray
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let whatMissionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Strings.Mission.whatMissionQuestion, for: .normal)
        button.titleLabel?.font = .kidkBody
        button.setTitleColor(.kidkPink, for: .normal)
        button.backgroundColor = .kidkDarkBackground
        button.layer.cornerRadius = CornerRadius.medium
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
        containerView.addSubview(rootStackView)
        rootStackView.addArrangedSubview(headerView)
        rootStackView.addArrangedSubview(contentContainerView)
        
        headerView.addSubview(titleLabel)
        headerView.addSubview(collapseButton)
        
        contentContainerView.addSubview(participantsStackView)
        contentContainerView.addSubview(participantsLabel)
        contentContainerView.addSubview(circularProgressView)
        contentContainerView.addSubview(deadlineLabel)
        contentContainerView.addSubview(missionSectionView)
        contentContainerView.addSubview(emptyStateView)
        
        missionSectionView.addSubview(missionTitleLabel)
        missionSectionView.addSubview(missionInputContainer)
        missionSectionView.addSubview(verifyButton)
        
        missionInputContainer.addSubview(missionIconView)
        missionInputContainer.addSubview(missionPlaceholderLabel)
        
        emptyStateView.addSubview(emptySubtitleLabel)
        emptyStateView.addSubview(emptyProgressCircleView)
        emptyStateView.addSubview(whatMissionButton)
        
        emptyProgressCircleView.addSubview(treasureIconView)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        rootStackView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview().inset(Spacing.md)
        }
        
        headerView.snp.makeConstraints { make in
            make.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
        }
        
        collapseButton.snp.makeConstraints { make in
            make.trailing.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        participantsStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Spacing.xs)
            make.leading.equalToSuperview()
            make.height.equalTo(24)
        }
        
        participantsLabel.snp.makeConstraints { make in
            make.leading.equalTo(participantsStackView.snp.trailing).offset(Spacing.xxs)
            make.centerY.equalTo(participantsStackView)
        }
        
        circularProgressView.snp.makeConstraints { make in
            make.top.equalTo(participantsStackView.snp.bottom).offset(Spacing.md)
            make.centerX.equalToSuperview()
            make.size.equalTo(310)
        }
        
        deadlineLabel.snp.makeConstraints { make in
            make.top.equalTo(circularProgressView.snp.bottom).offset(Spacing.md)
            make.centerX.equalToSuperview()
        }
        
        missionSectionView.snp.makeConstraints { make in
            make.top.equalTo(deadlineLabel.snp.bottom).offset(Spacing.xl)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        missionTitleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
        }
        
        missionInputContainer.snp.makeConstraints { make in
            make.top.equalTo(missionTitleLabel.snp.bottom).offset(Spacing.xs)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(48)
        }
        
        missionIconView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Spacing.sm)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        missionPlaceholderLabel.snp.makeConstraints { make in
            make.leading.equalTo(missionIconView.snp.trailing).offset(Spacing.xs)
            make.centerY.equalToSuperview()
        }
        
        verifyButton.snp.makeConstraints { make in
            make.top.equalTo(missionInputContainer.snp.bottom).offset(Spacing.sm)
            make.trailing.equalToSuperview()
            make.height.equalTo(40)
            make.width.equalTo(100)
            make.bottom.equalToSuperview()
        }
        
        emptyStateView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        emptySubtitleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        emptyProgressCircleView.snp.makeConstraints { make in
            make.top.equalTo(emptySubtitleLabel.snp.bottom).offset(Spacing.xl)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(200)
        }
        
        treasureIconView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(80)
        }
        
        whatMissionButton.snp.makeConstraints { make in
            make.top.equalTo(emptyProgressCircleView.snp.bottom).offset(Spacing.xl)
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
            make.width.equalTo(200)
            make.bottom.equalToSuperview()
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
        emptyStateView.isHidden = false
        participantsStackView.isHidden = true
        participantsLabel.isHidden = true
        circularProgressView.isHidden = true
        deadlineLabel.isHidden = true
        missionSectionView.isHidden = true
    }
    
    private func showActiveMission(mission: Mission) {
        titleLabel.text = mission.title
        emptyStateView.isHidden = true
        participantsStackView.isHidden = false
        participantsLabel.isHidden = false
        circularProgressView.isHidden = false
        deadlineLabel.isHidden = false
        missionSectionView.isHidden = false
        
        setupParticipants(mission.participants)
        
        let schoolImage = UIImage(named: "kidk_city_school")
        circularProgressView.configure(
            currentAmount: mission.currentAmount,
            targetAmount: mission.targetAmount ?? 0,
            image: schoolImage
        )
        
        if let formattedDate = mission.formattedTargetDate,
           let formattedTarget = mission.formattedTargetAmount {
            deadlineLabel.text = "\(formattedDate) \(formattedTarget) 모으기"
        } else {
            deadlineLabel.text = "목표 달성까지 화이팅!"
        }
    }
    
    private func setupParticipants(_ participants: [MissionParticipant]) {
        participantsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let displayParticipants = Array(participants.prefix(3))
        for _ in displayParticipants {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.layer.cornerRadius = 12
            imageView.layer.masksToBounds = true
            imageView.layer.borderWidth = 2
            imageView.layer.borderColor = UIColor.cardBackground.cgColor
            imageView.snp.makeConstraints { make in
                make.width.height.equalTo(24)
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
            self.contentContainerView.isHidden = isCollapsed
            self.layoutIfNeeded()
        })
    }
}
