import Foundation
import RxSwift
import RealmSwift

class BaseRepository {

    let disposeBag = DisposeBag()
    let networkService: NetworkService
    let tokenManager: TokenManager
    private let authInterceptor = AuthRequestInterceptor()

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

    func applyAuthHeader(to request: URLRequest, usesRefreshToken: Bool = false) -> URLRequest {
        authInterceptor.applyAuthHeader(to: request, usesRefreshToken: usesRefreshToken)
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

enum RepositoryError: Error, LocalizedError {
    case networkError(Error)
    case decodingError(Error)
    case notFound
    case unauthorized
    case serverError
    case insufficientBalance
    case invalidParameter
    case deferredInMVP(feature: String)
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return error.localizedDescription
        case .decodingError:
            return "데이터 처리 중 오류가 발생했습니다."
        case .notFound:
            return "요청한 정보를 찾을 수 없습니다."
        case .unauthorized:
            return "인증이 필요합니다. 다시 로그인해주세요."
        case .serverError:
            return "서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요."
        case .insufficientBalance:
            return "잔액이 부족합니다."
        case .invalidParameter:
            return "요청 값이 올바르지 않습니다."
        case .deferredInMVP(let feature):
            return "\(feature)은(는) 현재 MVP 범위에서 보류된 기능입니다."
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}
