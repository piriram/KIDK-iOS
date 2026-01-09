import Foundation
import RxSwift

protocol UserRepositoryProtocol {
    /// Get current user's profile
    func getMyProfile() -> Single<User>

    /// Get another user's profile by ID
    func getUserProfile(userId: String) -> Single<User>

    /// Update current user's profile
    func updateProfile(name: String, birthDate: Date?, phone: String?) -> Single<User>

    /// Update user status
    func updateStatus(status: UserStatus) -> Single<User>
}
