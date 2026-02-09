//
//  +Font.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/15/25.
//

import UIKit

// MARK: - Font Debug

private extension SceneDelegate {
    func debugPrintInstalledFonts() {
        #if DEBUG
        for family in UIFont.familyNames.sorted() {
            print("=== \(family) ===")
            for name in UIFont.fontNames(forFamilyName: family).sorted() {
                print("  \(name)")
            }
        }
        #endif
    }
}
