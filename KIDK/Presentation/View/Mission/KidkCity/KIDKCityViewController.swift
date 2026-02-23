import UIKit
import SpriteKit
import RxSwift
import RxCocoa
import SnapKit

final class KIDKCityViewController: BaseViewController, NavigationChromeConfigurable {

    private let viewModel: KIDKCityViewModel
    private let user: User
    private let viewDidAppearSubject = PublishSubject<Void>()
    private let missionCompletedSubject = PublishSubject<String>()

    private let gameView: SKView = {
        let view = SKView()
        view.ignoresSiblingOrder = true
        view.showsFPS = false
        view.showsNodeCount = false
        view.backgroundColor = .clear
        return view
    }()

    private let hudContainerView = UIView()

    private let gaugeTitleLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(text: "미션 게이지", size: .s14, weight: .bold, color: .kidkTextWhite)
        return label
    }()

    private let gaugeValueLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(text: "0%", size: .s14, weight: .bold, color: .kidkPink)
        return label
    }()

    private let levelLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(text: "Lv.1", size: .s12, weight: .medium, color: .kidkTextWhite.withAlphaComponent(0.8))
        return label
    }()

    private let gaugeProgressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .default)
        progress.progressTintColor = .kidkPink
        progress.trackTintColor = UIColor.white.withAlphaComponent(0.2)
        progress.layer.cornerRadius = 4
        progress.clipsToBounds = true
        return progress
    }()

    private let schoolMissionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("학교 미션 시작", for: .normal)
        button.setTitleColor(.kidkTextWhite, for: .normal)
        button.backgroundColor = .kidkPink
        button.layer.cornerRadius = CornerRadius.medium
        return button
    }()

    private let homeButton: IconContainerView = {
        let button = IconContainerView(
            "kidk_icon_home",
            backgroundColor: .cardBackground,
            size: 48,
            cornerRadius: 16,
            iconSize: 30,
            alpha: 0.9
        )
        button.isUserInteractionEnabled = true
        return button
    }()

    // MARK: - Map guide overlays

    private let mapGuideBubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#1F1F22").withAlphaComponent(0.88)
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        return view
    }()

    private let mapGuideIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let mapGuideTitleLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(text: "키득시티 가이드", size: .s12, weight: .bold, color: .kidkPink)
        return label
    }()

    private let mapGuideDescriptionLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(
            text: "건물1(학교)을 눌러\n첫 미션을 시작해요",
            size: .s12,
            weight: .medium,
            color: .kidkTextWhite,
            lineHeight: 128
        )
        label.numberOfLines = 2
        return label
    }()

    private let mapGuideArrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let missionClockBadgeView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#1F1F22").withAlphaComponent(0.9)
        view.layer.cornerRadius = 14
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        return view
    }()

    private let missionClockIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let missionClockLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(text: "오늘 추천 미션 3개", size: .s12, weight: .medium, color: .kidkTextWhite)
        return label
    }()

    private let martGuideBadgeView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#1F1F22").withAlphaComponent(0.9)
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        return view
    }()

    private let martGuideIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let martGuideLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(text: "마트 Lv.2 오픈", size: .s10, weight: .medium, color: .kidkTextWhite)
        return label
    }()

    // MARK: - Building mission detail overlay

    private let missionDetailDimButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        button.alpha = 0
        button.isHidden = true
        return button
    }()

    private let buildingMissionCardView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#1A1B20")
        view.layer.cornerRadius = 28
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.clipsToBounds = true
        view.alpha = 0
        view.isHidden = true
        return view
    }()

    private let buildingMissionGrabberView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        view.layer.cornerRadius = 2.5
        return view
    }()

    private let buildingMissionBackgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.isHidden = true
        return imageView
    }()

    private let buildingMissionTitleLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(text: "미션", size: .s26, weight: .bold, color: .kidkTextWhite)
        return label
    }()

    private let buildingMissionRewardLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(text: "2000원", size: .s36, weight: .bold, color: .kidkTextWhite)
        return label
    }()

    private let buildingMissionCloseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .kidkGray
        button.isHidden = true
        return button
    }()

    private let buildingMissionMainCardView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#2A2C35")
        view.layer.cornerRadius = 24
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.04).cgColor
        return view
    }()

    private let buildingMissionTagStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 10
        return stackView
    }()

    private let buildingMissionVideoTagLabel: CityMissionChipLabel = {
        let label = CityMissionChipLabel()
        label.applyFilledStyle(text: "영상 시청", fillColor: UIColor(hex: "#E965A5"), textColor: .kidkTextWhite)
        return label
    }()

    private let buildingMissionQuizTagLabel: CityMissionChipLabel = {
        let label = CityMissionChipLabel()
        label.applyFilledStyle(text: "퀴즈 풀기", fillColor: UIColor(hex: "#84DDCD"), textColor: .kidkTextWhite)
        return label
    }()

    private let buildingMissionDescriptionLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(
            text: "[저축의 즐거움]\n매일 영상 시청 후 퀴즈를 풀기",
            size: .s16,
            weight: .bold,
            color: .kidkTextWhite,
            lineHeight: 122
        )
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()

    private let buildingMissionItemView: UIView = {
        let view = UIView()
        view.backgroundColor = .kidkDarkBackground
        view.layer.cornerRadius = 14
        return view
    }()

    private let buildingMissionItemIconContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .cardBackground
        view.layer.cornerRadius = 10
        return view
    }()

    private let buildingMissionItemIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let buildingMissionItemTitleLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(text: "내가 몰랐던 저축의 즐거움을 알아보아요!", size: .s12, weight: .medium, color: .kidkTextWhite)
        return label
    }()

    private let buildingMissionParticipantsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = -8
        stackView.alignment = .center
        return stackView
    }()

    private let buildingMissionParticipantsLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(text: "가 이 미션에 참여했어요", size: .s12, weight: .medium, color: .kidkGray)
        return label
    }()

    private let buildingMissionOtherButton = KIDKButton(
        title: "다른 미션",
        backgroundColor: UIColor(hex: "#2F313A"),
        titleColor: .kidkTextWhite
    )

    private let buildingMissionStartButton = KIDKButton(
        title: "미션 수락하기",
        backgroundColor: .kidkPink,
        titleColor: .kidkTextWhite
    )

    // MARK: - Mission completed popup

    private let missionCompletedPopupView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#2B2B31")
        view.layer.cornerRadius = 24
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        view.alpha = 0
        view.isHidden = true
        return view
    }()

    private let missionCompletedTitleLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(text: "미션을 완료했어요!", size: .s18, weight: .bold, color: .kidkTextWhite)
        return label
    }()

    private let missionCompletedDescriptionLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(
            text: "완료 버튼을 눌러 미션 내용을\n부모님께 전달해보세요!",
            size: .s14,
            weight: .medium,
            color: .kidkTextWhite,
            lineHeight: 132
        )
        label.numberOfLines = 2
        return label
    }()

    private let missionCompletedGiftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let missionCompletedConfirmButton = KIDKButton(
        title: "완료",
        backgroundColor: .kidkPink,
        titleColor: .kidkTextWhite
    )

    private var isBuildingMissionOverlayVisible = false
    private var isMissionCompletedPopupVisible = false

    #if DEBUG
    enum DebugSnapshotAction {
        case none
        case showBuildingDetail
        case showMissionSelection
        case showMissionCreation
        case showMissionCompletedPopup
    }

    private var debugSnapshotAction: DebugSnapshotAction = .none
    private var didApplyDebugSnapshotAction = false
    #endif

    private weak var currentSheetViewController: UIViewController?
    private var cityScene: KidkCityScene?
    private var latestUnlockedLocations: Set<KIDKCityLocationType> = [.home, .school]

    init(viewModel: KIDKCityViewModel, user: User) {
        self.viewModel = viewModel
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    #if DEBUG
    func setDebugSnapshotAction(_ action: DebugSnapshotAction) {
        debugSnapshotAction = action
    }
    #endif

    var prefersNavigationBarHidden: Bool { true }
    var prefersTabBarHidden: Bool { true }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = .all
        self.extendedLayoutIncludesOpaqueBars = true
        setupUI()
        bind()
        configureSceneIfNeeded()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureSceneIfNeeded()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewDidAppearSubject.onNext(())
        #if DEBUG
        applyDebugSnapshotActionIfNeeded()
        #endif
    }

    private func setupUI() {
        view.backgroundColor = .kidkDarkBackground

        view.addSubview(gameView)
        view.addSubview(mapGuideBubbleView)
        view.addSubview(missionClockBadgeView)
        view.addSubview(martGuideBadgeView)
        view.addSubview(hudContainerView)
        view.addSubview(homeButton)
        view.addSubview(missionDetailDimButton)
        view.addSubview(buildingMissionCardView)
        view.addSubview(missionCompletedPopupView)

        mapGuideBubbleView.addSubview(mapGuideIconView)
        mapGuideBubbleView.addSubview(mapGuideTitleLabel)
        mapGuideBubbleView.addSubview(mapGuideDescriptionLabel)
        mapGuideBubbleView.addSubview(mapGuideArrowImageView)

        missionClockBadgeView.addSubview(missionClockIconView)
        missionClockBadgeView.addSubview(missionClockLabel)

        martGuideBadgeView.addSubview(martGuideIconView)
        martGuideBadgeView.addSubview(martGuideLabel)

        hudContainerView.addSubview(gaugeTitleLabel)
        hudContainerView.addSubview(gaugeValueLabel)
        hudContainerView.addSubview(levelLabel)
        hudContainerView.addSubview(gaugeProgressView)
        hudContainerView.addSubview(schoolMissionButton)

        buildingMissionCardView.addSubview(buildingMissionBackgroundImageView)
        buildingMissionCardView.addSubview(buildingMissionGrabberView)
        buildingMissionCardView.addSubview(buildingMissionTitleLabel)
        buildingMissionCardView.addSubview(buildingMissionRewardLabel)
        buildingMissionCardView.addSubview(buildingMissionCloseButton)
        buildingMissionCardView.addSubview(buildingMissionMainCardView)
        buildingMissionCardView.addSubview(buildingMissionItemView)
        buildingMissionCardView.addSubview(buildingMissionParticipantsStackView)
        buildingMissionCardView.addSubview(buildingMissionParticipantsLabel)
        buildingMissionCardView.addSubview(buildingMissionOtherButton)
        buildingMissionCardView.addSubview(buildingMissionStartButton)

        buildingMissionMainCardView.addSubview(buildingMissionTagStackView)
        buildingMissionMainCardView.addSubview(buildingMissionDescriptionLabel)
        buildingMissionTagStackView.addArrangedSubview(buildingMissionVideoTagLabel)
        buildingMissionTagStackView.addArrangedSubview(buildingMissionQuizTagLabel)

        buildingMissionItemView.addSubview(buildingMissionItemIconContainer)
        buildingMissionItemView.addSubview(buildingMissionItemTitleLabel)
        buildingMissionItemIconContainer.addSubview(buildingMissionItemIconView)

        missionCompletedPopupView.addSubview(missionCompletedTitleLabel)
        missionCompletedPopupView.addSubview(missionCompletedDescriptionLabel)
        missionCompletedPopupView.addSubview(missionCompletedGiftImageView)
        missionCompletedPopupView.addSubview(missionCompletedConfirmButton)

        gameView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        mapGuideBubbleView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Spacing.md)
            make.trailing.equalToSuperview().offset(-Spacing.md)
            make.width.lessThanOrEqualTo(220)
        }

        mapGuideIconView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(12)
            make.width.height.equalTo(20)
        }

        mapGuideTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(mapGuideIconView.snp.trailing).offset(8)
            make.top.equalToSuperview().offset(11)
            make.trailing.equalToSuperview().offset(-12)
        }

        mapGuideDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(mapGuideTitleLabel.snp.bottom).offset(4)
            make.leading.equalTo(mapGuideTitleLabel)
            make.trailing.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-12)
        }

        mapGuideArrowImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-8)
            make.bottom.equalToSuperview().offset(10)
            make.width.equalTo(26)
            make.height.equalTo(18)
        }

        missionClockBadgeView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Spacing.md)
            make.top.equalTo(homeButton.snp.bottom).offset(Spacing.sm)
            make.height.equalTo(32)
        }

        missionClockIconView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(14)
        }

        missionClockLabel.snp.makeConstraints { make in
            make.leading.equalTo(missionClockIconView.snp.trailing).offset(6)
            make.trailing.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
        }

        martGuideBadgeView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-Spacing.md)
            make.bottom.equalTo(hudContainerView.snp.top).offset(-Spacing.sm)
            make.height.equalTo(28)
        }

        martGuideIconView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(14)
        }

        martGuideLabel.snp.makeConstraints { make in
            make.leading.equalTo(martGuideIconView.snp.trailing).offset(5)
            make.trailing.equalToSuperview().offset(-8)
            make.centerY.equalToSuperview()
        }

        hudContainerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-Spacing.md)
        }

        gaugeTitleLabel.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
        }

        gaugeValueLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalTo(gaugeTitleLabel)
        }

        levelLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalTo(gaugeTitleLabel.snp.bottom).offset(4)
        }

        gaugeProgressView.snp.makeConstraints { make in
            make.top.equalTo(levelLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(8)
        }

        schoolMissionButton.snp.makeConstraints { make in
            make.top.equalTo(gaugeProgressView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
            make.bottom.equalToSuperview()
        }

        homeButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Spacing.md)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Spacing.md)
            make.width.height.equalTo(48)
        }

        missionDetailDimButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        buildingMissionCardView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(view.snp.height).multipliedBy(0.52)
        }

        buildingMissionBackgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        buildingMissionGrabberView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(58)
            make.height.equalTo(5)
        }

        buildingMissionTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.top.equalTo(buildingMissionGrabberView.snp.bottom).offset(16)
        }

        buildingMissionRewardLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-24)
            make.centerY.equalTo(buildingMissionTitleLabel)
            make.leading.greaterThanOrEqualTo(buildingMissionTitleLabel.snp.trailing).offset(8)
        }

        buildingMissionCloseButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(buildingMissionTitleLabel)
            make.width.height.equalTo(28)
        }

        buildingMissionMainCardView.snp.makeConstraints { make in
            make.top.equalTo(buildingMissionTitleLabel.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(176)
        }

        buildingMissionTagStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }

        buildingMissionDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(buildingMissionTagStackView.snp.bottom).offset(18)
            make.leading.trailing.equalToSuperview().inset(16)
            make.centerX.equalToSuperview()
        }

        buildingMissionItemView.snp.makeConstraints { make in
            make.top.equalTo(buildingMissionMainCardView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(58)
        }

        buildingMissionItemIconContainer.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }

        buildingMissionItemIconView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(18)
        }

        buildingMissionItemTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(buildingMissionItemIconContainer.snp.trailing).offset(10)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualToSuperview().offset(-12)
        }

        buildingMissionParticipantsStackView.snp.makeConstraints { make in
            make.top.equalTo(buildingMissionItemView.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(24)
            make.height.equalTo(24)
        }

        buildingMissionParticipantsLabel.snp.makeConstraints { make in
            make.leading.equalTo(buildingMissionParticipantsStackView.snp.trailing).offset(8)
            make.centerY.equalTo(buildingMissionParticipantsStackView)
            make.trailing.lessThanOrEqualToSuperview().offset(-24)
        }

        buildingMissionOtherButton.snp.makeConstraints { make in
            make.top.equalTo(buildingMissionParticipantsStackView.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(24)
            make.height.equalTo(56)
            make.width.equalTo(148)
        }

        buildingMissionStartButton.snp.makeConstraints { make in
            make.top.equalTo(buildingMissionOtherButton)
            make.leading.equalTo(buildingMissionOtherButton.snp.trailing).offset(12)
            make.trailing.equalToSuperview().offset(-24)
            make.height.equalTo(56)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-12)
        }

        missionCompletedPopupView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
            make.centerY.equalToSuperview().offset(34)
        }

        missionCompletedTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(28)
            make.leading.trailing.equalToSuperview().inset(Spacing.lg)
        }

        missionCompletedDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(missionCompletedTitleLabel.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(Spacing.lg)
        }

        missionCompletedGiftImageView.snp.makeConstraints { make in
            make.top.equalTo(missionCompletedDescriptionLabel.snp.bottom).offset(14)
            make.centerX.equalToSuperview()
            make.width.equalTo(280)
            make.height.equalTo(220)
        }

        missionCompletedConfirmButton.snp.makeConstraints { make in
            make.top.equalTo(missionCompletedGiftImageView.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(Spacing.lg)
            make.height.equalTo(56)
            make.bottom.equalToSuperview().offset(-Spacing.lg)
        }

        let homeTapGesture = UITapGestureRecognizer(target: self, action: #selector(homeButtonTapped))
        homeButton.addGestureRecognizer(homeTapGesture)

        schoolMissionButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.showMissionSelectionSheet()
            })
            .disposed(by: disposeBag)

        missionDetailDimButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.hideBuildingMissionDetailOverlay(animated: true)
                self?.hideMissionCompletedPopup(animated: true)
            })
            .disposed(by: disposeBag)

        buildingMissionCloseButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.hideBuildingMissionDetailOverlay(animated: true)
            })
            .disposed(by: disposeBag)

        buildingMissionOtherButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.hideBuildingMissionDetailOverlay(animated: false)
                self?.showMissionSelectionSheet()
            })
            .disposed(by: disposeBag)

        buildingMissionStartButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.hideBuildingMissionDetailOverlay(animated: false)
                self?.showMissionSelectionSheet()
            })
            .disposed(by: disposeBag)

        missionCompletedConfirmButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.missionCompletedSubject.onNext(UUID().uuidString)
                self.hideMissionCompletedPopup(animated: true)
            })
            .disposed(by: disposeBag)

        configureMapGuideAssets()
        configureBuildingMissionDetailAssets()
        configureMissionCompletedPopupAssets()
        setupBuildingMissionParticipants()
        updateMapGuideState()
    }

    private func bind() {
        let locationTapped = PublishSubject<KIDKCityLocationType>()

        let input = KIDKCityViewModel.Input(
            viewDidAppear: viewDidAppearSubject.asObservable(),
            locationTapped: locationTapped.asObservable(),
            missionCompleted: missionCompletedSubject.asObservable()
        )

        let output = viewModel.transform(input: input)

        output.gaugeProgress
            .drive(onNext: { [weak self] progress in
                self?.updateGauge(progress: progress)
            })
            .disposed(by: disposeBag)

        output.gaugeText
            .drive(gaugeValueLabel.rx.text)
            .disposed(by: disposeBag)

        output.levelText
            .drive(levelLabel.rx.text)
            .disposed(by: disposeBag)

        output.locations
            .drive(onNext: { [weak self] locations in
                guard let self = self else { return }
                self.latestUnlockedLocations = Set(locations.filter { $0.isUnlocked }.map { $0.type })
                self.cityScene?.setUnlockedLocations(self.latestUnlockedLocations)
                self.updateMapGuideState()
            })
            .disposed(by: disposeBag)
    }

    private func configureSceneIfNeeded() {
        guard cityScene == nil, gameView.bounds.size.width > 0 else { return }

        let scene = KidkCityScene(size: gameView.bounds.size)
        scene.scaleMode = .resizeFill
        scene.setUnlockedLocations(latestUnlockedLocations)
        scene.onSchoolTapped = { [weak self] in
            self?.showBuildingMissionDetailOverlay()
        }
        scene.onLockedLocationTapped = { [weak self] location in
            self?.showLockedLocationToast(location: location)
        }
        gameView.presentScene(scene)
        cityScene = scene
    }

    private func updateGauge(progress: Float) {
        let clamped = max(0, min(progress, 1))
        gaugeProgressView.setProgress(clamped, animated: true)
        gaugeValueLabel.text = "\(Int(clamped * 100))%"
    }

    #if DEBUG
    private func applyDebugSnapshotActionIfNeeded() {
        guard !didApplyDebugSnapshotAction else { return }
        didApplyDebugSnapshotAction = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { [weak self] in
            guard let self else { return }
            switch self.debugSnapshotAction {
            case .none:
                break
            case .showBuildingDetail:
                self.showBuildingMissionDetailOverlay()
            case .showMissionSelection:
                self.showMissionSelectionSheet()
            case .showMissionCreation:
                self.showMissionSelectionSheet()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    self.showMissionCreationSheet(missionType: .video)
                }
            case .showMissionCompletedPopup:
                self.showMissionCompletedPopup()
            }
        }
    }
    #endif

    @objc private func homeButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    private func configureMapGuideAssets() {
        applyMapOverlayImage(to: mapGuideIconView, assetName: "kidk_icon_pencil", fallbackSystemName: "pencil")
        applyMapOverlayImage(to: mapGuideArrowImageView, assetName: "kidk_game_bubble_arrow", fallbackSystemName: "arrowtriangle.down.fill")
        applyMapOverlayImage(to: missionClockIconView, assetName: "kidk_game_clock", fallbackSystemName: "clock.fill")
        applyMapOverlayImage(to: martGuideIconView, assetName: "kidk_game_mart_icon", fallbackSystemName: "storefront.fill")
    }

    private func configureBuildingMissionDetailAssets() {
        buildingMissionItemTitleLabel.text = "내가 몰랐던 저축의 즐거움을 알아보아요!"
        applyMapOverlayImage(to: buildingMissionItemIconView, assetName: "kidk_icon_pencil", fallbackSystemName: "lightbulb.fill")
        configureBuildingMissionCardBackground()
        configureBuildingMissionRewardBadge()
    }

    private func configureBuildingMissionCardBackground() {
        if let backgroundImage = UIImage(named: "kidk_building_mission_detail_bg") {
            buildingMissionBackgroundImageView.image = backgroundImage
            buildingMissionBackgroundImageView.isHidden = false
            buildingMissionCardView.backgroundColor = .clear
            return
        }

        buildingMissionBackgroundImageView.image = nil
        buildingMissionBackgroundImageView.isHidden = true
        buildingMissionCardView.backgroundColor = UIColor(hex: "#1A1B20")
    }

    private func configureBuildingMissionRewardBadge() {
        if let badgeImage = UIImage(named: "kidk_building_mission_reward_badge") {
            let attachment = NSTextAttachment()
            attachment.image = badgeImage
            attachment.bounds = CGRect(x: 0, y: -2, width: 18, height: 18)

            let text = NSMutableAttributedString(attachment: attachment)
            text.append(
                NSAttributedString(
                    string: " 2000원",
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 28, weight: .bold),
                        .foregroundColor: UIColor.kidkTextWhite
                    ]
                )
            )

            buildingMissionRewardLabel.attributedText = text
            buildingMissionRewardLabel.text = nil
            buildingMissionRewardLabel.backgroundColor = .clear
            return
        }

        buildingMissionRewardLabel.attributedText = nil
        buildingMissionRewardLabel.applyTextStyle(text: "2000원", size: .s36, weight: .bold, color: .kidkTextWhite)
        buildingMissionRewardLabel.backgroundColor = .clear
    }

    private func configureMissionCompletedPopupAssets() {
        if let image = UIImage(named: "kidk_mission_completed_gift") {
            missionCompletedGiftImageView.image = image
            return
        }

        missionCompletedGiftImageView.image = UIImage(systemName: "gift.fill")
        missionCompletedGiftImageView.tintColor = .kidkPink
    }

    private func updateMapGuideState() {
        let isMartUnlocked = latestUnlockedLocations.contains(.mart)
        martGuideLabel.text = isMartUnlocked ? "마트 오픈 완료" : "마트 Lv.2 오픈"
        martGuideBadgeView.backgroundColor = isMartUnlocked
            ? UIColor.kidkGreen.withAlphaComponent(0.2)
            : UIColor(hex: "#1F1F22").withAlphaComponent(0.9)
        martGuideLabel.textColor = isMartUnlocked ? .kidkGreen : .kidkTextWhite
    }

    private func setupBuildingMissionParticipants() {
        buildingMissionParticipantsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let avatarAssetNames = ["kidk_friend_avatar_1", "kidk_friend_avatar_2", "kidk_friend_avatar_3"]
        avatarAssetNames.forEach { assetName in
            let avatarView = UIImageView()
            avatarView.contentMode = .scaleAspectFill
            avatarView.layer.cornerRadius = 12
            avatarView.layer.masksToBounds = true
            avatarView.layer.borderWidth = 1
            avatarView.layer.borderColor = UIColor(hex: "#202028").cgColor
            avatarView.backgroundColor = UIColor(hex: "#25252C")
            avatarView.snp.makeConstraints { make in
                make.width.height.equalTo(24)
            }

            if let avatarImage = UIImage(named: assetName) ?? UIImage(named: "kidk_profile_one") {
                avatarView.image = avatarImage
                avatarView.contentMode = .scaleAspectFill
            } else {
                avatarView.image = UIImage(systemName: "person.fill")
                avatarView.tintColor = .kidkGray
                avatarView.contentMode = .center
            }

            buildingMissionParticipantsStackView.addArrangedSubview(avatarView)
        }
    }

    private func applyMapOverlayImage(to imageView: UIImageView, assetName: String, fallbackSystemName: String) {
        if let image = UIImage(named: assetName) {
            imageView.image = image
            imageView.tintColor = nil
            return
        }

        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        imageView.image = UIImage(systemName: fallbackSystemName, withConfiguration: symbolConfig)
        imageView.tintColor = UIColor.kidkPink.withAlphaComponent(0.92)
    }

    private func setCityChromeHidden(_ hidden: Bool, animated: Bool) {
        let chromeViews: [UIView] = [homeButton, mapGuideBubbleView, missionClockBadgeView, martGuideBadgeView, hudContainerView]

        if hidden {
            chromeViews.forEach {
                $0.isHidden = false
                $0.alpha = 1
            }
        }

        let animations = {
            chromeViews.forEach { $0.alpha = hidden ? 0 : 1 }
        }

        let completion: (Bool) -> Void = { _ in
            chromeViews.forEach { $0.isHidden = hidden }
        }

        if animated {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: animations, completion: completion)
        } else {
            animations()
            completion(true)
        }
    }

    private func showBuildingMissionDetailOverlay() {
        guard !isBuildingMissionOverlayVisible else { return }

        hideMissionCompletedPopup(animated: false)

        isBuildingMissionOverlayVisible = true
        missionDetailDimButton.isHidden = false
        buildingMissionCardView.isHidden = false
        buildingMissionCardView.transform = CGAffineTransform(translationX: 0, y: 36)
        setCityChromeHidden(true, animated: true)
        cityScene?.setSchoolFocus(true)

        UIView.animate(withDuration: 0.22, delay: 0, options: .curveEaseOut, animations: {
            self.missionDetailDimButton.alpha = 1
            self.buildingMissionCardView.alpha = 1
            self.buildingMissionCardView.transform = .identity
        })
    }

    private func hideBuildingMissionDetailOverlay(animated: Bool) {
        guard isBuildingMissionOverlayVisible else { return }

        isBuildingMissionOverlayVisible = false

        if !isMissionCompletedPopupVisible {
            setCityChromeHidden(false, animated: animated)
            cityScene?.setSchoolFocus(false)
        }

        let animations = {
            self.missionDetailDimButton.alpha = self.isMissionCompletedPopupVisible ? 1 : 0
            self.buildingMissionCardView.alpha = 0
            self.buildingMissionCardView.transform = CGAffineTransform(translationX: 0, y: 36)
        }

        let completion: (Bool) -> Void = { _ in
            if !self.isMissionCompletedPopupVisible {
                self.missionDetailDimButton.isHidden = true
            }
            self.buildingMissionCardView.isHidden = true
            self.buildingMissionCardView.transform = .identity
        }

        if animated {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: animations, completion: completion)
        } else {
            animations()
            completion(true)
        }
    }

    private func showMissionCompletedPopup() {
        guard !isMissionCompletedPopupVisible else { return }

        hideBuildingMissionDetailOverlay(animated: false)

        isMissionCompletedPopupVisible = true
        missionDetailDimButton.isHidden = false
        missionCompletedPopupView.isHidden = false
        missionCompletedPopupView.transform = CGAffineTransform(translationX: 0, y: 16)
        missionCompletedPopupView.alpha = 0

        setCityChromeHidden(true, animated: false)
        cityScene?.setSchoolFocus(false)

        UIView.animate(withDuration: 0.24, delay: 0, options: .curveEaseOut, animations: {
            self.missionDetailDimButton.alpha = 1
            self.missionCompletedPopupView.alpha = 1
            self.missionCompletedPopupView.transform = .identity
        })
    }

    private func hideMissionCompletedPopup(animated: Bool) {
        guard isMissionCompletedPopupVisible else { return }

        isMissionCompletedPopupVisible = false
        if !isBuildingMissionOverlayVisible {
            setCityChromeHidden(false, animated: animated)
        }

        let animations = {
            self.missionCompletedPopupView.alpha = 0
            self.missionCompletedPopupView.transform = CGAffineTransform(translationX: 0, y: 16)
            self.missionDetailDimButton.alpha = self.isBuildingMissionOverlayVisible ? 1 : 0
        }

        let completion: (Bool) -> Void = { _ in
            self.missionCompletedPopupView.isHidden = true
            self.missionCompletedPopupView.transform = .identity
            if !self.isBuildingMissionOverlayVisible {
                self.missionDetailDimButton.isHidden = true
            }
        }

        if animated {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: animations, completion: completion)
        } else {
            animations()
            completion(true)
        }
    }

    private func showMissionSelectionSheet() {
        hideBuildingMissionDetailOverlay(animated: false)
        hideMissionCompletedPopup(animated: false)

        guard currentSheetViewController == nil else {
            debugWarning("Sheet already presented")
            return
        }

        let sheetVC = MissionSelectionSheetViewController()

        if let sheet = sheetVC.sheetPresentationController {
            let customDetent = UISheetPresentationController.Detent.custom { context in
                return context.maximumDetentValue * 0.6
            }
            sheet.detents = [customDetent]
            sheet.prefersGrabberVisible = false
        }

        sheetVC.missionSelected
            .subscribe(onNext: { [weak self] missionType in
                self?.showMissionCreationSheet(missionType: missionType)
            })
            .disposed(by: disposeBag)

        sheetVC.customMissionTapped
            .subscribe(onNext: { [weak self] in
                self?.showMissionCreationSheet(missionType: .custom)
            })
            .disposed(by: disposeBag)

        sheetVC.previousMissionTapped
            .subscribe(onNext: { [weak self] in
                self?.dismissCurrentSheet()
            })
            .disposed(by: disposeBag)

        currentSheetViewController = sheetVC
        present(sheetVC, animated: true)
    }

    private func showMissionCreationSheet(missionType: MissionType) {
        guard let selectionSheet = currentSheetViewController else {
            debugWarning("No selection sheet found")
            return
        }

        guard selectionSheet.presentedViewController == nil else {
            debugWarning("Another view controller is already presented on selection sheet")
            return
        }

        let repository = MissionRepository(currentUserId: user.id)
        let creationViewModel = MissionCreationViewModel(missionRepository: repository, missionType: missionType)
        let creationVC = MissionCreationViewController(viewModel: creationViewModel)

        if let sheet = creationVC.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }

        creationVC.missionCreated
            .subscribe(onNext: { [weak self] (_: Mission) in
                let eventId = UUID().uuidString
                self?.missionCompletedSubject.onNext(eventId)
                creationVC.dismiss(animated: true)
            })
            .disposed(by: disposeBag)

        creationVC.previousTapped
            .subscribe(onNext: {
                creationVC.dismiss(animated: true)
            })
            .disposed(by: disposeBag)

        selectionSheet.present(creationVC, animated: true)
    }

    private func dismissCurrentSheet() {
        currentSheetViewController?.dismiss(animated: true) { [weak self] in
            self?.currentSheetViewController = nil
        }
    }

    private func showLockedLocationToast(location: KIDKCityLocationType) {
        let message: String
        switch location {
        case .mart:
            message = "마트는 레벨 2에서 열려요"
        case .home, .school:
            message = "아직 잠겨 있어요"
        }

        let alert = UILabel()
        alert.applyTextStyle(text: message, size: .s12, weight: .medium, color: .kidkTextWhite)
        alert.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        alert.textAlignment = .center
        alert.layer.cornerRadius = 12
        alert.clipsToBounds = true
        alert.alpha = 0

        view.addSubview(alert)
        alert.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(hudContainerView.snp.top).offset(-12)
            make.height.equalTo(32)
            make.width.greaterThanOrEqualTo(150)
        }

        UIView.animate(withDuration: 0.2, animations: {
            alert.alpha = 1
        }, completion: { _ in
            UIView.animate(withDuration: 0.2, delay: 1.0, options: .curveEaseInOut, animations: {
                alert.alpha = 0
            }, completion: { _ in
                alert.removeFromSuperview()
            })
        })
    }
}

private final class CityMissionChipLabel: UILabel {

    private let horizontalPadding: CGFloat = 16
    private let verticalPadding: CGFloat = 8

    override var intrinsicContentSize: CGSize {
        let base = super.intrinsicContentSize
        return CGSize(
            width: base.width + horizontalPadding * 2,
            height: base.height + verticalPadding * 2
        )
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.insetBy(dx: horizontalPadding, dy: verticalPadding))
    }

    func applyFilledStyle(text: String, fillColor: UIColor, textColor: UIColor) {
        applyTextStyle(text: text, size: .s12, weight: .bold, color: textColor)
        backgroundColor = fillColor
        layer.cornerRadius = 17
        clipsToBounds = true
        textAlignment = .center
    }
}

private final class KidkCityScene: SKScene {

    var onSchoolTapped: (() -> Void)?
    var onLockedLocationTapped: ((KIDKCityLocationType) -> Void)?

    private let backgroundNode: SKSpriteNode = {
        let node = SKSpriteNode(imageNamed: "kidk_city_map_background")
        node.zPosition = 0
        return node
    }()

    private let focusDimNode: SKSpriteNode = {
        let node = SKSpriteNode(color: UIColor.black, size: .zero)
        node.zPosition = 1
        node.alpha = 0
        return node
    }()

    private let schoolNode: SKSpriteNode = {
        let node = SKSpriteNode(imageNamed: "kidk_city_school")
        node.name = "school"
        node.zPosition = 2
        return node
    }()

    private let martNode: SKSpriteNode = {
        let node = SKSpriteNode(imageNamed: "kidk_city_mart")
        node.name = "mart"
        node.zPosition = 2
        return node
    }()

    private let martLockNode: SKLabelNode = {
        let node = SKLabelNode(text: "🔒")
        node.fontSize = 24
        node.zPosition = 4
        node.alpha = 0
        return node
    }()

    private let characterNode: SKSpriteNode = {
        let node = SKSpriteNode(imageNamed: "kidk_character_side_walk_1")
        node.zPosition = 3
        return node
    }()

    private var unlockedLocations: Set<KIDKCityLocationType> = [.home, .school]
    private var isSchoolFocused = false

    override func didMove(to view: SKView) {
        backgroundColor = .clear
        addChild(backgroundNode)
        addChild(focusDimNode)
        addChild(schoolNode)
        addChild(martNode)
        addChild(martLockNode)
        addChild(characterNode)
        layoutScene()
        applyUnlockState()
        startIdleAnimation()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        layoutScene()
        applyUnlockState()
    }

    private func layoutScene() {
        guard size.width > 0, size.height > 0 else { return }

        backgroundNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        backgroundNode.size = aspectFillSize(for: backgroundNode, in: size)

        focusDimNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        focusDimNode.size = size

        let schoolPosition = isSchoolFocused
            ? CGPoint(x: size.width * 0.5, y: size.height * 0.665)
            : CGPoint(x: size.width * 0.49, y: size.height * 0.675)
        let schoolMaxSize = isSchoolFocused
            ? CGSize(width: size.width * 0.78, height: size.height * 0.38)
            : CGSize(width: size.width * 0.63, height: size.height * 0.315)

        schoolNode.position = schoolPosition
        schoolNode.size = aspectFitSize(for: schoolNode, in: schoolMaxSize)

        martNode.position = CGPoint(x: size.width * 0.74, y: size.height * 0.28)
        martNode.size = aspectFitSize(for: martNode, in: CGSize(width: size.width * 0.34, height: size.height * 0.22))
        martLockNode.position = CGPoint(x: martNode.position.x, y: martNode.position.y + martNode.size.height * 0.3)

        characterNode.position = CGPoint(x: size.width * 0.77, y: size.height * 0.685)
        characterNode.size = aspectFitSize(for: characterNode, in: CGSize(width: 136, height: 136))
    }

    private func aspectFitSize(for node: SKSpriteNode, in maxSize: CGSize) -> CGSize {
        guard maxSize.width > 0, maxSize.height > 0,
              let texture = node.texture else { return maxSize }

        let textureSize = texture.size()
        guard textureSize.width > 0, textureSize.height > 0 else { return maxSize }

        let scale = min(maxSize.width / textureSize.width, maxSize.height / textureSize.height)
        return CGSize(width: textureSize.width * scale, height: textureSize.height * scale)
    }

    private func aspectFillSize(for node: SKSpriteNode, in targetSize: CGSize) -> CGSize {
        guard targetSize.width > 0, targetSize.height > 0,
              let texture = node.texture else { return targetSize }

        let textureSize = texture.size()
        guard textureSize.width > 0, textureSize.height > 0 else { return targetSize }

        let scale = max(targetSize.width / textureSize.width, targetSize.height / textureSize.height)
        return CGSize(width: textureSize.width * scale, height: textureSize.height * scale)
    }

    func setUnlockedLocations(_ locations: Set<KIDKCityLocationType>) {
        unlockedLocations = locations
        applyUnlockState()
    }

    func setSchoolFocus(_ focused: Bool) {
        guard isSchoolFocused != focused else { return }
        isSchoolFocused = focused
        layoutScene()
        applyUnlockState()
    }

    private func applyUnlockState() {
        let martUnlocked = unlockedLocations.contains(.mart)
        let martBaseAlpha: CGFloat = martUnlocked ? 1.0 : 0.6

        if isSchoolFocused {
            focusDimNode.alpha = 0.38
            martNode.alpha = martBaseAlpha * 0.35
            martLockNode.alpha = martUnlocked ? 0.0 : 0.4
            characterNode.alpha = 0
        } else {
            focusDimNode.alpha = 0
            martNode.alpha = martBaseAlpha
            martLockNode.alpha = martUnlocked ? 0.0 : 1.0
            characterNode.alpha = 1
        }
    }

    private func startIdleAnimation() {
        let frame1 = SKTexture(imageNamed: "kidk_character_side_walk_1")
        let frame2 = SKTexture(imageNamed: "kidk_character_side_walk_2")
        let animate = SKAction.animate(with: [frame1, frame2], timePerFrame: 0.2)
        let forever = SKAction.repeatForever(animate)
        characterNode.run(forever, withKey: "walk")
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let node = atPoint(location)

        if node.name == "school" || node.parent?.name == "school" {
            onSchoolTapped?()
            return
        }

        if node.name == "mart" || node.parent?.name == "mart" {
            if unlockedLocations.contains(.mart) {
                // TODO: 마트 컨텐츠 연결(서버 API 문서 기준)
            } else {
                onLockedLocationTapped?(.mart)
            }
        }
    }
}
