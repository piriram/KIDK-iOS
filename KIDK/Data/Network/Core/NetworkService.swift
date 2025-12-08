//
//  NetworkService.swift
//  KIDK
//
//  Created by KIDK on 11/27/25.
//

import Foundation
import RxSwift

final class NetworkService {

    static let shared = NetworkService()

    private let session: URLSession
    private let interceptor: RequestInterceptor
    private let environment: Environment

    init(
        session: URLSession = .shared,
        interceptor: RequestInterceptor = AuthRequestInterceptor(),
        environment: Environment = .current
    ) {
        self.session = session
        self.interceptor = interceptor
        self.environment = environment
    }

    // MARK: - Request with Result Type

    func request<T: Decodable>(_ endpoint: APIEndpoint) -> Observable<Result<T, NetworkError>> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onNext(.failure(.unknown(nil)))
                observer.onCompleted()
                return Disposables.create()
            }

            guard let url = self.buildURL(endpoint: endpoint) else {
                observer.onNext(.failure(.invalidURL))
                observer.onCompleted()
                return Disposables.create()
            }

            var request = URLRequest(url: url)
            request.httpMethod = endpoint.method.rawValue

            // Body 설정
            if let parameters = endpoint.parameters {
                do {
                    #if DEBUG
                    // 파라미터 타입 검증
                    print("📋 [Parameter Types]")
                    for (key, value) in parameters {
                        print("  - \(key): \(type(of: value)) = \(value)")
                    }
                    #endif

                    request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
                } catch {
                    observer.onNext(.failure(.encodingFailed(error)))
                    observer.onCompleted()
                    return Disposables.create()
                }
            }

            // Interceptor를 통한 헤더 추가
            request = self.interceptor.adapt(request, endpoint: endpoint)

            // Custom 헤더 추가
            endpoint.headers?.forEach { key, value in
                request.setValue(value, forHTTPHeaderField: key)
            }

            let task = self.session.dataTask(with: request) { data, response, error in
                // 에러 체크
                if let error = error {
                    let nsError = error as NSError
                    if nsError.domain == NSURLErrorDomain {
                        switch nsError.code {
                        case NSURLErrorNotConnectedToInternet, NSURLErrorNetworkConnectionLost:
                            observer.onNext(.failure(.noInternetConnection))
                        case NSURLErrorTimedOut:
                            observer.onNext(.failure(.timeout))
                        default:
                            observer.onNext(.failure(.unknown(error)))
                        }
                    } else {
                        observer.onNext(.failure(.unknown(error)))
                    }
                    observer.onCompleted()
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    observer.onNext(.failure(.unknown(nil)))
                    observer.onCompleted()
                    return
                }

                #if DEBUG
                print("📥 [Response] Status Code: \(httpResponse.statusCode)")

                // Response Headers 출력 (500 에러 시 유용)
                if httpResponse.statusCode >= 400 {
                    print("📋 [Response Headers]")
                    for (key, value) in httpResponse.allHeaderFields {
                        print("  - \(key): \(value)")
                    }
                }

                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("📦 [Response Body] \(responseString)")
                }
                #endif

                guard let data = data else {
                    observer.onNext(.failure(.unknown(nil)))
                    observer.onCompleted()
                    return
                }

                // 백엔드 공통 응답 포맷 파싱
                do {
                    let apiResponse = try JSONDecoder().decode(ApiResponse<T>.self, from: data)

                    if apiResponse.success {
                        // ✅ 성공 응답
                        if let responseData = apiResponse.data {
                            observer.onNext(.success(responseData))
                        } else {
                            observer.onNext(.failure(.unknown(nil)))
                        }
                    } else {
                        // ❌ 실패 응답
                        if let errorInfo = apiResponse.error {
                            // 에러 코드별 분기 처리
                            let errorCode = errorInfo.code
                            let errorMessage = errorInfo.message

                            switch httpResponse.statusCode {
                            case 401:
                                observer.onNext(.failure(.unauthorized(code: errorCode, message: errorMessage)))
                            case 403:
                                observer.onNext(.failure(.forbidden(code: errorCode, message: errorMessage)))
                            case 404:
                                observer.onNext(.failure(.notFound(code: errorCode, message: errorMessage)))
                            case 500...599:
                                observer.onNext(.failure(.serverError(statusCode: httpResponse.statusCode, code: errorCode, message: errorMessage)))
                            default:
                                observer.onNext(.failure(.apiError(code: errorCode, message: errorMessage)))
                            }
                        } else {
                            observer.onNext(.failure(.unknown(nil)))
                        }
                    }
                    observer.onCompleted()
                } catch {
                    #if DEBUG
                    print("⚠️ [Decoding Error] \(error)")
                    #endif
                    observer.onNext(.failure(.decodingFailed(error)))
                    observer.onCompleted()
                }
            }

            task.resume()

            return Disposables.create {
                task.cancel()
            }
        }
    }

    // MARK: - Async/Await API

    /// async/await 기반 네트워크 요청
    /// - Parameter endpoint: API 엔드포인트
    /// - Returns: 디코딩된 응답 데이터
    /// - Throws: NetworkError
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            self.request(endpoint)
                .subscribe(onNext: { (result: Result<T, NetworkError>) in
                    switch result {
                    case .success(let data):
                        continuation.resume(returning: data)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                })
                .dispose()
        }
    }

    // MARK: - Helper Methods

    private func buildURL(endpoint: APIEndpoint) -> URL? {
        let urlString = environment.baseURL + endpoint.path
        print("custom: urlString -  \(urlString)")
        return URL(string: urlString)
    }
}

// MARK: - Usage Examples

/*
 ## NetworkService 사용 예시

 ### 1. RxSwift 방식 (기존)
 ```swift
 networkService.request(UserAPI.getMyProfile)
     .subscribe(onNext: { result in
         switch result {
         case .success(let response):
             // 성공 처리
         case .failure(let error):
             // 에러 처리
         }
     })
     .disposed(by: disposeBag)
 ```

 ### 2. async/await 방식 (신규)
 ```swift
 Task {
     do {
         let response: ApiResponseUserResponse = try await networkService.request(UserAPI.getMyProfile)
         // 성공 처리
     } catch let error as NetworkError {
         // NetworkError 타입으로 에러 처리
         switch error {
         case .unauthorized:
             // 인증 에러
         case .serverError(let statusCode, let message):
             // 서버 에러
         default:
             // 기타 에러
         }
     }
 }
 ```

 ## 언제 어떤 방식을 사용할까?

 ### RxSwift 사용 (권장)
 - Repository 레이어
 - ViewModel에서 여러 스트림 조합이 필요한 경우
 - 기존 RxSwift 기반 코드와 통합

 ### async/await 사용 (권장)
 - Actor 내부에서 네트워크 호출
 - SwiftUI ViewModel (@Observable)
 - 단순한 일회성 네트워크 호출

 ## 포트폴리오 어필 포인트
 - 두 가지 패러다임 모두 지원 가능
 - 기존 코드 수정 없이 확장성 제공
 - 레거시와 최신 기술의 공존
 */

