//
//  BaseRepository.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/14/25.
//

import Foundation
import RxSwift
import RealmSwift

class BaseRepository {

    let disposeBag = DisposeBag()
    let networkService: NetworkService
    let tokenManager: TokenManager

    init(
        networkService: NetworkService = .shared,
        tokenManager: TokenManager = .shared
    ) {
        self.networkService = networkService
        self.tokenManager = tokenManager
        logLifecycle("init")
        #if DEBUG
        if let realmURL = try? Realm().configuration.fileURL {
            print("📂 Realm file path: \(realmURL.absoluteString)")
        }
        #endif
    }
    
    deinit {
        logLifecycle("deinit")
    }
    
    func handleError<T>(_ error: Error) -> Observable<T> {
        debugError("Repository error occurred", error: error)
        return .error(mapError(error))
    }
    
    private func mapError(_ error: Error) -> RepositoryError {
        if let repositoryError = error as? RepositoryError {
            return repositoryError
        }
        
        return .unknown(error)
    }
    
    private func logLifecycle(_ method: String) {
        #if DEBUG
        debugLog("[\(String(describing: type(of: self)))] \(method)")
        #endif
    }
    
    func debugLog(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
        let fileName = (file as NSString).lastPathComponent
        print("🐛 [\(fileName):\(line)] \(function) - \(message)")
        #endif
    }
    
    func debugSuccess(_ message: String) {
        #if DEBUG
        print("✅ \(message)")
        #endif
    }
    
    func debugError(_ message: String, error: Error? = nil) {
        #if DEBUG
        if let error = error {
            print("❌ \(message): \(error.localizedDescription)")
        } else {
            print("❌ \(message)")
        }
        #endif
    }
    
    func debugWarning(_ message: String) {
        #if DEBUG
        print("⚠️ \(message)")
        #endif
    }
}

enum RepositoryError: Error {
    case networkError(Error)
    case decodingError(Error)
    case notFound
    case unauthorized
    case serverError
    case insufficientBalance
    case unknown(Error)

    var localizedDescription: String {
        switch self {
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .notFound:
            return "Resource not found"
        case .unauthorized:
            return "Unauthorized access"
        case .serverError:
            return "Server error occurred"
        case .insufficientBalance:
            return "Insufficient balance"
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}
