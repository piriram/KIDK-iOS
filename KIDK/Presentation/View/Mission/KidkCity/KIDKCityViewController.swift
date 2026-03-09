import UIKit
import SpriteKit
import RxSwift
import RxCocoa
import SnapKit

final class KIDKCityViewController: BaseViewController, NavigationChromeConfigurable {

    private let viewModel: KIDKCityViewModel
    private let user: User
    private let viewDidAppearSubject = PublishSubject<Void>()
    private let missionCompletedSubject = PublishSubject<MissionRewardCompletedEvent>()

    private let gameView: SKView = {
        let view = SKView()
        view.ignoresSiblingOrder = true
        view.showsFPS = false
        view.showsNodeCount = false
        view.backgroundColor = .clear
        return view
    }()

    private let hudContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#2A2A35")
        view.layer.cornerRadius = 20
        return view
    }()

    private let ddayBadgeLabel: UILabel = {
        let label = UILabel()
        label.text = "D - 30"
        label.applyTextStyle(text: "D - 30", size: .s20, weight: .bold, color: .kidkTextPrimary)
        label.backgroundColor = .kidkPinkLight
        label.textAlignment = .center
        label.layer.cornerRadius = 26 / 2
        label.clipsToBounds = true
        return label
    }()

    private let missionTitleLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(text: "여름방학 놀이공원 가기", size: .s20, weight: .bold, color: .kidkTextWhite)
        label.numberOfLines = 1
        return label
    }()

    private let currentAmountLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(text: "0원", size: .s22, weight: .bold, color: .kidkTextWhite)
        return label
    }()

    private let targetAmountLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(text: "/ 50,000원", size: .s22, weight: .bold, color: .kidkGray)
        return label
    }()

    private let progressTrackView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.88)
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        return view
    }()

    private let progressMintView: UIView = {
        let view = UIView()
        view.backgroundColor = .kidkGreen
        return view
    }()

    private let progressPinkDeltaView: UIView = {
        let view = UIView()
        view.backgroundColor = .kidkPink
        return view
    }()

    private let amountStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .firstBaseline
        stack.spacing = 8
        return stack
    }()

    private var progressMintWidthConstraint: Constraint?
    private var progressPinkLeadingConstraint: Constraint?
    private var progressPinkWidthConstraint: Constraint?
    private var previousGaugeProgress: CGFloat = 0
    private let savingsTargetAmount: Int = 50_000

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

    private weak var currentSheetViewController: UIViewController?
    private var cityScene: KidkCityScene?
    private var latestUnlockedLocations: Set<KIDKCityLocationType> = [.home, .school]
    private var homeTapGestureRecognizer: UITapGestureRecognizer?

    #if DEBUG
    enum DebugSnapshotAction {
        case none
        case showMissionCompletedPopup
        case showBuildingDetail
        case showMissionSelection
        case showMissionCreation
    }

    private var debugSnapshotAction: DebugSnapshotAction = .none
    #endif

    #if DEBUG
    private var debugPanelVisible = false
    private var debugBgScale: CGFloat = 1.0
    private var debugBgOffsetX: CGFloat = 0
    private var debugBgOffsetY: CGFloat = 0
    private var debugHomeX: CGFloat = 0.0060
    private var debugHomeY: CGFloat = 0.4447
    private var debugHomeScale: CGFloat = 1.173
    private var debugSchoolX: CGFloat = 0.3964
    private var debugSchoolY: CGFloat = 0.7712
    private var debugSchoolScale: CGFloat = 1.269
    private var debugMartX: CGFloat = 0.7781
    private var debugMartY: CGFloat = 0.2945
    private var debugMartScale: CGFloat = 1.456

    private let debugPanel = UIStackView()
    private let debugSummaryLabel = UILabel()
    #endif

    init(viewModel: KIDKCityViewModel, user: User) {
        self.viewModel = viewModel
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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
        runDebugSnapshotActionIfNeeded()
        #endif
    }

    private func setupUI() {
        view.backgroundColor = .kidkDarkBackground

        view.addSubview(gameView)
        view.addSubview(hudContainerView)
        view.addSubview(homeButton)

        hudContainerView.addSubview(ddayBadgeLabel)
        hudContainerView.addSubview(missionTitleLabel)
        hudContainerView.addSubview(amountStackView)
        hudContainerView.addSubview(progressTrackView)

        amountStackView.addArrangedSubview(currentAmountLabel)
        amountStackView.addArrangedSubview(targetAmountLabel)

        progressTrackView.addSubview(progressMintView)
        progressTrackView.addSubview(progressPinkDeltaView)

        gameView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        hudContainerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-12)
            make.height.equalTo(125)
        }

        ddayBadgeLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(12)
            make.width.equalTo(74)
            make.height.equalTo(30)
        }

        missionTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(ddayBadgeLabel.snp.trailing).offset(12)
            make.centerY.equalTo(ddayBadgeLabel)
            make.trailing.lessThanOrEqualToSuperview().inset(16)
        }

        amountStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(ddayBadgeLabel.snp.bottom).offset(8)
            make.trailing.lessThanOrEqualToSuperview().inset(16)
        }

        progressTrackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(12)
            make.height.equalTo(24)
        }

        progressMintView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            self.progressMintWidthConstraint = make.width.equalTo(0).constraint
        }

        progressPinkDeltaView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            self.progressPinkLeadingConstraint = make.leading.equalTo(progressMintView.snp.trailing).constraint
            self.progressPinkWidthConstraint = make.width.equalTo(0).constraint
        }

        homeButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Spacing.md)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Spacing.md)
            make.width.height.equalTo(48)
        }

        let homeTapGesture = UITapGestureRecognizer(target: self, action: #selector(homeButtonTapped))
        homeTapGestureRecognizer = homeTapGesture
        homeButton.addGestureRecognizer(homeTapGesture)


        #if DEBUG
        setupDebugUI()
        #endif
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
            .drive(onNext: { [weak self] text in
                self?.applyGaugeAccentByGaugeText(text)
            })
            .disposed(by: disposeBag)

        output.levelText
            .drive(onNext: { _ in })
            .disposed(by: disposeBag)

        output.locations
            .drive(onNext: { [weak self] locations in
                guard let self = self else { return }
                self.latestUnlockedLocations = Set(locations.filter { $0.isUnlocked }.map { $0.type })
                self.cityScene?.setUnlockedLocations(self.latestUnlockedLocations)
            })
            .disposed(by: disposeBag)
    }

    private func configureSceneIfNeeded() {
        guard cityScene == nil, gameView.bounds.size.width > 0 else { return }

        let scene = KidkCityScene(size: gameView.bounds.size)
        scene.scaleMode = .resizeFill
        scene.setUnlockedLocations(latestUnlockedLocations)
        scene.onHomeTapped = { [weak self] in
            self?.homeButtonTapped()
        }
        scene.onSchoolTapped = { [weak self] in
            self?.showMissionSelectionSheet()
        }
        scene.onLockedLocationTapped = { [weak self] location in
            self?.showLockedLocationToast(location: location)
        }
        gameView.presentScene(scene)
        cityScene = scene

        #if DEBUG
        applyDebugLayoutToScene()
        #endif
    }

    private func updateGauge(progress: Float) {
        let clamped = CGFloat(max(0, min(progress, 1)))
        let amount = Int((clamped * CGFloat(savingsTargetAmount)).rounded())

        currentAmountLabel.applyTextStyle(
            text: "\(amount.formattedWithComma)원",
            size: .s22,
            weight: .bold,
            color: .kidkTextWhite
        )
        targetAmountLabel.applyTextStyle(
            text: "/ \(savingsTargetAmount.formattedWithComma)원",
            size: .s22,
            weight: .bold,
            color: .kidkGray
        )

        view.layoutIfNeeded()
        let effectivePrevious = previousGaugeProgress == 0 ? clamped : previousGaugeProgress
        let delta = max(0, clamped - effectivePrevious)
        let trackWidth = max(progressTrackView.bounds.width, 1)
        progressMintWidthConstraint?.update(offset: trackWidth * effectivePrevious)
        progressPinkLeadingConstraint?.update(offset: 0)
        progressPinkWidthConstraint?.update(offset: trackWidth * delta)

        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut]) {
            self.progressTrackView.layoutIfNeeded()
        }

        if delta > 0 {
            currentAmountLabel.applyTextStyle(
                text: "\(amount.formattedWithComma)원",
                size: .s22,
                weight: .bold,
                color: .kidkPink
            )
        }

        previousGaugeProgress = clamped
    }

    private func applyGaugeAccentByGaugeText(_ gaugeText: String) {
        guard let percent = Int(gaugeText.replacingOccurrences(of: "%", with: "")) else { return }
        if percent == 0 {
            currentAmountLabel.applyTextStyle(
                text: currentAmountLabel.text ?? "0원",
                size: .s22,
                weight: .bold,
                color: .kidkTextWhite
            )
        }
    }

    @objc private func homeButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    private func showMissionSelectionSheet() {
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
            .subscribe(onNext: { [weak self] (mission: Mission) in
                guard let self else { return }
                let event = MissionRewardCompletedEvent(
                    missionId: mission.id,
                    rewardAmount: mission.rewardAmount,
                    rewardType: .missionApproved,
                    childId: self.user.id,
                    timestamp: Date(),
                    idempotencyKey: UUID().uuidString
                )
                self.missionCompletedSubject.onNext(event)
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

    #if DEBUG
    func setDebugSnapshotAction(_ action: DebugSnapshotAction) {
        debugSnapshotAction = action
    }

    private func runDebugSnapshotActionIfNeeded() {
        switch debugSnapshotAction {
        case .none:
            break
        case .showMissionCompletedPopup:
            missionCompletedSubject.onNext(
                MissionRewardCompletedEvent(
                    missionId: "debug-mission-completed",
                    rewardAmount: 1000,
                    rewardType: .missionApproved,
                    childId: user.id,
                    timestamp: Date(),
                    idempotencyKey: UUID().uuidString
                )
            )
        case .showBuildingDetail:
            showLockedLocationToast(location: .mart)
        case .showMissionSelection:
            showMissionSelectionSheet()
        case .showMissionCreation:
            showMissionSelectionSheet()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.showMissionCreationSheet(missionType: .custom)
            }
        }
        debugSnapshotAction = .none
    }

    private func setupDebugUI() {
        let toggleGesture = UITapGestureRecognizer(target: self, action: #selector(toggleDebugPanel))
        toggleGesture.numberOfTapsRequired = 2
        if let homeTapGestureRecognizer {
            homeTapGestureRecognizer.require(toFail: toggleGesture)
        }
        homeButton.addGestureRecognizer(toggleGesture)

        debugPanel.axis = .vertical
        debugPanel.spacing = 6
        debugPanel.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        debugPanel.layer.cornerRadius = 10
        debugPanel.isLayoutMarginsRelativeArrangement = true
        debugPanel.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        debugPanel.isHidden = true

        debugSummaryLabel.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        debugSummaryLabel.textColor = .white
        debugSummaryLabel.numberOfLines = 0

        debugPanel.addArrangedSubview(makeSliderRow(title: "homeX", min: 0.0, max: 1.0, value: Float(debugHomeX)) { [weak self] value in
            self?.debugHomeX = CGFloat(value)
            self?.applyDebugLayoutToScene()
        })
        debugPanel.addArrangedSubview(makeSliderRow(title: "homeY", min: 0.0, max: 1.0, value: Float(debugHomeY)) { [weak self] value in
            self?.debugHomeY = CGFloat(value)
            self?.applyDebugLayoutToScene()
        })
        debugPanel.addArrangedSubview(makeSliderRow(title: "homeScale", min: 0.5, max: 2.6, value: Float(debugHomeScale)) { [weak self] value in
            self?.debugHomeScale = CGFloat(value)
            self?.applyDebugLayoutToScene()
        })

        debugPanel.addArrangedSubview(makeSliderRow(title: "schoolX", min: 0.0, max: 1.0, value: Float(debugSchoolX)) { [weak self] value in
            self?.debugSchoolX = CGFloat(value)
            self?.applyDebugLayoutToScene()
        })
        debugPanel.addArrangedSubview(makeSliderRow(title: "schoolY", min: 0.0, max: 1.0, value: Float(debugSchoolY)) { [weak self] value in
            self?.debugSchoolY = CGFloat(value)
            self?.applyDebugLayoutToScene()
        })
        debugPanel.addArrangedSubview(makeSliderRow(title: "schoolScale", min: 0.5, max: 1.8, value: Float(debugSchoolScale)) { [weak self] value in
            self?.debugSchoolScale = CGFloat(value)
            self?.applyDebugLayoutToScene()
        })
        debugPanel.addArrangedSubview(makeSliderRow(title: "martX", min: 0.0, max: 1.0, value: Float(debugMartX)) { [weak self] value in
            self?.debugMartX = CGFloat(value)
            self?.applyDebugLayoutToScene()
        })
        debugPanel.addArrangedSubview(makeSliderRow(title: "martY", min: 0.0, max: 1.0, value: Float(debugMartY)) { [weak self] value in
            self?.debugMartY = CGFloat(value)
            self?.applyDebugLayoutToScene()
        })
        debugPanel.addArrangedSubview(makeSliderRow(title: "martScale", min: 0.5, max: 2.6, value: Float(debugMartScale)) { [weak self] value in
            self?.debugMartScale = CGFloat(value)
            self?.applyDebugLayoutToScene()
        })

        debugPanel.addArrangedSubview(debugSummaryLabel)

        let buttonsRow = UIStackView()
        buttonsRow.axis = .horizontal
        buttonsRow.spacing = 8
        buttonsRow.distribution = .fillEqually

        let resetBtn = makeDebugButton(title: "RESET")
        let copyBtn = makeDebugButton(title: "COPY")
        resetBtn.addTarget(self, action: #selector(resetDebugLayout), for: .touchUpInside)
        copyBtn.addTarget(self, action: #selector(copyDebugJSON), for: .touchUpInside)
        buttonsRow.addArrangedSubview(resetBtn)
        buttonsRow.addArrangedSubview(copyBtn)
        debugPanel.addArrangedSubview(buttonsRow)

        view.addSubview(debugPanel)
        debugPanel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.trailing.equalToSuperview().inset(8)
            make.width.equalTo(240)
        }

        refreshDebugSummary()
    }

    private func makeSliderRow(title: String, min: Float, max: Float, value: Float, onChange: @escaping (Float) -> Void) -> UIView {
        let row = UIStackView()
        row.axis = .vertical
        row.spacing = 2

        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .medium)
        label.textColor = .white
        label.text = title

        let slider = UISlider()
        slider.minimumValue = min
        slider.maximumValue = max
        slider.value = value
        slider.addAction(UIAction { _ in
            onChange(slider.value)
        }, for: .valueChanged)

        row.addArrangedSubview(label)
        row.addArrangedSubview(slider)
        return row
    }

    private func makeDebugButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        button.layer.cornerRadius = 6
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
        button.snp.makeConstraints { make in
            make.height.equalTo(30)
        }
        return button
    }

    @objc private func toggleDebugPanel() {
        debugPanelVisible.toggle()
        debugPanel.isHidden = !debugPanelVisible
    }

    @objc private func resetDebugLayout() {
        debugBgScale = 1.0
        debugBgOffsetX = 0
        debugBgOffsetY = 0
        debugHomeX = 0.0060
        debugHomeY = 0.4447
        debugHomeScale = 1.173
        debugSchoolX = 0.3964
        debugSchoolY = 0.7712
        debugSchoolScale = 1.269
        debugMartX = 0.7781
        debugMartY = 0.2945
        debugMartScale = 1.456
        applyDebugLayoutToScene()
    }

    private func applyDebugLayoutToScene() {
        cityScene?.updateLayoutForDebug(
            backgroundScale: debugBgScale,
            backgroundOffsetX: debugBgOffsetX,
            backgroundOffsetY: debugBgOffsetY,
            homeX: debugHomeX,
            homeY: debugHomeY,
            homeScale: debugHomeScale,
            schoolX: debugSchoolX,
            schoolY: debugSchoolY,
            schoolScale: debugSchoolScale,
            martX: debugMartX,
            martY: debugMartY,
            martScale: debugMartScale
        )
        refreshDebugSummary()
    }

    private func refreshDebugSummary() {
        debugSummaryLabel.text = "home: (\(String(format: "%.3f", debugHomeX)), \(String(format: "%.3f", debugHomeY))), s=\(String(format: "%.2f", debugHomeScale))\nschool: (\(String(format: "%.3f", debugSchoolX)), \(String(format: "%.3f", debugSchoolY))), s=\(String(format: "%.2f", debugSchoolScale))\nmart: (\(String(format: "%.3f", debugMartX)), \(String(format: "%.3f", debugMartY))), s=\(String(format: "%.2f", debugMartScale))"
    }

    @objc private func copyDebugJSON() {
        let json = """
        {
          "map": {
            "bgScale": \(String(format: "%.3f", debugBgScale)),
            "bgOffsetX": \(String(format: "%.1f", debugBgOffsetX)),
            "bgOffsetY": \(String(format: "%.1f", debugBgOffsetY))
          },
          "buildings": {
            "home": { "xRatio": \(String(format: "%.4f", debugHomeX)), "yRatio": \(String(format: "%.4f", debugHomeY)), "scale": \(String(format: "%.3f", debugHomeScale)) },
            "school": { "xRatio": \(String(format: "%.4f", debugSchoolX)), "yRatio": \(String(format: "%.4f", debugSchoolY)), "scale": \(String(format: "%.3f", debugSchoolScale)) },
            "mart": { "xRatio": \(String(format: "%.4f", debugMartX)), "yRatio": \(String(format: "%.4f", debugMartY)), "scale": \(String(format: "%.3f", debugMartScale)) }
          }
        }
        """
        UIPasteboard.general.string = json
        refreshDebugSummary()
    }
    #endif
}


private final class KidkCityScene: SKScene {

    struct BuildingLayout {
        var xRatio: CGFloat
        var yRatio: CGFloat
        var scale: CGFloat

        init(xRatio: CGFloat, yRatio: CGFloat, scale: CGFloat) {
            self.xRatio = xRatio
            self.yRatio = yRatio
            self.scale = scale
        }

        init(config: KIDKCityLayoutConfig.BuildingConfig) {
            self.xRatio = CGFloat(config.xRatio)
            self.yRatio = CGFloat(config.yRatio)
            self.scale = CGFloat(config.scale)
        }
    }

    var onHomeTapped: (() -> Void)?
    var onSchoolTapped: (() -> Void)?
    var onLockedLocationTapped: ((KIDKCityLocationType) -> Void)?

    private let backgroundNode: SKSpriteNode = {
        let node = SKSpriteNode(imageNamed: "kidk_city_map_background")
        node.zPosition = 0
        return node
    }()

    private let homeNode: SKSpriteNode = {
        let node = SKSpriteNode(imageNamed: "kidk_city_home")
        node.name = "home"
        node.zPosition = 2
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

    private let characterNode: SKSpriteNode = {
        let node = SKSpriteNode(imageNamed: "kidk_character_side_walk_1")
        node.zPosition = 3
        return node
    }()

    private var unlockedLocations: Set<KIDKCityLocationType> = [.home, .school]

    // NOTE: 좌표는 "scene size"가 아니라 "배경 표시 영역(frame)" 기준 ratio로 관리한다.
    private let layoutConfig = KIDKCityLayoutConfig.loadFromBundle()

    private lazy var backgroundScale: CGFloat = CGFloat(layoutConfig.map.bgScale)
    private lazy var backgroundOffset: CGPoint = CGPoint(
        x: CGFloat(layoutConfig.map.bgOffsetX),
        y: CGFloat(layoutConfig.map.bgOffsetY)
    )
    private lazy var homeLayout = BuildingLayout(config: layoutConfig.buildings.home)
    private lazy var schoolLayout = BuildingLayout(config: layoutConfig.buildings.school)
    private lazy var martLayout = BuildingLayout(config: layoutConfig.buildings.mart)
    private lazy var characterLayout = BuildingLayout(
        config: layoutConfig.buildings.character ?? KIDKCityLayoutConfig.fallback.buildings.character!
    )

    private var mapDisplayRect: CGRect = .zero
    private let movementSpeed: CGFloat = 220

    override func didMove(to view: SKView) {
        backgroundColor = .clear
        addChild(backgroundNode)
        addChild(homeNode)
        addChild(schoolNode)
        addChild(martNode)
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

        let sceneCenter = CGPoint(x: size.width / 2, y: size.height / 2)
        backgroundNode.position = CGPoint(
            x: sceneCenter.x + backgroundOffset.x,
            y: sceneCenter.y + backgroundOffset.y
        )

        let fillSize = aspectFillSize(for: backgroundNode, in: size)
        backgroundNode.size = CGSize(width: fillSize.width * backgroundScale, height: fillSize.height * backgroundScale)

        let displayRect = backgroundNode.frame
        mapDisplayRect = displayRect

        homeNode.position = point(in: displayRect, layout: homeLayout)
        homeNode.size = aspectFitSize(
            for: homeNode,
            in: CGSize(width: size.width * 0.28 * homeLayout.scale, height: size.height * 0.20 * homeLayout.scale)
        )

        schoolNode.position = point(in: displayRect, layout: schoolLayout)
        schoolNode.size = aspectFitSize(
            for: schoolNode,
            in: CGSize(width: size.width * 0.5 * schoolLayout.scale, height: size.height * 0.25 * schoolLayout.scale)
        )

        martNode.position = point(in: displayRect, layout: martLayout)
        martNode.size = aspectFitSize(
            for: martNode,
            in: CGSize(width: size.width * 0.30 * martLayout.scale, height: size.height * 0.20 * martLayout.scale)
        )

        let previousCharacterPosition = characterNode.position
        characterNode.size = aspectFitSize(
            for: characterNode,
            in: CGSize(width: 72 * characterLayout.scale, height: 72 * characterLayout.scale)
        )

        if previousCharacterPosition == .zero {
            characterNode.position = point(in: displayRect, layout: characterLayout)
        } else {
            characterNode.position = clampToMap(previousCharacterPosition)
        }
    }

    private func point(in rect: CGRect, layout: BuildingLayout) -> CGPoint {
        CGPoint(
            x: rect.minX + rect.width * layout.xRatio,
            y: rect.minY + rect.height * layout.yRatio
        )
    }

    #if DEBUG
    func updateLayoutForDebug(
        backgroundScale: CGFloat,
        backgroundOffsetX: CGFloat,
        backgroundOffsetY: CGFloat,
        homeX: CGFloat,
        homeY: CGFloat,
        homeScale: CGFloat,
        schoolX: CGFloat,
        schoolY: CGFloat,
        schoolScale: CGFloat,
        martX: CGFloat,
        martY: CGFloat,
        martScale: CGFloat
    ) {
        self.backgroundScale = backgroundScale
        self.backgroundOffset = CGPoint(x: backgroundOffsetX, y: backgroundOffsetY)
        self.homeLayout.xRatio = homeX
        self.homeLayout.yRatio = homeY
        self.homeLayout.scale = homeScale
        self.schoolLayout.xRatio = schoolX
        self.schoolLayout.yRatio = schoolY
        self.schoolLayout.scale = schoolScale
        self.martLayout.xRatio = martX
        self.martLayout.yRatio = martY
        self.martLayout.scale = martScale
        layoutScene()
    }
    #endif

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

    private func applyUnlockState() {
        martNode.alpha = 1.0
    }

    private func startIdleAnimation() {
        let frame1 = SKTexture(imageNamed: "kidk_character_side_walk_1")
        let frame2 = SKTexture(imageNamed: "kidk_character_side_walk_2")
        let animate = SKAction.animate(with: [frame1, frame2], timePerFrame: 0.2)
        let forever = SKAction.repeatForever(animate)
        characterNode.run(forever, withKey: "walk")
    }

    private func clampToMap(_ point: CGPoint) -> CGPoint {
        guard mapDisplayRect != .zero else { return point }

        let insetX = characterNode.size.width * 0.35
        let insetY = characterNode.size.height * 0.25
        let safeRect = mapDisplayRect.insetBy(dx: insetX, dy: insetY)

        return CGPoint(
            x: min(max(point.x, safeRect.minX), safeRect.maxX),
            y: min(max(point.y, safeRect.minY), safeRect.maxY)
        )
    }

    private func moveCharacter(to target: CGPoint, completion: (() -> Void)? = nil) {
        let destination = clampToMap(target)
        let current = characterNode.position
        let dx = destination.x - current.x
        let dy = destination.y - current.y
        let distance = hypot(dx, dy)

        if distance < 1 {
            completion?()
            return
        }

        characterNode.xScale = dx < 0 ? -abs(characterNode.xScale) : abs(characterNode.xScale)
        characterNode.removeAction(forKey: "move")

        let duration = max(0.15, TimeInterval(distance / movementSpeed))
        let move = SKAction.move(to: destination, duration: duration)
        move.timingMode = .easeInEaseOut

        let sequence = SKAction.sequence([move, .run { completion?() }])
        characterNode.run(sequence, withKey: "move")
    }

    private func interactionPoint(for buildingNode: SKSpriteNode) -> CGPoint {
        CGPoint(x: buildingNode.position.x, y: buildingNode.position.y - (buildingNode.size.height * 0.25))
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let node = atPoint(location)

        if node.name == "home" || node.parent?.name == "home" {
            moveCharacter(to: interactionPoint(for: homeNode)) { [weak self] in
                self?.onHomeTapped?()
            }
            return
        }

        if node.name == "school" || node.parent?.name == "school" {
            moveCharacter(to: interactionPoint(for: schoolNode)) { [weak self] in
                self?.onSchoolTapped?()
            }
            return
        }

        if node.name == "mart" || node.parent?.name == "mart" {
            moveCharacter(to: interactionPoint(for: martNode)) { [weak self] in
                guard let self else { return }
                if self.unlockedLocations.contains(.mart) {
                    // TODO: 마트 컨텐츠 연결(서버 API 문서 기준)
                } else {
                    self.onLockedLocationTapped?(.mart)
                }
            }
            return
        }

        moveCharacter(to: location)
    }
}
