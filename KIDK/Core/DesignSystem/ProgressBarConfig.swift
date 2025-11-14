//TODO: 바운시말고 다양한 애니메이션을 enum으로 관리하면서 해보기. enum은 어디서든 쓸 수 있또록
//
//  ProgressBarConfig.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/15/25.
//

import UIKit

enum ProgressBarConfig {
    static let maxVisibleCategories = 6
    static let othersThreshold: Double = 0.05
    
    static let barHeight: CGFloat = 16
    static let barCornerRadius: CGFloat = 8
    
    static let brandColors: [UIColor] = [
        .kidkPink,
        .kidkGreen,
        .kidkBlue,
        UIColor(hex: "#FFB800"),
        UIColor(hex: "#9D4EDD")
    ]
    
    static let othersColor: UIColor = .kidkGray
    
    static let animationDuration: TimeInterval = 1.0
    static let animationDelay: TimeInterval = 0.0
}
