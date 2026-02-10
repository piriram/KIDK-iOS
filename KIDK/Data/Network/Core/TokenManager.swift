//
//  TokenManager.swift
//  KIDK
//
//  Created by KIDK on 11/27/25.
//

import Foundation

final class TokenManager {

    static let shared = TokenManager()

    private init() {}

    private let keychain = KeychainWrapper.shared
    private let accessTokenKey = "KIDK_ACCESS_TOKEN"
    private let refreshTokenKey = "KIDK_REFRESH_TOKEN"

    // MARK: - Access Token

    var accessToken: String? {
        return try? keychain.load(key: accessTokenKey)
    }

    func saveAccessToken(_ token: String) {
        try? keychain.save(key: accessTokenKey, value: token)
    }

    func deleteAccessToken() {
        try? keychain.delete(key: accessTokenKey)
    }

    // MARK: - Refresh Token

    var refreshToken: String? {
        return try? keychain.load(key: refreshTokenKey)
    }

    func saveRefreshToken(_ token: String) {
        try? keychain.save(key: refreshTokenKey, value: token)
    }

    func deleteRefreshToken() {
        try? keychain.delete(key: refreshTokenKey)
    }

    // MARK: - Clear All Tokens

    func clearAllTokens() {
        deleteAccessToken()
        deleteRefreshToken()
    }

    // MARK: - Token Validation

    var isLoggedIn: Bool {
        return accessToken != nil
    }
}
