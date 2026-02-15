import Foundation
import RxSwift

protocol AuthRepositoryProtocol {
    // Real API
    func login(firebaseToken: String, firebaseUID: String) -> Observable<Result<User, NetworkError>>
    func devLogin() -> Observable<Result<User, NetworkError>>
    func logout() -> Observable<Result<Void, NetworkError>>

    // Mock methods
    func generateMockUser(userType: UserType) -> Observable<User>
    func getCurrentUser() -> Observable<User?>
    func saveSession(user: User) -> Observable<Void>
    func clearSession() -> Observable<Void>
    func isFirstLaunch() -> Bool
    func setFirstLaunchComplete()
    func isAutoLoginEnabled() -> Bool
    func saveAutoLoginPreference(_ isEnabled: Bool)
    func saveLoginCredentials(email: String)
    func getLastLoginEmail() -> String?
}
