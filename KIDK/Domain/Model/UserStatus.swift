import Foundation

enum UserStatus: String, Codable {
    case active = "ACTIVE"
    case dormant = "DORMANT"
    case withdrawn = "WITHDRAWN"
    case deleted = "DELETED"
}
