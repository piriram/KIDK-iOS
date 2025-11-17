//
//  BuildingType.swift
//  KIDK
//
//  Created by Claude on 11/17/25.
//

import Foundation
import CoreGraphics

enum BuildingType: String, CaseIterable {
    case home
    case mart
    case school
    case special

    var displayName: String {
        switch self {
        case .home:
            return "집"
        case .mart:
            return "마트"
        case .school:
            return "학교"
        case .special:
            return "특별 건물"
        }
    }

    var requiredLevel: Int {
        switch self {
        case .home:
            return 1
        case .mart:
            return 5
        case .school:
            return 10
        case .special:
            return 20
        }
    }

    var imageName: String {
        switch self {
        case .home:
            return "kidk_city_home"
        case .mart:
            return "kidk_city_mart"
        case .school:
            return "kidk_city_school"
        case .special:
            return "kidk_city_home" // 특별 건물 이미지 없으면 home 사용
        }
    }

    /// 씬 내 위치 (0.0 ~ 1.0 비율)
    func position(sceneSize: CGSize) -> CGPoint {
        switch self {
        case .home:
            return CGPoint(x: sceneSize.width * 0.25, y: sceneSize.height * 0.7)
        case .mart:
            return CGPoint(x: sceneSize.width * 0.75, y: sceneSize.height * 0.7)
        case .school:
            return CGPoint(x: sceneSize.width * 0.25, y: sceneSize.height * 0.3)
        case .special:
            return CGPoint(x: sceneSize.width * 0.75, y: sceneSize.height * 0.3)
        }
    }
}
