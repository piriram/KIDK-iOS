import Foundation

/// 앱의 빌드 환경 설정
/// - Development: 개발/테스트용 빌드
/// - Production: 실제 배포용 빌드
enum AppConfiguration {

    // MARK: - Current Configuration

    /// 현재 빌드 환경
    static var current: BuildEnvironment {
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }

    // MARK: - Build Environment

    enum BuildEnvironment {
        case development
        case production

        var displayName: String {
            switch self {
            case .development: return "개발"
            case .production: return "운영"
            }
        }

        var bundleIdentifierSuffix: String {
            switch self {
            case .development: return ".dev"
            case .production: return ""
            }
        }

        var appName: String {
            switch self {
            case .development: return "KIDK-DEV"
            case .production: return "KIDK"
            }
        }
    }

    // MARK: - Feature Flags

    /// Mock 데이터 사용 여부
    static var useMockData: Bool {
        switch current {
        case .development: return true  // 개발 중에는 Mock 데이터 사용 가능
        case .production: return false  // 운영에서는 무조건 실제 API
        }
    }

    /// 상세 로깅 활성화 여부
    static var isLoggingEnabled: Bool {
        switch current {
        case .development: return true  // 개발: 모든 로그 출력
        case .production: return false  // 운영: 에러 로그만
        }
    }

    /// 개발자 메뉴 표시 여부 (Settings 화면의 개발용 버튼들)
    static var showDeveloperMenu: Bool {
        switch current {
        case .development: return true
        case .production: return false
        }
    }

    /// Swagger UI 사용 가능 여부
    static var isSwaggerEnabled: Bool {
        switch current {
        case .development: return true
        case .production: return false
        }
    }

    // MARK: - API Configuration

    /// API 베이스 URL
    static var apiBaseURL: String {
        return Environment.current.baseURL
    }

    /// API 타임아웃 (초)
    static var apiTimeout: TimeInterval {
        switch current {
        case .development: return 30.0  // 개발: 길게
        case .production: return 15.0   // 운영: 짧게
        }
    }

    // MARK: - Debug Info

    /// 현재 설정 정보 출력 (디버그용)
    static func printConfiguration() {
        #if DEBUG
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📱 KIDK App Configuration")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("🏗️  Environment: \(current.displayName)")
        print("🌐 API Base URL: \(apiBaseURL)")
        print("⏱️  API Timeout: \(apiTimeout)s")
        print("🧪 Mock Data: \(useMockData ? "Enabled" : "Disabled")")
        print("📊 Logging: \(isLoggingEnabled ? "Enabled" : "Disabled")")
        print("🔧 Developer Menu: \(showDeveloperMenu ? "Visible" : "Hidden")")
        print("📖 Swagger: \(isSwaggerEnabled ? "Enabled" : "Disabled")")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        #endif
    }
}
