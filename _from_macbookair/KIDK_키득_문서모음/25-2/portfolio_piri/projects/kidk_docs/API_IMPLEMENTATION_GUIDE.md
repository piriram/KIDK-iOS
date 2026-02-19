# API 구현 가이드 (Implementation Guide)

## 📁 프로젝트 구조 개요

```
KIDK/
├── Domain/              # 도메인 계층 (비즈니스 로직)
│   ├── Model/          # 도메인 모델 (Entity)
│   └── Interface/      # Repository Protocol 정의
├── Data/               # 데이터 계층 (외부 데이터 처리)
│   ├── Repository/     # Repository 구현체
│   ├── Network/
│   │   ├── API/       # API 엔드포인트 정의
│   │   └── DTO/       # 데이터 전송 객체
│   ├── Entity/        # 로컬 DB 엔티티 (Realm)
│   └── DataSource/    # Mock/Remote/Local DataSource
└── Presentation/       # 프레젠테이션 계층 (UI)
    ├── View/          # UIViewController
    ├── ViewModel/     # RxSwift ViewModel
    └── Coordinator/   # Navigation 관리
```

---

## 🔴 구현되지 않은 API 목록 및 구현 위치

### 1. User Controller (전체 미구현) ⚠️

**현재 상태**:
- ✅ `UserAPI.swift` 정의됨
- ✅ `UserResponse` DTO 존재 (`AuthDTO.swift`)
- ✅ `User` 도메인 모델 존재
- ❌ `UserRepositoryProtocol` 없음
- ❌ `UserRepository` 구현체 없음
- ⚠️ `UserProfileManager`가 로컬 관리만 수행 (API 통신 X)

#### 구현 필요 파일

| 파일 경로 | 역할 | 구현 내용 |
|---------|------|----------|
| `Domain/Interface/UserRepositoryProtocol.swift` | Repository 인터페이스 | User CRUD 메서드 정의 |
| `Data/Repository/UserRepository.swift` | Repository 구현체 | UserAPI 호출 및 UserProfileManager 연동 |

#### 구현할 API 목록

```swift
// UserRepositoryProtocol.swift
protocol UserRepositoryProtocol {
    /// GET /api/v1/users/me - 내 정보 조회
    func getMyProfile() -> Single<User>

    /// PUT /api/v1/users/me - 내 정보 수정
    func updateProfile(name: String, birthDate: Date?, phone: String?) -> Single<User>

    /// DELETE /api/v1/users/me - 내 계정 삭제
    func deleteAccount() -> Completable

    /// POST /api/v1/users/me/profile-image - 프로필 이미지 업로드
    func uploadProfileImage(imageData: Data) -> Single<String>

    /// PATCH /api/v1/users/me/status - 상태 변경
    func updateStatus(status: UserStatus) -> Completable

    /// GET /api/v1/users/{userId} - 특정 유저 조회
    func getUserProfile(userId: String) -> Single<User>
}
```

**연동 포인트**:
- `UserRepository` 구현 시 `UserProfileManager.shared`와 연동하여 로컬 캐시 동기화 필요
- AuthRepository 로그인 성공 시 `getMyProfile()` 호출하여 사용자 정보 갱신

**참고 구현**: `AuthRepository.swift` (로그인 구현 참조)

---

### 2. Account Controller (부분 미구현)

**현재 상태**:
- ✅ `AccountRepository.swift` 존재
- ✅ `AccountAPI.swift` 일부 정의됨
- ❌ 일부 API 미사용

#### 구현 필요 위치

| API | 현재 상태 | 구현 위치 | 작업 내용 |
|-----|----------|----------|----------|
| `GET /accounts/{accountId}` | API 정의만 존재 | `AccountRepository.swift:142` | `getAccount()` 메서드에서 실제 API 호출로 변경 |
| `GET /accounts/user/{userId}/active` | 미정의 | `AccountAPI.swift` + `AccountRepository.swift` | 새 API 추가 및 메서드 구현 |

#### 구현 예시

```swift
// AccountAPI.swift에 추가
case getAccount(accountId: Int, userId: Int)
case getActiveAccounts(userId: Int)

// AccountRepository.swift에 추가
func getActiveAccounts(userId: String) -> Single<[Account]> {
    // API 호출 로직
}
```

**참고 구현**: `AccountRepository.swift:39` (getAllAccounts 메서드 참조)

---

### 3. Mission Controller (부분 미구현)

**현재 상태**:
- ✅ `MissionRepository.swift` 존재
- ✅ `MissionAPI.swift` 정의됨
- ❌ 일부 API 미사용

#### 구현 필요 위치

| API | 현재 상태 | 구현 위치 | 작업 내용 |
|-----|----------|----------|----------|
| `PUT /missions/{missionId}/complete` | API 정의만 존재 | `MissionRepository.swift` | completeMission 메서드 추가 |
| `GET /missions/creator/{creatorId}` | API 정의만 존재 | `MissionRepository.swift` | fetchMissionsByCreator 메서드 추가 |

#### 구현 예시

```swift
// MissionRepository.swift에 추가
func completeMission(missionId: String) -> Single<Mission> {
    guard let missionIdInt = Int(missionId) else {
        return .error(RepositoryError.invalidParameter)
    }

    return networkService.request(MissionAPI.completeMission(missionId: missionIdInt))
        .map { (result: Result<MissionResponse, NetworkError>) -> Mission in
            switch result {
            case .success(let response):
                return response.toDomain()
            case .failure(let error):
                throw RepositoryError.networkError(error)
            }
        }
}
```

**참고 구현**: `MissionRepository.swift:18` (createMission 메서드 참조)

---

### 4. Mission Verification Controller (부분 미구현)

**현재 상태**:
- ✅ `MissionVerificationRepository.swift` 존재
- ❌ `MissionVerificationAPI.swift` 일부 정의 누락
- ❌ Mock 데이터로만 동작

#### 구현 필요 위치

| API | 현재 상태 | 구현 위치 | 작업 내용 |
|-----|----------|----------|----------|
| `GET /missions/{missionId}/verifications` | API 미정의 | `MissionVerificationAPI.swift` + Repository | 조회 API 추가 및 구현 |
| `POST /missions/{missionId}/verifications` | API 미정의 | `MissionVerificationAPI.swift` + Repository | 제출 API 추가 및 구현 |

#### 구현 필요 내용

**1. MissionVerificationAPI.swift에 추가**

```swift
// MissionVerificationAPI.swift
enum MissionVerificationAPI {
    case getVerifications(missionId: Int)
    case submitVerification(missionId: Int, childId: Int, verificationType: String, content: String?)
    case approveVerification(missionId: Int, verificationId: Int, parentId: Int)
    case rejectVerification(missionId: Int, verificationId: Int, parentId: Int, reason: String)
}
```

**2. MissionVerificationRepository.swift 수정**

현재 Mock으로만 동작하는 `submitVerification()`, `getVerifications()` 메서드를 실제 API 호출로 변경:

```swift
// 파일: MissionVerificationRepository.swift:117
func submitVerification(_ request: MissionVerificationRequest) -> Single<MissionVerification> {
    guard let missionIdInt = Int(request.missionId) else {
        return .error(RepositoryError.invalidParameter)
    }

    // 실제 API 호출
    return networkService.request(
        MissionVerificationAPI.submitVerification(
            missionId: missionIdInt,
            childId: /* userId */,
            verificationType: request.type.rawValue,
            content: request.content
        )
    ).map { /* DTO to Domain */ }
}
```

**참고 구현**: `MissionVerificationRepository.swift:183` (approveVerification - 이미 API 연동됨)

---

### 5. Mission Progress Controller (전체 미구현) ⚠️

**현재 상태**:
- ✅ `MissionAPI.swift`에 정의됨
- ✅ `MissionProgressResponse` DTO 존재
- ❌ Repository에서 전혀 사용되지 않음
- ❌ Domain Model 없음

#### 구현 필요 파일

| 파일 경로 | 역할 | 구현 내용 |
|---------|------|----------|
| `Domain/Model/MissionProgress.swift` | 도메인 모델 | 미션 진행도 모델 정의 |
| `Domain/Interface/MissionRepositoryProtocol.swift` | Protocol 확장 | 진행도 관련 메서드 추가 |
| `Data/Repository/MissionRepository.swift` | 구현 | 진행도 API 호출 로직 추가 |

#### 구현할 API 목록

```swift
// MissionRepositoryProtocol.swift에 추가
extension MissionRepositoryProtocol {
    /// GET /mission-progress/{missionId}
    func fetchMissionProgress(missionId: String) -> Single<[MissionProgress]>

    /// POST /mission-progress/{missionId}
    func updateMissionProgress(
        missionId: String,
        userId: String,
        progressAmount: Double?,
        progressPercentage: Double?
    ) -> Single<MissionProgress>

    /// GET /mission-progress/user/{userId}
    func fetchUserMissionProgress(userId: String) -> Single<[MissionProgress]>
}
```

#### 도메인 모델 정의

```swift
// Domain/Model/MissionProgress.swift (신규 생성)
struct MissionProgress {
    let id: String
    let missionId: String
    let userId: String
    let progressAmount: Double?
    let progressPercentage: Double?
    let lastActivityAt: Date
}
```

#### DTO 변환 추가

```swift
// MissionDTO.swift에 추가
extension MissionProgressResponse {
    func toDomain() -> MissionProgress {
        let dateFormatter = ISO8601DateFormatter()
        return MissionProgress(
            id: String(id),
            missionId: String(mission.id),
            userId: String(user.id),
            progressAmount: progressAmount,
            progressPercentage: progressPercentage,
            lastActivityAt: dateFormatter.date(from: lastActivityAt) ?? Date()
        )
    }
}
```

**참고 구현**: `MissionRepository.swift:217` (createMissionRaw - Raw API 호출 패턴 참조)

---

### 6. Savings Goal Controller (부분 미구현)

**현재 상태**:
- ✅ `SavingsRepository.swift` 존재
- ✅ `SavingsAPI.swift` 정의됨
- ❌ 단건 조회 미사용

#### 구현 필요 위치

| API | 현재 상태 | 구현 위치 | 작업 내용 |
|-----|----------|----------|----------|
| `GET /savings-goals/{goalId}` | API 정의만 존재 | `SavingsRepository.swift` | getSavingsGoal 메서드 추가 |

#### 구현 예시

```swift
// SavingsRepository.swift에 추가
func getSavingsGoal(goalId: String) -> Single<SavingsGoal> {
    guard let goalIdInt = Int(goalId) else {
        return .error(RepositoryError.invalidParameter)
    }

    return networkService.request(SavingsAPI.getSavingsGoal(goalId: goalIdInt))
        .map { (result: Result<SavingsResponse, NetworkError>) -> SavingsGoal in
            switch result {
            case .success(let response):
                return response.toDomain()
            case .failure(let error):
                throw RepositoryError.networkError(error)
            }
        }
}
```

**참고 구현**: `SavingsRepository.swift:43` (fetchSavingsGoals 메서드 참조)

---

### 7. Family Controller (부분 미구현)

**현재 상태**:
- ✅ `FamilyRepository.swift` 존재
- ✅ `FamilyAPI.swift` 정의됨
- ❌ 단건 조회 미사용

#### 구현 필요 위치

| API | 현재 상태 | 구현 위치 | 작업 내용 |
|-----|----------|----------|----------|
| `GET /families/{familyId}` | API 미정의 | `FamilyAPI.swift` + Repository | 단건 조회 API 추가 |

#### 구현 예시

```swift
// FamilyAPI.swift에 추가
case getFamily(familyId: Int)

// FamilyRepository.swift에 추가
func getFamily(familyId: String) -> Single<Family> {
    guard let familyIdInt = Int(familyId) else {
        return .error(RepositoryError.invalidParameter)
    }

    return networkService.request(FamilyAPI.getFamily(familyId: familyIdInt))
        .map { /* ... */ }
}
```

**참고 구현**: `FamilyRepository.swift:177` (createFamilyRaw 메서드 참조)

---

### 8. Family Member Controller (부분 미구현)

**현재 상태**:
- ✅ `FamilyRepository.swift`에 일부 구현
- ✅ `FamilyMemberAPI.swift` 존재
- ❌ 전체 조회, 단건 조회, 유저별 조회 미구현

#### 구현 필요 위치

| API | 현재 상태 | 구현 위치 | 작업 내용 |
|-----|----------|----------|----------|
| `GET /family-members` | 미구현 | `FamilyMemberAPI.swift` + Repository | 전체 조회 API 추가 |
| `GET /family-members/{id}` | 미구현 | API + Repository | 단건 조회 API 추가 |
| `GET /family-members/user/{userId}` | 미구현 | API + Repository | 유저별 조회 API 추가 |

#### 구현 예시

```swift
// FamilyMemberAPI.swift에 추가
enum FamilyMemberAPI {
    case getAllFamilyMembers
    case getFamilyMember(id: Int)
    case getFamilyMembersByUser(userId: Int)
    case getFamilyMembers(familyId: Int)
    case removeFamilyMember(familyMemberId: Int)
}

// FamilyRepository.swift에 추가
func getAllFamilyMembers() -> Single<[FamilyMember]> {
    return networkService.request(FamilyMemberAPI.getAllFamilyMembers)
        .map { /* ... */ }
}

func getFamilyMembersByUser(userId: String) -> Single<[FamilyMember]> {
    guard let userIdInt = Int(userId) else {
        return .error(RepositoryError.invalidParameter)
    }

    return networkService.request(FamilyMemberAPI.getFamilyMembersByUser(userId: userIdInt))
        .map { /* ... */ }
}
```

**참고 구현**: `FamilyRepository.swift:109` (getFamilyMembers 메서드 참조)

---

### 9. Auth Controller (개발용 로그인 미구현)

**현재 상태**:
- ✅ `AuthRepository.swift` 존재
- ❌ 개발용 로그인 미정의

#### 구현 필요 위치

| API | 현재 상태 | 구현 위치 | 작업 내용 |
|-----|----------|----------|----------|
| `POST /auth/dev/login` | 미정의 | `AuthAPI.swift` + Repository | 개발용 로그인 추가 |

#### 구현 예시

```swift
// AuthAPI.swift에 추가
case devLogin

// AuthRepository.swift에 추가
func devLogin() -> Observable<Result<User, NetworkError>> {
    return networkService.request(AuthAPI.devLogin)
        .map { /* ... */ }
}
```

**참고 구현**: `AuthRepository.swift:9` (login 메서드 참조)

---

## 📋 우선순위별 구현 권장 순서

### 🔴 High Priority (핵심 기능)
1. **User Controller 전체** - 사용자 프로필 관리 필수
2. **Mission Progress Controller** - 미션 진행도 추적 필수
3. **Mission Verification 조회/제출** - 인증 기능 완성

### 🟡 Medium Priority (기능 완성도)
4. **Account 활성 계좌 조회** - 계좌 관리 개선
5. **Mission 완료 API** - 미션 상태 관리
6. **Family Member 조회** - 가족 관리 완성

### 🟢 Low Priority (편의성)
7. **Savings 단건 조회** - 상세 조회 기능
8. **Family 단건 조회** - 상세 조회 기능
9. **개발용 로그인** - 개발 편의성

---

## 🎯 구현 체크리스트

### User Controller 구현 시
- [ ] `Domain/Interface/UserRepositoryProtocol.swift` 생성
- [ ] `Data/Repository/UserRepository.swift` 생성
- [ ] `UserProfileManager.swift`와 연동 (로컬 캐시 동기화)
- [ ] 프로필 이미지 업로드 multipart/form-data 처리
- [ ] AuthRepository 로그인 성공 시 `getMyProfile()` 호출 추가

### Mission Progress 구현 시
- [ ] `Domain/Model/MissionProgress.swift` 생성
- [ ] `MissionRepositoryProtocol.swift`에 메서드 추가
- [ ] `MissionRepository.swift`에 구현 추가
- [ ] `MissionDTO.swift`에 `toDomain()` 변환 추가
- [ ] Mission 상세 화면에서 진행도 표시 UI 연동

### Mission Verification 완성 시
- [ ] `MissionVerificationAPI.swift`에 조회/제출 케이스 추가
- [ ] `MissionVerificationRepository.swift` Mock 로직 제거
- [ ] 실제 API 호출로 변경
- [ ] 파일 업로드 처리 (사진 인증)

---

## 📌 공통 구현 패턴

### 1. Repository 메서드 구조
```swift
func someMethod() -> Single<DomainModel> {
    return Single.create { [weak self] single in
        guard let self = self else {
            single(.failure(RepositoryError.unknown(...)))
            return Disposables.create()
        }

        // 1. 파라미터 검증
        guard let validParam = Int(param) else {
            single(.failure(RepositoryError.invalidParameter))
            return Disposables.create()
        }

        // 2. API 호출
        self.networkService.request(SomeAPI.someEndpoint(...))
            .subscribe(onNext: { (result: Result<DTOResponse, NetworkError>) in
                switch result {
                case .success(let response):
                    let model = response.toDomain()
                    self.debugSuccess("Success message")
                    single(.success(model))

                case .failure(let error):
                    self.debugError("Error message", error: error)
                    // Fallback to mock if needed
                    single(.failure(RepositoryError.networkError(error)))
                }
            })
            .disposed(by: self.disposeBag)

        return Disposables.create()
    }
}
```

### 2. Raw Response 처리 (공통 포맷 미사용 API)
```swift
private func fetchSomethingRaw(id: Int) -> Single<ResponseDTO> {
    return Single.create { [weak self] single in
        guard let self = self else { /* ... */ }

        let baseURL = Environment.current.baseURL
        guard let url = URL(string: "\(baseURL)/path/\(id)") else { /* ... */ }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let accessToken = self.tokenManager.accessToken {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // 에러 처리
            // 디코딩
            // 응답 반환
        }

        task.resume()
        return Disposables.create { task.cancel() }
    }
}
```

### 3. DTO to Domain 변환
```swift
extension SomeResponse {
    func toDomain() -> DomainModel {
        // ISO8601 날짜 파싱
        let dateFormatter = ISO8601DateFormatter()

        // Enum 변환
        let enumValue = EnumType(rawValue: rawValue.lowercased()) ?? .default

        return DomainModel(
            id: String(id),
            // ... 필드 매핑
        )
    }
}
```

---

## 🚨 주의사항

1. **공통 응답 포맷 확인**
   - API 명세서의 "예외 API 목록" 확인 필수
   - 예외 API는 `fetchSomethingRaw()` 패턴 사용

2. **데이터 타입**
   - 백엔드는 금액/포인트를 `Double` 타입으로 반환
   - 클라이언트는 `Int`로 사용하므로 변환 필요

3. **에러 핸들링**
   - API 실패 시 Mock 데이터로 fallback 고려
   - 사용자 경험을 위해 빈 배열 반환 vs 에러 반환 판단

4. **Thread Safety**
   - Repository는 RxSwift로 비동기 처리
   - UserProfileManager는 Actor 패턴 (async/await)

5. **디버그 로그**
   - `debugLog()`, `debugSuccess()`, `debugError()` 활용
   - BaseRepository 상속 시 자동 제공

---

## 📞 구현 관련 문의

구현 중 불명확한 부분이나 기술적 질문이 있다면:
1. 기존 구현된 Repository 코드 참고
2. API 명세서 (`API_SPECIFICATION.md`) 재확인
3. DTO 변환 로직 확인 (`toDomain()` 메서드)
