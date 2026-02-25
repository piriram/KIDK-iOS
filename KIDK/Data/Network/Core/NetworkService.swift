import Foundation
import RxSwift

final class NetworkService {

    static let shared = NetworkService()

    private let session: URLSession
    private let interceptor: RequestInterceptor
    private let environment: Environment
    private let tokenManager = TokenManager.shared

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

            guard let initialRequest = self.makeRequest(endpoint: endpoint) else {
                observer.onNext(.failure(.invalidURL))
                observer.onCompleted()
                return Disposables.create()
            }

            var currentTask: URLSessionDataTask?

            func execute(_ request: URLRequest, retryAllowed: Bool) {
                currentTask = self.session.dataTask(with: request) { data, response, error in
                    if let networkError = self.mapTransportError(error) {
                        observer.onNext(.failure(networkError))
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

                    let result: Result<T, NetworkError> = self.parseResponse(data: data, response: httpResponse)

                    if retryAllowed,
                       case .failure(.unauthorized(_, _)) = result,
                       endpoint.requiresAuth,
                       !endpoint.usesRefreshToken {
                        self.refreshAccessToken { success in
                            guard success, let retryRequest = self.makeRequest(endpoint: endpoint) else {
                                observer.onNext(result)
                                observer.onCompleted()
                                return
                            }
                            execute(retryRequest, retryAllowed: false)
                        }
                        return
                    }

                    observer.onNext(result)
                    observer.onCompleted()
                }

                currentTask?.resume()
            }

            execute(initialRequest, retryAllowed: true)

            return Disposables.create {
                currentTask?.cancel()
            }
        }
    }

    // MARK: - Async/Await API

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

    // MARK: - Private helpers

    private func makeRequest(endpoint: APIEndpoint) -> URLRequest? {
        guard let url = buildURL(endpoint: endpoint) else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue

        if let parameters = endpoint.parameters {
            let encoding: ParameterEncoding
            switch endpoint.parameterEncoding {
            case .methodDependent:
                encoding = (endpoint.method == .get || endpoint.method == .delete) ? .query : .jsonBody
            case .query:
                encoding = .query
            case .jsonBody:
                encoding = .jsonBody
            }

            switch encoding {
            case .query:
                if var components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                    components.queryItems = parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
                    if let updatedURL = components.url {
                        request.url = updatedURL
                    }
                }
            case .jsonBody:
                request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
            case .methodDependent:
                break
            }
        }

        request = interceptor.adapt(request, endpoint: endpoint)
        endpoint.headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        return request
    }

    private func parseResponse<T: Decodable>(data: Data?, response: HTTPURLResponse) -> Result<T, NetworkError> {
        guard let data = data else {
            return .failure(.unknown(nil))
        }

        do {
            let apiResponse = try JSONDecoder().decode(ApiResponse<T>.self, from: data)

            if apiResponse.success, let payload = apiResponse.data {
                return .success(payload)
            }

            let code = apiResponse.error?.code
            let message = apiResponse.error?.message

            switch response.statusCode {
            case 401:
                return .failure(.unauthorized(code: code, message: message))
            case 403:
                return .failure(.forbidden(code: code, message: message))
            case 404:
                return .failure(.notFound(code: code, message: message))
            case 500...599:
                return .failure(.serverError(statusCode: response.statusCode, code: code, message: message))
            default:
                return .failure(.apiError(code: code ?? "UNKNOWN", message: message ?? "API 요청에 실패했습니다."))
            }
        } catch {
            #if DEBUG
            print("⚠️ [Decoding Error] \(error)")
            #endif
            return .failure(.decodingFailed(error))
        }
    }

    private func mapTransportError(_ error: Error?) -> NetworkError? {
        guard let error = error else { return nil }

        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain {
            switch nsError.code {
            case NSURLErrorNotConnectedToInternet, NSURLErrorNetworkConnectionLost:
                return .noInternetConnection
            case NSURLErrorTimedOut:
                return .timeout
            default:
                return .unknown(error)
            }
        }

        return .unknown(error)
    }

    private func refreshAccessToken(completion: @escaping (Bool) -> Void) {
        guard tokenManager.refreshToken != nil,
              let request = makeRequest(endpoint: AuthAPI.refreshToken) else {
            completion(false)
            return
        }

        session.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self,
                  error == nil,
                  let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode),
                  let data = data,
                  let apiResponse = try? JSONDecoder().decode(ApiResponse<LoginResponseData>.self, from: data),
                  apiResponse.success,
                  let loginData = apiResponse.data else {
                completion(false)
                return
            }

            self.tokenManager.saveAccessToken(loginData.accessToken)
            self.tokenManager.saveRefreshToken(loginData.refreshToken)
            completion(true)
        }.resume()
    }

    private func buildURL(endpoint: APIEndpoint) -> URL? {
        let urlString = environment.baseURL + endpoint.path
        print("custom: urlString -  \(urlString)")
        return URL(string: urlString)
    }
}
