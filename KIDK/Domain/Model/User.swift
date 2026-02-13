import Foundation

struct User {
    let id: String
    let firebaseUID: String
    let userType: UserType
    var name: String
    var nickname: String?
    var profileImageURL: String?
    var birthdate: Date?
    var status: UserStatus
    let createdAt: Date
    var lastLoginAt: Date?
    
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
