import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class KIDKCityViewController: BaseViewController {
    
    private let viewModel: KIDKCityViewModel
    private let viewDidAppearSubject = PublishSubject<Void>()
    
    private let mapBackgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "kidk_city_map_background")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let mapContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let schoolBuildingImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "kidk_city_school")
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private let martBuildingImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "kidk_city_mart")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let characterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "kidk_character_side_walk_1")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let exclamationImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "kidk_icon_exclamation")
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = 0
        return imageView
    }()
    
    private let dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.alpha = 0
        return view
    }()
    
    private let schoolInfoCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .cardBackground.withAlphaComponent(0.9)
        view.layer.cornerRadius = CornerRadius.large
        return view
    }()
    
    private let schoolIconImageView = IconContainerView("kidk_icon_pencil",
                                                        backgroundColor: .kidkTextWhite, size: 60,
                                                        cornerRadius: CornerRadius.medium,
                                                        iconSize: 50, alpha: 0.1)
    
    private let schoolTitleLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(text: "학교", size: .s24, weight: .bold, color: .kidkTextWhite)
        return label
    }()
    
    private let schoolSubtitleLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(text: "학습과 관련된 미션을 할 수 있어요!", size: .s14, weight: .medium,
                             color: .kidkTextWhite.withAlphaComponent(0.8))
        return label
    }()
    
    private let arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = .chevronGray
        imageView.contentMode = .scaleAspectFit
        return imageView
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
    
    private var isWalking = false
    private var walkTimer: Timer?
    private var sheetViewController: UIViewController?
    
    init(viewModel: KIDKCityViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = .all
        self.extendedLayoutIncludesOpaqueBars = true
        setupUI()
        bind()
        checkAndShowSchoolCard()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewDidAppearSubject.onNext(())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    private func setupUI() {
        view.backgroundColor = .kidkDarkBackground
        
        view.addSubview(mapBackgroundImageView)
        view.addSubview(mapContainerView)
        mapContainerView.addSubview(schoolBuildingImageView)
        mapContainerView.addSubview(martBuildingImageView)
        mapContainerView.addSubview(characterImageView)
        mapContainerView.addSubview(exclamationImageView)
        view.addSubview(dimmedView)
        view.addSubview(schoolInfoCardView)
        view.addSubview(homeButton)
        
        schoolInfoCardView.addSubview(schoolIconImageView)
        schoolInfoCardView.addSubview(schoolTitleLabel)
        schoolInfoCardView.addSubview(schoolSubtitleLabel)
        schoolInfoCardView.addSubview(arrowImageView)
        
        mapBackgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        mapContainerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        schoolBuildingImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(100)
            make.width.equalTo(300)
            make.height.equalTo(250)
        }
        
        martBuildingImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-40)
            make.bottom.equalToSuperview().offset(-200)
            make.width.equalTo(200)
            make.height.equalTo(180)
        }
        
        characterImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(80)
            make.top.equalToSuperview().offset(200)
            make.width.height.equalTo(80)
        }
        
        exclamationImageView.snp.makeConstraints { make in
            make.centerX.equalTo(characterImageView)
            make.bottom.equalTo(characterImageView.snp.top).offset(-5)
            make.width.height.equalTo(40)
        }
        
        dimmedView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        schoolInfoCardView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-Spacing.md)
            make.height.equalTo(100)
        }
        
        schoolIconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Spacing.md)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(60)
        }
        
        schoolTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(schoolIconImageView.snp.trailing).offset(Spacing.md)
            make.top.equalToSuperview().offset(Spacing.md)
        }
        
        schoolSubtitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(schoolTitleLabel)
            make.top.equalTo(schoolTitleLabel.snp.bottom).offset(4)
        }
        
        arrowImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-Spacing.md)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        homeButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Spacing.md)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Spacing.md)
            make.width.height.equalTo(48)
        }
        
        let schoolTapGesture = UITapGestureRecognizer(target: self, action: #selector(schoolBuildingTapped))
        schoolBuildingImageView.addGestureRecognizer(schoolTapGesture)
        
        let cardTapGesture = UITapGestureRecognizer(target: self, action: #selector(schoolCardTapped))
        schoolInfoCardView.addGestureRecognizer(cardTapGesture)
        
        let homeTapGesture = UITapGestureRecognizer(target: self, action: #selector(homeButtonTapped))
        homeButton.addGestureRecognizer(homeTapGesture)
    }
    
    private func bind() {
        let locationTapped = PublishSubject<KIDKCityLocationType>()
        
        let input = KIDKCityViewModel.Input(
            viewDidAppear: viewDidAppearSubject.asObservable(),
            locationTapped: locationTapped.asObservable()
        )
        
        let output = viewModel.transform(input: input)
    }
    
    private func checkAndShowSchoolCard() {
        let hasActiveMission = false
        
        if !hasActiveMission {
            UIView.animate(withDuration: 0.4, delay: 0.5, options: .curveEaseOut) {
                self.schoolInfoCardView.alpha = 1
            }
        }
    }
    
    @objc private func schoolBuildingTapped() {
        showExclamationAndWalk()
    }
    
    @objc private func schoolCardTapped() {
        showExclamationAndWalk()
    }
    
    @objc private func homeButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    private func showExclamationAndWalk() {
        UIView.animate(withDuration: 0.3, delay: 0.3) {
            self.exclamationImageView.alpha = 1
        } completion: { _ in
            UIView.animate(withDuration: 0.3, delay: 0.5) {
                self.exclamationImageView.alpha = 0
            } completion: { _ in
                self.startWalkingAnimation()
            }
        }
    }
    
    private func startWalkingAnimation() {
        isWalking = true
        
        var walkFrame = 1
        walkTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            walkFrame = walkFrame == 1 ? 2 : 1
            self.characterImageView.image = UIImage(named: "kidk_character_side_walk_\(walkFrame)")
        }
        
        let schoolEntranceX = view.bounds.width / 2
        let schoolEntranceY = schoolBuildingImageView.frame.maxY - 40
        
        UIView.animate(withDuration: 3.0, delay: 0, options: .curveLinear) {
            self.characterImageView.frame.origin.x = schoolEntranceX - 40
            self.characterImageView.frame.origin.y = schoolEntranceY
        } completion: { [weak self] _ in
            self?.stopWalkingAnimation()
            self?.characterEntersSchool()
        }
    }
    
    private func stopWalkingAnimation() {
        isWalking = false
        walkTimer?.invalidate()
        walkTimer = nil
    }
    
    private func characterEntersSchool() {
        UIView.animate(withDuration: 0.5) {
            self.characterImageView.alpha = 0
            self.schoolInfoCardView.alpha = 0
        } completion: { _ in
            self.showDimmedOverlay()
        }
    }
    
    private func showDimmedOverlay() {
        UIView.animate(withDuration: 0.3) {
            self.dimmedView.alpha = 1
        } completion: { _ in
            self.showHalfSheet()
        }
    }
    
    private func showHalfSheet() {
        let sheetVC = MissionSelectionSheetViewController()
        
        if let sheet = sheetVC.sheetPresentationController {
            let customDetent = UISheetPresentationController.Detent.custom { context in
                return context.maximumDetentValue * 0.6
            }
            sheet.detents = [customDetent]
        }
        
        sheetVC.missionSelected
            .subscribe(onNext: { [weak self] missionType in
                self?.showMissionCreationSheet(missionType: missionType)
            })
            .disposed(by: disposeBag)
        
        sheetVC.missionSelected
            .subscribe(onNext: { [weak self] missionType in
                self?.showMissionCreationSheet(missionType: missionType)
            })
            .disposed(by: disposeBag)
        
        sheetVC.previousMissionTapped
            .subscribe(onNext: { [weak self] in
                self?.hideHalfSheet()
            })
            .disposed(by: disposeBag)
        
        sheetViewController = sheetVC
        present(sheetVC, animated: true)
    }
    
    private func showMissionCreationSheet(missionType: MissionType) {
        guard let currentSheet = sheetViewController else { return }
        
        // 중복 호출 방지
        sheetViewController = nil
        
        currentSheet.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            
            // 이미 다른 VC가 present되어 있는지 확인
            guard self.presentedViewController == nil else {
                print("⚠️ Already presenting something")
                return
            }
            
            let repository = MissionRepository(currentUserId: "user123")
            let viewModel = MissionCreationViewModel(missionRepository: repository, missionType: missionType)
            let viewController = MissionCreationViewController(viewModel: viewModel)
            
            if let sheet = viewController.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 20
            }
            
            viewController.missionCreated
                .subscribe(onNext: { [weak self] mission in
                    print("Mission created: \(mission.title)")
                    viewController.dismiss(animated: true) {
                        self?.showHalfSheet()
                    }
                })
                .disposed(by: self.disposeBag)
            
            viewController.previousTapped
                .subscribe(onNext: { [weak self] in
                    viewController.dismiss(animated: true) {
                        self?.showHalfSheet()
                    }
                })
                .disposed(by: self.disposeBag)
            
            self.sheetViewController = viewController
            self.present(viewController, animated: true)
        }
    }
    
    private func hideHalfSheet() {
        sheetViewController?.dismiss(animated: true) { [weak self] in
            UIView.animate(withDuration: 0.3) {
                self?.dimmedView.alpha = 0
            } completion: { _ in
                UIView.animate(withDuration: 0.3) {
                    self?.schoolInfoCardView.alpha = 1
                }
                self?.resetCharacterPosition()
            }
        }
    }
    
    private func resetCharacterPosition() {
        self.characterImageView.alpha = 1
        self.characterImageView.snp.remakeConstraints { make in
            make.leading.equalToSuperview().offset(80)
            make.top.equalToSuperview().offset(200)
            make.width.height.equalTo(80)
        }
        self.view.layoutIfNeeded()
    }
}
