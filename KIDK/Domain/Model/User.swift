//
//  User.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/13/25.
//

import Foundation

struct User {
    let id: String
    let firebaseUID: String
    let userType: UserType
    let name: String
    let nickname: String?
    let profileImageURL: String?
    let birthdate: Date?
    let status: UserStatus
    let createdAt: Date
    let lastLoginAt: Date?
    
    init(
        id: String,
        firebaseUID: String,
        userType: UserType,
        name: String,
        nickname: String? = nil,
        profileImageURL: String? = nil,
        birthdate: Date? = nil,
        status: UserStatus = .active,
        createdAt: Date = Date(),
        lastLoginAt: Date? = nil
    ) {
        self.id = id
        self.firebaseUID = firebaseUID
        self.userType = userType
        self.name = name
        self.nickname = nickname
        self.profileImageURL = profileImageURL
        self.birthdate = birthdate
        self.status = status
        self.createdAt = createdAt
        self.lastLoginAt = lastLoginAt
    }
}
