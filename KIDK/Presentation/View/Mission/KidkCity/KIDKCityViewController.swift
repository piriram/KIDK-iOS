//
//  KIDKCityViewController.swift
//  KIDK
//
//  Created by Claude on 11/17/25.
//

import UIKit
import SpriteKit
import RxSwift
import RxCocoa
import SnapKit

final class KIDKCityViewController: BaseViewController {

    // MARK: - Properties
    private let viewModel: KIDKCityViewModel
    private var cityScene: KIDKCityScene!

    var onBuildingEnter: ((BuildingType) -> Void)?

    // MARK: - UI Components
    private lazy var skView: SKView = {
        let view = SKView()
        view.showsFPS = true
        view.showsNodeCount = true
        view.ignoresSiblingOrder = true
        view.backgroundColor = .clear
        return view
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

    private let dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.alpha = 0
        view.isHidden = true
        return view
    }()

    private var sheetViewController: UIViewController?

    // MARK: - Initialization
    init(viewModel: KIDKCityViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupScene()
        bind()
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

    // MARK: - Setup
    private func setupUI() {
        view.addSubview(skView)
        view.addSubview(dimmedView)
        view.addSubview(homeButton)

        skView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        dimmedView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        homeButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Spacing.md)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Spacing.md)
            make.width.height.equalTo(48)
        }

        let homeTapGesture = UITapGestureRecognizer(target: self, action: #selector(homeButtonTapped))
        homeButton.addGestureRecognizer(homeTapGesture)
    }

    private func setupScene() {
        let scene = KIDKCityScene(size: view.bounds.size)
        scene.scaleMode = .aspectFill
        scene.sceneDelegate = self

        cityScene = scene
        skView.presentScene(scene)
    }

    private func bind() {
        let input = KIDKCityViewModel.Input(
            viewDidLoad: Observable.just(())
        )

        let output = viewModel.transform(input: input)

        output.unlockedBuildings
            .drive(onNext: { [weak self] buildings in
                self?.cityScene.updateUnlockedBuildings(buildings)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - KIDKCitySceneDelegate
extension KIDKCityViewController: KIDKCitySceneDelegate {

    func didRequestBuildingEntry(_ type: BuildingType) {
        debugLog("Building entry requested: \(type.displayName)")

        // Home이나 School 건물은 미션 생성 시트 표시
        if type == .home || type == .school {
            showDimmedOverlay()
        } else {
            onBuildingEnter?(type)
        }
    }

    func didTapLockedBuilding(_ type: BuildingType, requiredLevel: Int) {
        let message = "\(type.displayName)은(는) 레벨 \(requiredLevel)에 해금됩니다!"
        showAlert(title: "잠금됨", message: message)
    }
}

// MARK: - Sheet Presentation
extension KIDKCityViewController {

    private func showDimmedOverlay() {
        dimmedView.isHidden = false
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
                self.debugWarning("Already presenting something")
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
                    self?.debugLog("Mission created: \(mission.title)")
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
                self?.dimmedView.isHidden = true
            }
        }
    }
}

// MARK: - Actions
extension KIDKCityViewController {

    @objc private func homeButtonTapped() {
        debugLog("Home button tapped")
        navigationController?.popViewController(animated: true)
    }
}
