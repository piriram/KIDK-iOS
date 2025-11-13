//
//  Typography.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/13/25.
//

import UIKit

extension UIFont {
    static func spoqaHanSansNeo(size: CGFloat, weight: Weight) -> UIFont {
        let fontName: String
        switch weight {
        case .bold:
            fontName = "SpoqaHanSansNeo-Bold"
        case .regular:
            fontName = "SpoqaHanSansNeo-Regular"
        default:
            fontName = "SpoqaHanSansNeo-Regular"
        }
        return UIFont(name: fontName, size: size) ?? .systemFont(ofSize: size, weight: weight)
    }
    
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
    
    static let kidkTitle = spoqaHanSansNeo(size: 20, weight: .bold)
    static let kidkSubtitle = spoqaHanSansNeo(size: 16, weight: .bold)
    static let kidkBody = spoqaHanSansNeo(size: 12, weight: .regular)
    
    static let kidkTitleEn = poppins(size: 20, weight: .bold)
    static let kidkSubtitleEn = poppins(size: 16, weight: .semibold)
    static let kidkBodyEn = poppins(size: 12, weight: .regular)
    
    func withLineHeight(_ lineHeight: CGFloat) -> [NSAttributedString.Key: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = lineHeight
        paragraphStyle.maximumLineHeight = lineHeight
        
        return [
            .font: self,
            .paragraphStyle: paragraphStyle
        ]
    }
}

extension UILabel {
    func setTextWithLineHeight(text: String, font: UIFont, lineHeight: CGFloat) {
        let attributes = font.withLineHeight(lineHeight)
        self.attributedText = NSAttributedString(string: text, attributes: attributes)
    }
}
