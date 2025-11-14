//
//  AuthRepository.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/13/25.
//

import Foundation
import RxSwift

final class AuthRepository: BaseRepository, AuthRepositoryProtocol {
    
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

