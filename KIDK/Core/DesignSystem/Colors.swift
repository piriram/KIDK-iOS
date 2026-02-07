//
//  Colors.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/13/25.
//

import UIKit

extension UIColor {
    static let kidkPinkLight = UIColor(hex: "#FFC4DE")
    static let kidkPink = UIColor(hex: "#F54F95")
    static let kidkGreen = UIColor(hex: "#16E8AD")
    static let kidkBlue = UIColor(hex: "#0095FF")
    static let kidkGray = UIColor(hex: "#97979A")
    static let kidkBlack = UIColor(hex: "#1B1B1C")
    static let kidkDarkBackground = UIColor(hex: "#242426")
    
    static let kidkTextPrimary = UIColor(hex: "#1B1B1C")
    static let kidkTextSecondary = UIColor(hex: "#3C3C40")
    static let cardBackground = UIColor(hex: "#303036")
    static let kidkTextWhite = UIColor.white
    
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}
