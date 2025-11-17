//
//  CharacterNode.swift
//  KIDK
//
//  Created by Claude on 11/17/25.
//

import SpriteKit

final class CharacterNode: SKSpriteNode {

    // MARK: - Properties
    private(set) var isMoving: Bool = false

    // MARK: - Constants
    private let movementSpeed: CGFloat = 200 // points per second
    private let walkTextures: [SKTexture] = [
        SKTexture(imageNamed: "kidk_character_side_walk_1"),
        SKTexture(imageNamed: "kidk_character_side_walk_2")
    ]

    // MARK: - Initialization
    init() {
        let texture = SKTexture(imageNamed: "kidk_character_side_walk_1")
        super.init(texture: texture, color: .clear, size: CGSize(width: 80, height: 80))

        self.colorBlendFactor = 0.0
        self.name = "character"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Movement
    func move(to targetPosition: CGPoint, completion: @escaping () -> Void) {
        // 이동 중이면 무시
        guard !isMoving else { return }

        isMoving = true

        // 거리 계산
        let dx = targetPosition.x - position.x
        let dy = targetPosition.y - position.y
        let distance = sqrt(dx * dx + dy * dy)

        // 이동 시간 계산
        let duration = TimeInterval(distance / movementSpeed)

        // 방향에 따라 좌우 반전
        if dx < 0 {
            xScale = -abs(xScale) // 왼쪽으로 이동
        } else {
            xScale = abs(xScale) // 오른쪽으로 이동
        }

        // 걷기 애니메이션 (텍스처 교체)
        let textureAnimation = SKAction.animate(with: walkTextures, timePerFrame: 0.2)
        let walkAnimation = SKAction.repeatForever(textureAnimation)

        // 이동 액션
        let moveAction = SKAction.move(to: targetPosition, duration: duration)
        moveAction.timingMode = .easeInEaseOut

        // 걷기 애니메이션 시작
        let walkKey = "walkAnimation"
        run(walkAnimation, withKey: walkKey)

        run(moveAction) { [weak self] in
            guard let self = self else { return }
            self.removeAction(forKey: walkKey)
            self.texture = self.walkTextures[0] // 기본 포즈로 복원
            self.isMoving = false
            completion()
        }
    }
}
