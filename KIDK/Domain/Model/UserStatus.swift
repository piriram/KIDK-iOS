//
//  UserStatus.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/13/25.
//

import Foundation

enum UserStatus: String, Codable {
    case active = "ACTIVE"
    case dormant = "DORMANT"
    case withdrawn = "WITHDRAWN"
    case deleted = "DELETED"
}
