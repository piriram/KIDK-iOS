//
//  Typography.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/13/25.
//

import UIKit

enum FontSize: CGFloat {
    case s10 = 10
    case s12 = 12
    case s14 = 14
    case s16 = 16
    case s18 = 18
    case s20 = 20
    case s22 = 22
    case s24 = 24
    case s26 = 26
    case s28 = 28
    case s30 = 30
    case s32 = 32
    case s34 = 34
    case s36 = 36
}

extension UIFont {
    /// legacy
    static func spoqaHanSansNeo(size: CGFloat, weight: Weight) -> UIFont {
        let fontName: String
        switch weight {
        case .bold:
            fontName = "SpoqaHanSansNeo-Bold"
        case .regular:
            fontName = "SpoqaHanSansNeo-Regular"
        case .medium:
            fontName = "SpoqaHanSansNeo-Medium"
        default:
            fontName = "SpoqaHanSansNeo-Regular"
        }
        return UIFont(name: fontName, size: size) ?? .systemFont(ofSize: size, weight: weight)
    }
    ///legacy
    static func poppins(size: CGFloat, weight: Weight) -> UIFont {
        let fontName: String
        switch weight {
        case .bold:
            fontName = "Poppins-Bold"
        case .semibold:
            fontName = "Poppins-SemiBold"
        case .regular:
            fontName = "Poppins-Regular"
        default:
            fontName = "Poppins-Regular"
        }
        return UIFont(name: fontName, size: size) ?? .systemFont(ofSize: size, weight: weight)
    }
    
    static func kidkFont(_ size: FontSize, _ weight: Weight = .regular) -> UIFont {
        return spoqaHanSansNeo(size: size.rawValue, weight: weight)
    }
    
    static let kidkTitle = spoqaHanSansNeo(size: 20, weight: .bold)
    static let kidkSubtitle = spoqaHanSansNeo(size: 16, weight: .bold)
    static let kidkBody = spoqaHanSansNeo(size: 14, weight: .medium)
    
    static let kidkTitleEn = poppins(size: 20, weight: .bold)
    static let kidkSubtitleEn = poppins(size: 16, weight: .semibold)
    static let kidkBodyEn = poppins(size: 12, weight: .regular)
}

extension UILabel {
    func applyTextStyle(text: String,
                  size: FontSize,
                  weight: UIFont.Weight,
                  color: UIColor,
                  lineHeight: CGFloat = 120) {
        self.text = text
        
        self.textColor = color
        
        
        let font = UIFont.kidkFont(size, weight)
        let calculatedLineHeight = font.pointSize * (lineHeight / 100)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = calculatedLineHeight
        paragraphStyle.maximumLineHeight = calculatedLineHeight
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .paragraphStyle: paragraphStyle,
            .foregroundColor: self.textColor ?? UIColor.kidkTextPrimary
        ]
        
        let displayText = self.text ?? ""
        self.attributedText = NSAttributedString(string: displayText, attributes: attributes)
    }
}
