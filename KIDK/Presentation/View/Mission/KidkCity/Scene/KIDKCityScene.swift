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
        isUserInteractionEnabled = true
        setupBackground()
        setupBuildings()
        setupCharacter()
        debugLog("Scene setup complete")
    }

    private func debugLog(_ message: String) {
        #if DEBUG
        print("🎮 [KIDKCityScene] \(message)")
        #endif
    }

    // MARK: - Setup
    private func setupBackground() {
        backgroundColor = .kidkDarkBackground

        // 배경 이미지 설정
        let backgroundTexture = SKTexture(imageNamed: "kidk_city_map_background")
        let background = SKSpriteNode(texture: backgroundTexture)
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.size = size
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
        debugLog("Touch at: \(location)")

        let touchedNodes = nodes(at: location)
        debugLog("Touched nodes count: \(touchedNodes.count)")

        for node in touchedNodes {
            debugLog("Node: \(node.name ?? "unnamed"), type: \(type(of: node))")
            if let buildingNode = node as? BuildingNode {
                debugLog("Building tapped: \(buildingNode.buildingType.displayName)")
                handleBuildingTap(buildingNode)
                return
            }
        }

        debugLog("No building node found at touch location")
    }

    private func handleBuildingTap(_ building: BuildingNode) {
        debugLog("handleBuildingTap called for: \(building.buildingType.displayName)")

        // 이미 이동 중이면 무시
        guard !characterNode.isMoving else {
            debugLog("Character is already moving, ignoring tap")
            return
        }

        // 잠금 체크
        if !building.isUnlocked {
            debugLog("Building is locked")
            building.showLockedAnimation()
            sceneDelegate?.didTapLockedBuilding(building.buildingType, requiredLevel: building.buildingType.requiredLevel)
            return
        }

        debugLog("Building is unlocked, starting highlight")
        // 해금된 건물: 하이라이트 → 이동 → 진입
        building.highlight { [weak self] in
            guard let self = self else { return }
            self.debugLog("Highlight complete, starting move")

            self.characterNode.move(to: building.position) { [weak self] in
                self?.debugLog("Move complete, entering building")
                self?.sceneDelegate?.didRequestBuildingEntry(building.buildingType)
            }
        }
    }
}
