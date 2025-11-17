//
//  RepositoryProtocol.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/13/25.
//

import Foundation
import RxSwift

protocol RepositoryProtocol {
    associatedtype DataType
    associatedtype ErrorType: Error
}
