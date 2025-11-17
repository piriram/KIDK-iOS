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

    // MARK: - Initialization
    init() {
        let texture = SKTexture(imageNamed: "character_placeholder")
        super.init(texture: texture, color: .kidkPink, size: CGSize(width: 50, height: 50))

        self.colorBlendFactor = 1.0
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
            xScale = -1 // 왼쪽으로 이동
        } else {
            xScale = 1 // 오른쪽으로 이동
        }

        // 걷기 애니메이션 (위아래 흔들림)
        let walkUp = SKAction.moveBy(x: 0, y: 5, duration: 0.15)
        let walkDown = SKAction.moveBy(x: 0, y: -5, duration: 0.15)
        let walkCycle = SKAction.sequence([walkUp, walkDown])
        let walkAnimation = SKAction.repeatForever(walkCycle)

        // 이동 액션
        let moveAction = SKAction.move(to: targetPosition, duration: duration)
        moveAction.timingMode = .easeInEaseOut

        // 그룹으로 동시 실행
        let walkKey = "walkAnimation"
        run(walkAnimation, withKey: walkKey)

        run(moveAction) { [weak self] in
            guard let self = self else { return }
            self.removeAction(forKey: walkKey)
            self.isMoving = false
            completion()
        }
    }
}
