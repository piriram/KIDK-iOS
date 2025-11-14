//
//  UIView+.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/15/25.
//

import UIKit

extension UIView {
    func makeCircular() {
        layoutIfNeeded()
        
        let side = min(bounds.width, bounds.height)
        layer.cornerRadius = side / 2
        clipsToBounds = true
    }
}

