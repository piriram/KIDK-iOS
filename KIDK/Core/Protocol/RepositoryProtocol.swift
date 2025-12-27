import Foundation
import RxSwift

protocol RepositoryProtocol {
    associatedtype DataType
    associatedtype ErrorType: Error
}
