//
//  APIEndpoint.swift
//  KIDK
//
//  Created by KIDK on 11/27/25.
//

import Foundation

protocol APIEndpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: [String: Any]? { get }
    var headers: [String: String]? { get }
    var requiresAuth: Bool { get }
}

extension APIEndpoint {
    var headers: [String: String]? {
        return nil
    }

    var requiresAuth: Bool {
        return true
    }
}
