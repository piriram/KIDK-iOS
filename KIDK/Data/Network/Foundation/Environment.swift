import Foundation

enum Environment {
    case development
    case production

    static var current: Environment {
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }

    var baseURL: String {
        switch self {
        case .development:
            return SecretsManager.shared.apiBaseURLDev
        case .production:
            return SecretsManager.shared.apiBaseURLProd
        }
    }

    var swaggerURL: String? {
        switch self {
        case .development:
            return SecretsManager.shared.swaggerURLDev
        case .production:
            return nil
        }
    }

    var useMockMissionData: Bool {
        switch self {
        case .development:
            return true  // 개발 환경에서는 목업 데이터 사용
        case .production:
            return true  // TestFlight 데모용: 프로덕션에서도 목업 미션 데이터 사용
        }
    }
}
