//
//  KIDKCityScene.swift
//  KIDK
//
//  Created by Claude on 11/17/25.
//

import SpriteKit

final class KIDKCityScene: SKScene {

    // MARK: - Properties
    weak var sceneDelegate: KIDKCitySceneDelegate?

    private var characterNode: CharacterNode!
    private var buildingNodes: [BuildingType: BuildingNode] = [:]

    // zPosition 레이어
    private enum ZPosition: CGFloat {
        case background = 0
        case buildings = 10
        case character = 20
        case effects = 30
        case ui = 100
    }

    // MARK: - Lifecycle
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        setupBackground()
        setupBuildings()
        setupCharacter()
    }

    // MARK: - Setup
    private func setupBackground() {
        backgroundColor = .kidkDarkBackground

        // 간단한 배경 설정
        let background = SKSpriteNode(color: .kidkDarkBackground, size: size)
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = ZPosition.background.rawValue
        addChild(background)
    }

    private func setupBuildings() {
        for buildingType in BuildingType.allCases {
            let position = buildingType.position(sceneSize: size)
            let building = BuildingNode(buildingType: buildingType, isUnlocked: false)
            building.position = position
            building.zPosition = ZPosition.buildings.rawValue
            building.name = buildingType.rawValue

            buildingNodes[buildingType] = building
            addChild(building)
        }
    }

    private func setupCharacter() {
        characterNode = CharacterNode()
        characterNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        characterNode.zPosition = ZPosition.character.rawValue
        addChild(characterNode)
    }

    // MARK: - Public Methods
    func updateUnlockedBuildings(_ types: Set<BuildingType>) {
        for (buildingType, buildingNode) in buildingNodes {
            buildingNode.isUnlocked = types.contains(buildingType)
        }
    }

    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)

        for node in touchedNodes {
            if let buildingNode = node as? BuildingNode {
                handleBuildingTap(buildingNode)
                return
            }
        }
    }

    private func handleBuildingTap(_ building: BuildingNode) {
        // 이미 이동 중이면 무시
        guard !characterNode.isMoving else { return }

        // 잠금 체크
        if !building.isUnlocked {
            building.showLockedAnimation()
            sceneDelegate?.didTapLockedBuilding(building.buildingType, requiredLevel: building.buildingType.requiredLevel)
            return
        }

        // 해금된 건물: 하이라이트 → 이동 → 진입
        building.highlight { [weak self] in
            guard let self = self else { return }

            self.characterNode.move(to: building.position) { [weak self] in
                self?.sceneDelegate?.didRequestBuildingEntry(building.buildingType)
            }
        }
    }
}
