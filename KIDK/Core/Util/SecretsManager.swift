//
//  SecretsManager.swift
//  KIDK
//
//  민감 정보 관리
//  - Secrets.plist에서 API URL 등 민감 정보를 읽어옴
//  - Git에 노출되지 않음
//

import Foundation

final class SecretsManager {

    static let shared = SecretsManager()

    private var secrets: [String: Any]?

    private init() {
        loadSecrets()
    }

    private func loadSecrets() {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any] else {
            print("⚠️ Secrets.plist not found. Using default values.")
            return
        }
        secrets = dict
    }

    func getString(_ key: String, defaultValue: String = "") -> String {
        return secrets?[key] as? String ?? defaultValue
    }

    // MARK: - API URLs

    var apiBaseURLDev: String {
        return getString("API_BASE_URL_DEV", defaultValue: "http://localhost:8080/api/v1")
    }

    var apiBaseURLProd: String {
        return getString("API_BASE_URL_PROD", defaultValue: "https://YOUR_PROD_API_URL/api/v1")
    }

    var swaggerURLDev: String? {
        return getString("SWAGGER_URL_DEV")
    }
}
