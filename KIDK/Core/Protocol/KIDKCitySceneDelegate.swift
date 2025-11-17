//
//  KIDKCitySceneDelegate.swift
//  KIDK
//
//  Created by Claude on 11/17/25.
//

import Foundation

protocol KIDKCitySceneDelegate: AnyObject {
    func didRequestBuildingEntry(_ type: BuildingType)
    func didTapLockedBuilding(_ type: BuildingType, requiredLevel: Int)
}
