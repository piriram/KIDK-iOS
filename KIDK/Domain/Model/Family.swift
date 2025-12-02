//
//  Family.swift
//  KIDK
//
//  Created by KIDK on 12/02/24.
//

import Foundation

// MARK: - Family Role

enum FamilyRole: String, Codable {
    case parent = "PARENT"
    case child = "CHILD"
}

// MARK: - Family

struct Family: Codable {
    let id: String
    let familyName: String
    let inviteCode: String
    let createdAt: Date
    let updatedAt: Date

    var formattedCreatedDate: String {
        return createdAt.formattedFullDate
    }
}

// MARK: - Family Member

struct FamilyMember: Codable {
    let id: String
    let familyId: String
    let userId: String
    let userName: String?
    let role: FamilyRole
    let joinedAt: Date

    var isParent: Bool {
        return role == .parent
    }

    var isChild: Bool {
        return role == .child
    }

    var formattedJoinedDate: String {
        return joinedAt.formattedFullDate
    }
}

// MARK: - Family Creation Request

struct FamilyCreationRequest {
    let familyName: String
    let creatorId: String
    let creatorRole: FamilyRole
}

// MARK: - Family Join Request

struct FamilyJoinRequest {
    let userId: String
    let inviteCode: String
    let role: FamilyRole
}
