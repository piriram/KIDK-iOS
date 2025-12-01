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
}
