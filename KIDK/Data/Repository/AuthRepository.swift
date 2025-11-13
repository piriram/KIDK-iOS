//
//  AuthRepository.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/13/25.
//

import Foundation
import RxSwift

final class AuthRepository: AuthRepositoryProtocol {
    
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
    }
    
    func generateMockUser(userType: UserType) -> Observable<User> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onError(AuthError.unknown)
                return Disposables.create()
            }
            
            let firebaseUID = self.mockDataSource.generateMockFirebaseUID()
            let user = self.mockDataSource.createMockUser(firebaseUID: firebaseUID, userType: userType)
            
            self.userDefaultsManager.saveMockFirebaseUID(firebaseUID)
            self.userDefaultsManager.saveUserType(userType.rawValue)
            
            do {
                try self.keychainWrapper.save(key: "mock_token", value: firebaseUID)
                observer.onNext(user)
                observer.onCompleted()
            } catch {
                observer.onError(AuthError.sessionSaveFailed)
            }
            
            return Disposables.create()
        }
    }
    
    func getCurrentUser() -> Observable<User?> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onError(AuthError.unknown)
                return Disposables.create()
            }
            
            guard let firebaseUID = self.userDefaultsManager.loadMockFirebaseUID(),
                  let userTypeString = self.userDefaultsManager.loadUserType(),
                  let userType = UserType(rawValue: userTypeString) else {
                observer.onNext(nil)
                observer.onCompleted()
                return Disposables.create()
            }
            
            let user = self.mockDataSource.createMockUser(firebaseUID: firebaseUID, userType: userType)
            observer.onNext(user)
            observer.onCompleted()
            
            return Disposables.create()
        }
    }
    
    func saveSession(user: User) -> Observable<Void> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onError(AuthError.unknown)
                return Disposables.create()
            }
            
            self.userDefaultsManager.saveMockFirebaseUID(user.firebaseUID)
            self.userDefaultsManager.saveUserType(user.userType.rawValue)
            self.userDefaultsManager.saveLastLoginDate(Date())
            
            do {
                try self.keychainWrapper.save(key: "mock_token", value: user.firebaseUID)
                observer.onNext(())
                observer.onCompleted()
            } catch {
                observer.onError(AuthError.sessionSaveFailed)
            }
            
            return Disposables.create()
        }
    }
    
    func clearSession() -> Observable<Void> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onError(AuthError.unknown)
                return Disposables.create()
            }
            
            self.userDefaultsManager.clearAll()
            
            do {
                try self.keychainWrapper.delete(key: "mock_token")
                observer.onNext(())
                observer.onCompleted()
            } catch {
                observer.onError(AuthError.sessionClearFailed)
            }
            
            return Disposables.create()
        }
    }
    
    func isFirstLaunch() -> Bool {
        return !userDefaultsManager.loadIsFirstLaunch()
    }
    
    func setFirstLaunchComplete() {
        userDefaultsManager.saveIsFirstLaunch(true)
    }
}

enum AuthError: Error {
    case sessionSaveFailed
    case sessionClearFailed
    case unknown
}
