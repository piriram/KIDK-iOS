import Foundation
import RxSwift

protocol DataSourceProtocol {
    associatedtype DataType
    associatedtype ErrorType: Error
}

protocol MockDataSourceProtocol: DataSourceProtocol {
    func fetchMockData() -> Observable<DataType>
}

protocol LocalDataSourceProtocol: DataSourceProtocol {
    func fetch() -> Observable<DataType>
    func save(_ data: DataType) -> Observable<Void>
    func delete() -> Observable<Void>
}

protocol RemoteDataSourceProtocol: DataSourceProtocol {
    func fetch() -> Observable<DataType>
    func create(_ data: DataType) -> Observable<DataType>
    func update(_ data: DataType) -> Observable<DataType>
    func delete(id: String) -> Observable<Void>
}
