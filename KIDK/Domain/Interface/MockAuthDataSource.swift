//
//  MockAuthDataSource.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/13/25.
//

import Foundation
import RxSwift

final class MockAuthDataSource {
    
    func generateMockFirebaseUID() -> String {
        return "mock_" + UUID().uuidString
    }
    
    func createMockUser(firebaseUID: String, userType: UserType) -> User {
        let userName = userType == .child ? "Mock Child" : "Mock Parent"
        
        return User(
            id: UUID().uuidString,
            firebaseUID: firebaseUID,
            userType: userType,
            name: userName,
            nickname: nil,
            profileImageURL: nil,
            birthdate: userType == .child ? createChildBirthdate() : nil,
            status: .active,
            createdAt: Date(),
            lastLoginAt: Date()
        )
    }
    
    private func createChildBirthdate() -> Date {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let childAge = Int.random(in: 8...12)
        let birthYear = currentYear - childAge
        
        var components = DateComponents()
        components.year = birthYear
        components.month = Int.random(in: 1...12)
        components.day = Int.random(in: 1...28)
        
        return calendar.date(from: components) ?? Date()
    }
}
