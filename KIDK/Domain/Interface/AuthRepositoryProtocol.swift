//
//  AuthRepositoryProtocol.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/13/25.
//

import Foundation
import RxSwift

protocol AuthRepositoryProtocol {
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
