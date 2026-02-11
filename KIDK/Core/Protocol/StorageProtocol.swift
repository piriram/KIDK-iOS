//
//  StorageProtocol.swift
//  KIDK
//
//  Generic + Protocol을 활용한 Storage 추상화
//  - 다양한 Storage 구현체 지원 (UserDefaults, Keychain, File 등)
//  - Generic을 통한 타입 안정성
//  - Protocol을 통한 의존성 역전 (Dependency Inversion)
//

import Foundation

/// Generic Storage Protocol
/// - Parameter T: 저장할 데이터 타입
protocol StorageProtocol {
    associatedtype T

    func save(_ value: T, forKey key: String) throws
    func load(forKey key: String) throws -> T?
    func delete(forKey key: String) throws
    func exists(forKey key: String) -> Bool
}

// MARK: - UserDefaults Storage Implementation

final class UserDefaultsStorage<T>: StorageProtocol {

    private let storage: UserDefaults

    init(storage: UserDefaults = .standard) {
        self.storage = storage
    }

    func save(_ value: T, forKey key: String) throws {
        storage.set(value, forKey: key)
    }

    func load(forKey key: String) throws -> T? {
        return storage.object(forKey: key) as? T
    }

    func delete(forKey key: String) throws {
        storage.removeObject(forKey: key)
    }

    func exists(forKey key: String) -> Bool {
        return storage.object(forKey: key) != nil
    }
}

// MARK: - Keychain Storage Implementation

final class KeychainStorage: StorageProtocol {
    typealias T = String

    private let wrapper: KeychainWrapper

    init(wrapper: KeychainWrapper = .shared) {
        self.wrapper = wrapper
    }

    func save(_ value: String, forKey key: String) throws {
        try wrapper.save(key: key, value: value)
    }

    func load(forKey key: String) throws -> String? {
        return try? wrapper.load(key: key)
    }

    func delete(forKey key: String) throws {
        try wrapper.delete(key: key)
    }

    func exists(forKey key: String) -> Bool {
        return (try? wrapper.load(key: key)) != nil
    }
}

// MARK: - Codable Storage (JSON 파일 저장)

final class CodableStorage<T: Codable>: StorageProtocol {

    private let fileManager: FileManager
    private let directory: FileManager.SearchPathDirectory

    init(
        fileManager: FileManager = .default,
        directory: FileManager.SearchPathDirectory = .documentDirectory
    ) {
        self.fileManager = fileManager
        self.directory = directory
    }

    func save(_ value: T, forKey key: String) throws {
        let url = try getURL(forKey: key)
        let data = try JSONEncoder().encode(value)
        try data.write(to: url)
    }

    func load(forKey key: String) throws -> T? {
        let url = try getURL(forKey: key)
        guard fileManager.fileExists(atPath: url.path) else {
            return nil
        }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(T.self, from: data)
    }

    func delete(forKey key: String) throws {
        let url = try getURL(forKey: key)
        if fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
        }
    }

    func exists(forKey key: String) -> Bool {
        guard let url = try? getURL(forKey: key) else { return false }
        return fileManager.fileExists(atPath: url.path)
    }

    private func getURL(forKey key: String) throws -> URL {
        let paths = fileManager.urls(for: directory, in: .userDomainMask)
        guard let documentDirectory = paths.first else {
            throw NSError(domain: "CodableStorage", code: -1, userInfo: [NSLocalizedDescriptionKey: "Document directory not found"])
        }
        return documentDirectory.appendingPathComponent("\(key).json")
    }
}

// MARK: - Generic Storage Manager

final class GenericStorageManager<T, Storage: StorageProtocol> where Storage.T == T {

    private let storage: Storage
    private let key: String

    init(storage: Storage, key: String) {
        self.storage = storage
        self.key = key
    }

    var value: T? {
        get { try? storage.load(forKey: key) }
        set {
            if let newValue = newValue {
                try? storage.save(newValue, forKey: key)
            } else {
                try? storage.delete(forKey: key)
            }
        }
    }

    func save(_ value: T) throws {
        try storage.save(value, forKey: key)
    }

    func load() throws -> T? {
        try storage.load(forKey: key)
    }

    func delete() throws {
        try storage.delete(forKey: key)
    }

    func exists() -> Bool {
        storage.exists(forKey: key)
    }
}

// MARK: - 사용 예시 (주석)
/*
 // 1. UserDefaults로 String 저장
 let stringStorage = GenericStorageManager(
     storage: UserDefaultsStorage<String>(),
     key: "username"
 )
 stringStorage.value = "김철수"
 print(stringStorage.value) // Optional("김철수")

 // 2. Keychain으로 Token 저장
 let tokenStorage = GenericStorageManager(
     storage: KeychainStorage(),
     key: "accessToken"
 )
 try? tokenStorage.save("secret_token")

 // 3. Codable 객체를 JSON 파일로 저장
 struct UserProfile: Codable {
     let name: String
     let age: Int
 }

 let profileStorage = GenericStorageManager(
     storage: CodableStorage<UserProfile>(),
     key: "userProfile"
 )
 let profile = UserProfile(name: "김철수", age: 25)
 try? profileStorage.save(profile)

 // 이력서 어필 포인트:
 // 1. Generic을 활용한 타입 안정성과 재사용성
 // 2. Protocol을 통한 의존성 역전 (SOLID 원칙)
 // 3. 다양한 Storage 구현체 지원 (확장 가능한 설계)
 // 4. Codable 지원으로 복잡한 객체도 쉽게 저장
 */
