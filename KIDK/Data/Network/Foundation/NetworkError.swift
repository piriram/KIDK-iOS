//
//  NetworkError.swift
//  KIDK
//
//  Created by KIDK on 11/27/25.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case noInternetConnection
    case timeout
    case unauthorized(code: String?, message: String?)
    case forbidden(code: String?, message: String?)
    case notFound(code: String?, message: String?)
    case serverError(statusCode: Int, code: String?, message: String?)
    case apiError(code: String, message: String)  // 백엔드 API 에러
    case decodingFailed(Error)
    case encodingFailed(Error)
    case unknown(Error?)

    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "잘못된 URL입니다."
        case .noInternetConnection:
            return "인터넷 연결을 확인해주세요."
        case .timeout:
            return "요청 시간이 초과되었습니다."
        case .unauthorized(_, let message):
            return message ?? "인증이 필요합니다. 다시 로그인해주세요."
        case .forbidden(_, let message):
            return message ?? "접근 권한이 없습니다."
        case .notFound(_, let message):
            return message ?? "요청한 리소스를 찾을 수 없습니다."
        case .serverError(let statusCode, _, let message):
            return message ?? "서버 오류가 발생했습니다. (코드: \(statusCode))"
        case .apiError(_, let message):
            return message
        case .decodingFailed:
            return "데이터 처리 중 오류가 발생했습니다."
        case .encodingFailed:
            return "요청 데이터 생성 중 오류가 발생했습니다."
        case .unknown:
            return "알 수 없는 오류가 발생했습니다."
        }
    }

    /// 에러 코드 추출 (에러 분기 처리용)
    var errorCode: String? {
        switch self {
        case .unauthorized(let code, _),
             .forbidden(let code, _),
             .notFound(let code, _),
             .serverError(_, let code, _):
            return code
        case .apiError(let code, _):
            return code
        default:
            return nil
        }
    }

    /// 특정 에러 코드인지 확인
    func isErrorCode(_ code: String) -> Bool {
        return errorCode == code
    }

    /// 인증 관련 에러인지 확인 (AUTH_***)
    var isAuthError: Bool {
        guard let code = errorCode else { return false }
        return code.hasPrefix("AUTH_")
    }
}
