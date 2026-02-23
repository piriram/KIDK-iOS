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
    }

    private func setupUI() {
        view.backgroundColor = .kidkDarkBackground

        view.addSubview(gameView)
        view.addSubview(hudContainerView)
        view.addSubview(homeButton)

        hudContainerView.addSubview(gaugeTitleLabel)
        hudContainerView.addSubview(gaugeValueLabel)
        hudContainerView.addSubview(levelLabel)
        hudContainerView.addSubview(gaugeProgressView)
        hudContainerView.addSubview(schoolMissionButton)

        gameView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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

        let homeTapGesture = UITapGestureRecognizer(target: self, action: #selector(homeButtonTapped))
        homeButton.addGestureRecognizer(homeTapGesture)

        schoolMissionButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.showMissionSelectionSheet()
            })
            .disposed(by: disposeBag)
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
            })
            .disposed(by: disposeBag)
    }

    private func configureSceneIfNeeded() {
        guard cityScene == nil, gameView.bounds.size.width > 0 else { return }

        let scene = KidkCityScene(size: gameView.bounds.size)
        scene.scaleMode = .resizeFill
        scene.setUnlockedLocations(latestUnlockedLocations)
        scene.onSchoolTapped = { [weak self] in
            self?.showMissionSelectionSheet()
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

private final class KidkCityScene: SKScene {

    var onSchoolTapped: (() -> Void)?
    var onLockedLocationTapped: ((KIDKCityLocationType) -> Void)?

    private let backgroundNode: SKSpriteNode = {
        let node = SKSpriteNode(imageNamed: "kidk_city_map_background")
        node.zPosition = 0
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

    override func didMove(to view: SKView) {
        backgroundColor = .clear
        addChild(backgroundNode)
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

        schoolNode.position = CGPoint(x: size.width * 0.5, y: size.height * 0.62)
        schoolNode.size = aspectFitSize(for: schoolNode, in: CGSize(width: size.width * 0.5, height: size.height * 0.25))

        martNode.position = CGPoint(x: size.width * 0.8, y: size.height * 0.33)
        martNode.size = aspectFitSize(for: martNode, in: CGSize(width: size.width * 0.24, height: size.height * 0.16))
        martLockNode.position = CGPoint(x: martNode.position.x, y: martNode.position.y + martNode.size.height * 0.28)

        characterNode.position = CGPoint(x: size.width * 0.2, y: size.height * 0.38)
        characterNode.size = aspectFitSize(for: characterNode, in: CGSize(width: 72, height: 72))
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

    private func applyUnlockState() {
        let martUnlocked = unlockedLocations.contains(.mart)
        martNode.alpha = martUnlocked ? 1.0 : 0.6
        martLockNode.alpha = martUnlocked ? 0.0 : 1.0
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
