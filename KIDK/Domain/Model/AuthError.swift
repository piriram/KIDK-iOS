//
//  AuthError.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/14/25.
//

import Foundation

enum AuthError: Error {
    case sessionSaveFailed
    case sessionClearFailed
    case unknown
}
