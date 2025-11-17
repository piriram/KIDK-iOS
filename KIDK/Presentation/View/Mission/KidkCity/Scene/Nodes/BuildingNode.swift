//
//  BuildingNode.swift
//  KIDK
//
//  Created by Claude on 11/17/25.
//

import SpriteKit

final class BuildingNode: SKSpriteNode {

    // MARK: - Properties
    let buildingType: BuildingType

    var isUnlocked: Bool {
        didSet {
            updateAppearance()
        }
    }

    private var highlightBorder: SKShapeNode?

    // MARK: - Initialization
    init(buildingType: BuildingType, isUnlocked: Bool) {
        self.buildingType = buildingType
        self.isUnlocked = isUnlocked

        let texture = SKTexture(imageNamed: buildingType.imageName)
        super.init(texture: texture, color: .clear, size: texture.size())

        self.name = buildingType.rawValue
        self.isUserInteractionEnabled = false // Scene에서 터치 처리

        // 적절한 크기로 조정 (원본 비율 유지)
        let targetHeight: CGFloat = 180
        let aspectRatio = texture.size().width / texture.size().height
        self.size = CGSize(width: targetHeight * aspectRatio, height: targetHeight)

        updateAppearance()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Appearance
    private func updateAppearance() {
        if isUnlocked {
            self.alpha = 1.0
            self.colorBlendFactor = 0.0
        } else {
            self.alpha = 0.5
            self.color = .gray
            self.colorBlendFactor = 0.6
        }
    }

    // MARK: - Animations
    func highlight(completion: @escaping () -> Void) {
        // 테두리 생성
        let border = SKShapeNode(rectOf: size, cornerRadius: 8)
        border.strokeColor = .kidkPink
        border.lineWidth = 4
        border.fillColor = .clear
        border.position = .zero
        addChild(border)
        highlightBorder = border

        // 깜빡임 애니메이션
        let fadeOut = SKAction.fadeAlpha(to: 0.3, duration: 0.2)
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.2)
        let blink = SKAction.sequence([fadeOut, fadeIn])
        let repeat3Times = SKAction.repeat(blink, count: 3)

        border.run(repeat3Times) { [weak self] in
            self?.highlightBorder?.removeFromParent()
            self?.highlightBorder = nil
            completion()
        }
    }

    func showLockedAnimation() {
        // 좌우로 흔들리는 애니메이션
        let rotateLeft = SKAction.rotate(byAngle: -0.1, duration: 0.1)
        let rotateRight = SKAction.rotate(byAngle: 0.1, duration: 0.1)
        let rotateBack = SKAction.rotate(byAngle: 0.0, duration: 0.1)
        let shake = SKAction.sequence([rotateLeft, rotateRight, rotateLeft, rotateRight, rotateBack])

        run(shake)
    }
}
