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
    case unauthorized(message: String?)
    case forbidden(message: String?)
    case notFound(message: String?)
    case serverError(statusCode: Int, message: String?)
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
        case .unauthorized(let message):
            return message ?? "인증이 필요합니다. 다시 로그인해주세요."
        case .forbidden(let message):
            return message ?? "접근 권한이 없습니다."
        case .notFound(let message):
            return message ?? "요청한 리소스를 찾을 수 없습니다."
        case .serverError(let statusCode, let message):
            return message ?? "서버 오류가 발생했습니다. (코드: \(statusCode))"
        case .decodingFailed:
            return "데이터 처리 중 오류가 발생했습니다."
        case .encodingFailed:
            return "요청 데이터 생성 중 오류가 발생했습니다."
        case .unknown:
            return "알 수 없는 오류가 발생했습니다."
        }
    }
}
