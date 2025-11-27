//
//  Environment.swift
//  KIDK
//
//  Created by KIDK on 11/27/25.
//

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
            return "http://43.202.165.98:8080/api/v1"
        case .production:
            return "https://api.kidk.com/api/v1" // TODO: 실제 프로덕션 URL로 변경
        }
    }

    var swaggerURL: String? {
        switch self {
        case .development:
            return "http://43.202.165.98:8080/swagger-ui/index.html"
        case .production:
            return nil
        }
    }
}
