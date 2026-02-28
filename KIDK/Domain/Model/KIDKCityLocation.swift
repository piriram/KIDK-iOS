import Foundation
import CoreGraphics

enum KIDKCityLocationType: String, Hashable {
    case home
    case school
    case mart
}

struct KIDKCityLocation {
    let type: KIDKCityLocationType
    let position: CGPoint
    let isUnlocked: Bool
    let requiredLevel: Int
    
    var iconName: String {
        switch type {
        case .home:
            return "kidk_city_home"
        case .school:
            return "kidk_icon_pencil"
        case .mart:
            return "kidk_icon_bowl"
        }
    }
    
    var buildingImageName: String {
        switch type {
        case .home:
            return "kidk_city_home"
        case .school:
            return "kidk_city_school"
        case .mart:
            return "kidk_city_mart"
        }
    }
}
