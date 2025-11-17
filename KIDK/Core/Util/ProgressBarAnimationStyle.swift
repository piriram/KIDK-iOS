//  ProgressBarAnimationStyle.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/15/25.
//

import UIKit

enum ProgressBarAnimationStyle {
    case none
    case easeInOut
    case easeOut
    case spring
    case bounce
    
    func animate(
        duration: TimeInterval = ProgressBarConfig.animationDuration,
        delay: TimeInterval = ProgressBarConfig.animationDelay,
        animations: @escaping () -> Void,
        completion: ((Bool) -> Void)? = nil
    ) {
        switch self {
        case .none:
            animations()
            completion?(true)
            
        case .easeInOut:
            UIView.animate(
                withDuration: duration,
                delay: delay,
                options: [.curveEaseInOut],
                animations: animations,
                completion: completion
            )
            
        case .easeOut:
            UIView.animate(
                withDuration: duration,
                delay: delay,
                options: [.curveEaseOut],
                animations: animations,
                completion: completion
            )
            
        case .spring:
            UIView.animate(
                withDuration: duration,
                delay: delay,
                usingSpringWithDamping: ProgressBarConfig.springDamping,
                initialSpringVelocity: ProgressBarConfig.springInitialVelocity,
                options: [.curveEaseInOut],
                animations: animations,
                completion: completion
            )
            
        case .bounce:
            UIView.animate(
                withDuration: duration,
                delay: delay,
                usingSpringWithDamping: ProgressBarConfig.bounceDamping,
                initialSpringVelocity: ProgressBarConfig.bounceInitialVelocity,
                options: [.curveEaseOut],
                animations: animations,
                completion: completion
            )
        }
    }
}
