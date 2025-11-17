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
        view.addSubview(homeButton)

        skView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
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
        onBuildingEnter?(type)
    }

    func didTapLockedBuilding(_ type: BuildingType, requiredLevel: Int) {
        let message = "\(type.displayName)은(는) 레벨 \(requiredLevel)에 해금됩니다!"
        showAlert(title: "잠금됨", message: message)
    }
}

// MARK: - Actions
extension KIDKCityViewController {

    @objc private func homeButtonTapped() {
        debugLog("Home button tapped")
        navigationController?.popViewController(animated: true)
    }
}
