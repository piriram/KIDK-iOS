//
//  AsyncNetworkExample.swift
//  KIDK
//
//  async/await 기반 네트워크 요청 예시
//  Actor와 함께 사용하는 패턴 데모
//

import Foundation

/// async/await NetworkService 사용 예시
/// - Actor 내부에서 네트워크 호출
/// - SwiftUI ViewModel에서 사용 가능한 패턴
actor NetworkExampleService {

    private let networkService: NetworkService

    init(networkService: NetworkService = .shared) {
        self.networkService = networkService
    }

    // MARK: - Example 1: 단순 조회

    /// 사용자 프로필 조회 (async/await 방식)
    func fetchUserProfile() async throws -> User {
        let response: ApiResponseUserResponse = try await networkService.request(UserAPI.getMyProfile)

        guard let userData = response.data else {
            throw NetworkError.unknown(nil)
        }

        return userData.toDomain()
    }

    // MARK: - Example 2: 여러 API 순차 호출

    /// 사용자 정보와 계좌 정보를 순차적으로 조회
    func fetchUserWithAccounts() async throws -> (User, [Account]) {
        // 1. 사용자 정보 조회
        let userResponse: ApiResponseUserResponse = try await networkService.request(UserAPI.getMyProfile)
        guard let userData = userResponse.data else {
            throw NetworkError.unknown(nil)
        }
        let user = userData.toDomain()

        // 2. 계좌 정보 조회 (userId 사용)
        guard let userId = Int(user.id) else {
            throw NetworkError.unknown(nil)
        }

        let accountsResponse: ApiResponseAccountList = try await networkService.request(
            AccountAPI.getUserAccounts(userId: userId)
        )
        let accounts = accountsResponse.data?.map { $0.toDomain() } ?? []

        return (user, accounts)
    }

    // MARK: - Example 3: 병렬 API 호출

    /// 여러 API를 동시에 호출하고 결과를 조합
    func fetchDashboardData() async throws -> DashboardData {
        async let userTask: ApiResponseUserResponse = networkService.request(UserAPI.getMyProfile)
        async let accountsTask: ApiResponseAccountList = networkService.request(
            AccountAPI.getUserAccounts(userId: 1) // 실제로는 userId 필요
        )

        // 두 API가 모두 완료될 때까지 대기
        let (userResponse, accountsResponse) = try await (userTask, accountsTask)

        guard let userData = userResponse.data else {
            throw NetworkError.unknown(nil)
        }

        return DashboardData(
            user: userData.toDomain(),
            accounts: accountsResponse.data?.map { $0.toDomain() } ?? []
        )
    }

    // MARK: - Example 4: 에러 처리

    /// NetworkError를 적절히 처리하는 패턴
    func fetchUserProfileWithErrorHandling() async -> Result<User, NetworkError> {
        do {
            let response: ApiResponseUserResponse = try await networkService.request(UserAPI.getMyProfile)

            guard let userData = response.data else {
                return .failure(.decodingFailed(NSError(domain: "AsyncNetworkExample", code: -1, userInfo: [NSLocalizedDescriptionKey: "응답 데이터가 없습니다"])))
            }

            return .success(userData.toDomain())

        } catch let error as NetworkError {
            return .failure(error)
        } catch {
            return .failure(.unknown(error))
        }
    }
}

// MARK: - Dashboard Data Model

struct DashboardData {
    let user: User
    let accounts: [Account]
}

// MARK: - SwiftUI ViewModel 사용 예시 (주석)

/*
 ## SwiftUI에서 사용하는 방법

 ```swift
 @Observable
 final class DashboardViewModel {
     var user: User?
     var accounts: [Account] = []
     var isLoading = false
     var errorMessage: String?

     private let service = NetworkExampleService()

     func loadDashboard() async {
         isLoading = true
         defer { isLoading = false }

         do {
             let data = try await service.fetchDashboardData()
             user = data.user
             accounts = data.accounts
         } catch {
             errorMessage = error.localizedDescription
         }
     }
 }

 // View
 struct DashboardView: View {
     @State private var viewModel = DashboardViewModel()

     var body: some View {
         VStack {
             if viewModel.isLoading {
                 ProgressView()
             } else {
                 // UI 표시
             }
         }
         .task {
             await viewModel.loadDashboard()
         }
     }
 }
 ```

 ## UIKit에서 사용하는 방법 (현재 프로젝트)

 ```swift
 class SomeViewController: UIViewController {
     private let service = NetworkExampleService()

     override func viewDidLoad() {
         super.viewDidLoad()
         loadData()
     }

     private func loadData() {
         Task {
             do {
                 let user = try await service.fetchUserProfile()
                 await MainActor.run {
                     // UI 업데이트
                     print("User loaded: \(user.name)")
                 }
             } catch {
                 await MainActor.run {
                     // 에러 표시
                     print("Error: \(error)")
                 }
             }
         }
     }
 }
 ```

 ## 장점

 1. **가독성**: 순차적인 코드 흐름
 2. **간결함**: Callback이나 RxSwift 체이닝보다 짧음
 3. **타입 안전**: async throws로 명확한 에러 타입
 4. **Actor 통합**: Thread-safe한 상태 관리
 5. **병렬 처리**: async let으로 쉬운 병렬 요청

 ## RxSwift vs async/await 선택 기준

 | 상황 | 권장 방식 | 이유 |
 |------|----------|------|
 | Repository 계층 | RxSwift | 기존 인프라 활용 |
 | ViewModel (UIKit) | RxSwift | UI 바인딩 용이 |
 | Actor 내부 | async/await | 자연스러운 통합 |
 | SwiftUI | async/await | @Observable과 궁합 |
 | 단순 API 호출 | async/await | 간결한 코드 |
 | 복잡한 스트림 조합 | RxSwift | Operator 활용 |
 */
