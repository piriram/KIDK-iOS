//
//  FirebaseAuthService.swift
//  KIDK
//
//  Created by KIDK on 11/27/25.
//

import Foundation
import FirebaseAuth
import RxSwift

final class FirebaseAuthService {

    static let shared = FirebaseAuthService()

    private init() {}

    // MARK: - 이메일/비밀번호 회원가입

    func signUp(email: String, password: String) -> Observable<String> {
        return Observable.create { observer in
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    observer.onError(error)
                    return
                }

                guard let user = authResult?.user else {
                    observer.onError(NSError(domain: "FirebaseAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "User is nil"]))
                    return
                }

                // Firebase ID Token 가져오기
                user.getIDToken { token, error in
                    if let error = error {
                        observer.onError(error)
                        return
                    }

                    guard let token = token else {
                        observer.onError(NSError(domain: "FirebaseAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Token is nil"]))
                        return
                    }

                    observer.onNext(token)
                    observer.onCompleted()
                }
            }

            return Disposables.create()
        }
    }

    // MARK: - 이메일/비밀번호 로그인

    func signIn(email: String, password: String) -> Observable<String> {
        return Observable.create { observer in
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    observer.onError(error)
                    return
                }

                guard let user = authResult?.user else {
                    observer.onError(NSError(domain: "FirebaseAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "User is nil"]))
                    return
                }

                // Firebase ID Token 가져오기
                user.getIDToken { token, error in
                    if let error = error {
                        observer.onError(error)
                        return
                    }

                    guard let token = token else {
                        observer.onError(NSError(domain: "FirebaseAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Token is nil"]))
                        return
                    }

                    print("🔑 Firebase Token: \(token)")
                    observer.onNext(token)
                    observer.onCompleted()
                }
            }

            return Disposables.create()
        }
    }

    // MARK: - 현재 Firebase Token 가져오기

    func getCurrentUserToken() -> Observable<String> {
        return Observable.create { observer in
            guard let user = Auth.auth().currentUser else {
                observer.onError(NSError(domain: "FirebaseAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user signed in"]))
                return Disposables.create()
            }

            user.getIDToken { token, error in
                if let error = error {
                    observer.onError(error)
                    return
                }

                guard let token = token else {
                    observer.onError(NSError(domain: "FirebaseAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Token is nil"]))
                    return
                }

                observer.onNext(token)
                observer.onCompleted()
            }

            return Disposables.create()
        }
    }

    // MARK: - 로그아웃

    func signOut() -> Observable<Void> {
        return Observable.create { observer in
            do {
                try Auth.auth().signOut()
                observer.onNext(())
                observer.onCompleted()
            } catch {
                observer.onError(error)
            }

            return Disposables.create()
        }
    }

    // MARK: - 현재 로그인된 유저

    var currentUser: FirebaseAuth.User? {
        return Auth.auth().currentUser
    }

    var isSignedIn: Bool {
        return Auth.auth().currentUser != nil
    }
}
