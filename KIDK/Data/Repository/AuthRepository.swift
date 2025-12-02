//
//  AuthRepository.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/13/25.
//

import Foundation
import RxSwift
import UIKit

final class AuthRepository: BaseRepository, AuthRepositoryProtocol {

    // MARK: - Real API

    func login(firebaseToken: String, firebaseUID: String) -> Observable<Result<User, NetworkError>> {
        debugLog("Starting login with Firebase token")

        let deviceId = UIDevice.current.identifierForVendor?.uuidString

        return networkService.request(AuthAPI.login(firebaseToken: firebaseToken, deviceId: deviceId))
            .do(onNext: { [weak self] (result: Result<ApiResponse<LoginResponseData>, NetworkError>) in
                guard let self = self else { return }

                switch result {
                case .success(let apiResponse):
                    guard let loginData = apiResponse.data else {
                        self.debugError("Login response data is nil", error: nil)
                        return
                    }

                    // 토큰 저장
                    self.tokenManager.saveAccessToken(loginData.accessToken)
                    self.tokenManager.saveRefreshToken(loginData.refreshToken)

                    // 사용자 정보 저장
                    let user = loginData.toDomain(firebaseUID: firebaseUID)
                    self.userDefaultsManager.saveMockFirebaseUID(user.firebaseUID)
                    self.userDefaultsManager.saveUserType(user.userType.rawValue)
                    self.userDefaultsManager.saveLastLoginDate(Date())

                    self.debugSuccess("Login successful, tokens saved")

                case .failure(let error):
                    self.debugError("Login failed", error: error)
                }
            })
            .map { [firebaseUID] (result: Result<ApiResponse<LoginResponseData>, NetworkError>) -> Result<User, NetworkError> in
                return result.flatMap { apiResponse in
                    guard let loginData = apiResponse.data else {
                        return .failure(.decodingFailed(NSError(domain: "AuthRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Login data is nil"])))
                    }
                    return .success(loginData.toDomain(firebaseUID: firebaseUID))
                }
            }
    }

    func logout() -> Observable<Result<Void, NetworkError>> {
        debugLog("Starting logout")

        // RefreshToken 가져오기
        guard let refreshToken = tokenManager.refreshToken else {
            debugWarning("No refresh token found, proceeding with local logout")
            // 토큰이 없어도 로컬 세션은 정리
            return clearSession()
                .map { .success(()) }
                .catch { error in
                    return .just(.failure(.unknown(error)))
                }
        }

        return networkService.request(AuthAPI.logout(refreshToken: refreshToken))
            .do(onNext: { [weak self] (result: Result<ApiResponse<EmptyResponse>, NetworkError>) in
                guard let self = self else { return }

                switch result {
                case .success:
                    // 서버 로그아웃 성공 시 로컬 세션 정리
                    self.tokenManager.clearAllTokens()
                    self.userDefaultsManager.clearAll()

                    do {
                        try self.keychainWrapper.delete(key: "mock_token")
                    } catch {
                        self.debugWarning("Failed to delete keychain token: \(error.localizedDescription)")
                    }

                    self.debugSuccess("Logout successful, session cleared")

                case .failure(let error):
                    self.debugError("Logout API failed", error: error)
                    // API 실패해도 로컬 세션은 정리
                    self.tokenManager.clearAllTokens()
                    self.userDefaultsManager.clearAll()

                    do {
                        try self.keychainWrapper.delete(key: "mock_token")
                    } catch {
                        self.debugWarning("Failed to delete keychain token: \(error.localizedDescription)")
                    }
                }
            })
            .map { (result: Result<ApiResponse<EmptyResponse>, NetworkError>) -> Result<Void, NetworkError> in
                // API 성공/실패 여부와 관계없이 로컬 세션은 정리되었으므로 성공 반환
                return .success(())
            }
    }

    // MARK: - Mock Methods

    func isAutoLoginEnabled() -> Bool {
        return userDefaultsManager.loadIsAutoLoginEnabled()
    }

    func saveAutoLoginPreference(_ isEnabled: Bool) {
        userDefaultsManager.saveIsAutoLoginEnabled(isEnabled)
        debugLog("Auto-login preference saved: \(isEnabled)")
    }

    func saveLoginCredentials(email: String) {
        userDefaultsManager.saveEmail(email)
        debugLog("Login email saved")
    }

    func getLastLoginEmail() -> String? {
        return userDefaultsManager.loadEmail()
    }
    
   
    
    
    private let mockDataSource: MockAuthDataSource
    private let userDefaultsManager: UserDefaultsManager
    private let keychainWrapper: KeychainWrapper
    
    init(
        mockDataSource: MockAuthDataSource = MockAuthDataSource(),
        userDefaultsManager: UserDefaultsManager = .shared,
        keychainWrapper: KeychainWrapper = .shared
    ) {
        self.mockDataSource = mockDataSource
        self.userDefaultsManager = userDefaultsManager
        self.keychainWrapper = keychainWrapper
        super.init()
    }
    
    func generateMockUser(userType: UserType) -> Observable<User> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onError(RepositoryError.unknown(NSError(domain: "AuthRepository", code: -1)))
                return Disposables.create()
            }
            
            self.debugLog("Generating mock user with type: \(userType)")
            
            let firebaseUID = self.mockDataSource.generateMockFirebaseUID()
            let user = self.mockDataSource.createMockUser(firebaseUID: firebaseUID, userType: userType)
            
            self.userDefaultsManager.saveMockFirebaseUID(firebaseUID)
            self.userDefaultsManager.saveUserType(userType.rawValue)
            
            do {
                try self.keychainWrapper.save(key: "mock_token", value: firebaseUID)
                self.debugSuccess("Mock user generated successfully")
                observer.onNext(user)
                observer.onCompleted()
            } catch {
                self.debugError("Failed to save mock token", error: error)
                observer.onError(RepositoryError.unknown(error))
            }
            
            return Disposables.create()
        }
    }
    
    func getCurrentUser() -> Observable<User?> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onError(RepositoryError.unknown(NSError(domain: "AuthRepository", code: -1)))
                return Disposables.create()
            }
            
            guard let firebaseUID = self.userDefaultsManager.loadMockFirebaseUID(),
                  let userTypeString = self.userDefaultsManager.loadUserType(),
                  let userType = UserType(rawValue: userTypeString) else {
                self.debugLog("No current user found")
                observer.onNext(nil)
                observer.onCompleted()
                return Disposables.create()
            }
            
            let user = self.mockDataSource.createMockUser(firebaseUID: firebaseUID, userType: userType)
            self.debugSuccess("Current user loaded")
            observer.onNext(user)
            observer.onCompleted()
            
            return Disposables.create()
        }
    }
    
    func saveSession(user: User) -> Observable<Void> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onError(RepositoryError.unknown(NSError(domain: "AuthRepository", code: -1)))
                return Disposables.create()
            }
            
            self.userDefaultsManager.saveMockFirebaseUID(user.firebaseUID)
            self.userDefaultsManager.saveUserType(user.userType.rawValue)
            self.userDefaultsManager.saveLastLoginDate(Date())
            
            do {
                try self.keychainWrapper.save(key: "mock_token", value: user.firebaseUID)
                self.debugSuccess("Session saved")
                observer.onNext(())
                observer.onCompleted()
            } catch {
                self.debugError("Failed to save session", error: error)
                observer.onError(RepositoryError.unknown(error))
            }
            
            return Disposables.create()
        }
    }
    
    func clearSession() -> Observable<Void> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onError(RepositoryError.unknown(NSError(domain: "AuthRepository", code: -1)))
                return Disposables.create()
            }
            
            self.userDefaultsManager.clearAll()
            
            do {
                try self.keychainWrapper.delete(key: "mock_token")
                self.debugSuccess("Session cleared")
                observer.onNext(())
                observer.onCompleted()
            } catch {
                self.debugError("Failed to clear session", error: error)
                observer.onError(RepositoryError.unknown(error))
            }
            
            return Disposables.create()
        }
    }
    
    func isFirstLaunch() -> Bool {
        return !userDefaultsManager.loadIsFirstLaunch()
    }
    
    func setFirstLaunchComplete() {
        userDefaultsManager.saveIsFirstLaunch(true)
        debugLog("First launch completed")
    }
    
}

