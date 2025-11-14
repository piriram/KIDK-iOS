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
    
    static let animationStyle: ProgressBarAnimationStyle = .easeOut
    static let animationDuration: TimeInterval = 1.0
    static let animationDelay: TimeInterval = 0.0
    
    static let springDamping: CGFloat = 0.8
    static let springInitialVelocity: CGFloat = 0.5
    
    static let bounceDamping: CGFloat = 0.6
    static let bounceInitialVelocity: CGFloat = 1.0
}
