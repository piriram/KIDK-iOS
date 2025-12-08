# KIDK API Document (v1.0.0)

**Base URL**: `http://43.202.165.98:8080`

**Swagger**: http://43.202.165.98:8080/swagger-ui/index.html

**인증**: Bearer Token (JWT)

---

## 공통 응답 포맷

### 성공 응답
```json
{
  "success": true,
  "data": { /* 실제 데이터 */ }
}
```

### 실패 응답
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "에러 메시지"
  }
}
```

### ⚠️ 예외 API 목록
다음 API들은 공통 응답 포맷을 **사용하지 않고** 데이터를 직접 반환:
- `GET /api/v1/accounts/user/{userId}` - 배열 직접 반환
- `GET /api/v1/accounts/user/{userId}/active` - 배열 직접 반환
- `GET /api/v1/families` - 배열 직접 반환
- `PUT /api/v1/missions/{missionId}/complete` - MissionResponse 직접 반환
- `POST /api/v1/families` - FamilyResponse 직접 반환
- `POST /api/v1/families/join` - FamilyMember 직접 반환
- `POST /api/v1/accounts` - AccountResponse 직접 반환
- `GET /api/v1/accounts/{accountId}` - AccountResponse 직접 반환
- `GET /api/v1/accounts/user/{userId}/primary` - AccountResponse 직접 반환
- `GET /api/v1/missions/owner/{ownerId}` - 배열 직접 반환
- `GET /api/v1/missions/creator/{creatorId}` - 배열 직접 반환
- `GET /api/v1/missions/{missionId}/verifications` - 배열 직접 반환
- `POST /api/v1/missions/{missionId}/verifications` - MissionVerification 직접 반환
- `PATCH /api/v1/missions/{missionId}/verifications/{verificationId}/approve` - MissionVerification 직접 반환
- `PATCH /api/v1/missions/{missionId}/verifications/{verificationId}/reject` - MissionVerification 직접 반환
- `GET /api/v1/mission-progress/{missionId}` - 배열 직접 반환
- `POST /api/v1/mission-progress/{missionId}` - MissionProgress 직접 반환
- `GET /api/v1/mission-progress/user/{userId}` - 배열 직접 반환
- `GET /api/v1/family-members` - 배열 직접 반환
- `GET /api/v1/family-members/{id}` - FamilyMember 직접 반환
- `GET /api/v1/family-members/user/{userId}` - 배열 직접 반환
- `GET /api/v1/family-members/family/{familyId}` - 배열 직접 반환
- `GET /api/v1/families/{familyId}` - FamilyResponse 직접 반환
- `GET /api/v1/friends/{userId}/friends` - 배열 직접 반환

---

## 1. Auth Controller

### POST `/api/v1/auth/login`
로그인

**Request Body:**
```json
{
  "firebaseToken": "string",
  "deviceId": "string"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "accessToken": "string",
    "refreshToken": "string",
    "userId": 0,
    "name": "string",
    "userType": "string"
  }
}
```

### POST `/api/v1/auth/logout`
로그아웃

**Headers:**
- `Refresh-Token`: string (required)

**Response:**
```json
{
  "success": true,
  "data": null
}
```

### POST `/api/v1/auth/dev/login`
개발용 로그인 (파라미터 없음)

**Response:**
```json
{
  "success": true,
  "data": {
    "accessToken": "string",
    "refreshToken": "string",
    "userId": 0,
    "name": "string",
    "userType": "string"
  }
}
```

---

## 2. User Controller

### GET `/api/v1/users/me`
내 정보 조회

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 0,
    "firebaseUid": "string",
    "email": "string",
    "socialProvider": "string",
    "socialProviderId": "string",
    "userType": "string",
    "name": "string",
    "profileImageUrl": "string",
    "birthDate": "2025-12-08",
    "phone": "string",
    "status": "string",
    "statusChangedAt": "2025-12-08T04:20:11.738Z",
    "lastLoginAt": "2025-12-08T04:20:11.738Z"
  }
}
```

### PUT `/api/v1/users/me`
내 정보 수정

**Request Body:**
```json
{
  "name": "string",        // required, 1-100자
  "birthDate": "2025-12-08",
  "phone": "762-491-2357"  // 형식: \d{2,3}-\d{3,4}-\d{4}
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    // UserResponse 객체
  }
}
```

### DELETE `/api/v1/users/me`
내 계정 삭제

**Response:**
```json
{
  "success": true,
  "data": null
}
```

### POST `/api/v1/users/me/profile-image`
프로필 이미지 업로드

**Request:**
- Content-Type: `multipart/form-data`
- Body: `file` (binary)

**Response:**
```json
{
  "success": true,
  "data": "https://image-url.com/profile.jpg"
}
```

### PATCH `/api/v1/users/me/status`
상태 변경

**Request Body:**
```json
{
  "status": "string"  // required
}
```

**Response:**
```json
{
  "success": true,
  "data": null
}
```

### GET `/api/v1/users/{userId}`
특정 유저 조회

**Parameters:**
- `userId` (path, required): integer

**Response:**
```json
{
  "success": true,
  "data": {
    // UserResponse 객체
  }
}
```

---

## 3. Account Controller

⚠️ **이 컨트롤러는 공통 응답 포맷을 사용하지 않음**

### POST `/api/v1/accounts`
계좌 생성

**Request Body:**
```json
{
  "userId": 0,
  "accountType": "string",
  "accountName": "string",
  "initialBalance": 0.0
}
```

**Response (직접 객체 반환):**
```json
{
  "id": 0,
  "userId": 0,
  "accountType": "string",
  "accountName": "string",
  "balance": 0.0,
  "active": true,
  "primary": true
}
```

### GET `/api/v1/accounts/user/{userId}`
유저의 계좌 목록 조회

**Parameters:**
- `userId` (path, required): integer

**Response (직접 배열 반환):**
```json
[
  {
    "id": 0,
    "userId": 0,
    "accountType": "string",
    "accountName": "string",
    "balance": 0.0,
    "active": true,
    "primary": true
  }
]
```

### GET `/api/v1/accounts/{accountId}`
계좌 단건 조회

**Parameters:**
- `accountId` (path, required): integer
- `userId` (query, required): integer

**Response (직접 객체 반환):**
```json
{
  "id": 0,
  "userId": 0,
  "accountType": "string",
  "accountName": "string",
  "balance": 0.0,
  "active": true,
  "primary": true
}
```

### GET `/api/v1/accounts/user/{userId}/primary`
대표 계좌 조회

**Parameters:**
- `userId` (path, required): integer

**Response (직접 객체 반환):**
```json
{
  "id": 0,
  "userId": 0,
  "accountType": "string",
  "accountName": "string",
  "balance": 0.0,
  "active": true,
  "primary": true
}
```

### GET `/api/v1/accounts/user/{userId}/active`
활성 계좌 목록 조회

**Parameters:**
- `userId` (path, required): integer

**Response (직접 배열 반환):**
```json
[
  {
    "id": 0,
    "userId": 0,
    "accountType": "string",
    "accountName": "string",
    "balance": 0.0,
    "active": true,
    "primary": true
  }
]
```

---

## 4. Mission Controller

### POST `/api/v1/missions`
미션 생성

**Request Body:**
```json
{
  "creatorId": 0,
  "ownerId": 0,
  "missionType": "string",
  "title": "string",
  "description": "string",
  "targetAmount": 0.0,      // number (Double)
  "rewardAmount": 0.0,      // number (Double)
  "status": "string",
  "targetDate": "2025-12-08"  // date 형식
}
```

**Response (직접 객체 반환):**
```json
{
  "createdAt": "2025-12-08T04:20:11.738Z",
  "updatedAt": "2025-12-08T04:20:11.738Z",
  "id": 0,
  "creator": {
    "id": 0,
    "firebaseUid": "string",
    "email": "string",
    "name": "string"
    // ... User 객체
  },
  "owner": {
    "id": 0,
    "name": "string"
    // ... User 객체
  },
  "missionType": "string",
  "title": "string",
  "description": "string",
  "targetAmount": 0.0,
  "rewardAmount": 0.0,
  "targetDate": "2025-12-08",
  "status": "string",
  "completedAt": "2025-12-08T04:20:11.738Z"
}
```

### PUT `/api/v1/missions/{missionId}/complete`
미션 완료 처리

**Parameters:**
- `missionId` (path, required): integer

**Response (직접 객체 반환):**
```json
{
  // MissionResponse 객체
}
```

### GET `/api/v1/missions/owner/{ownerId}`
해당 유저가 수행자(owner)인 미션 목록

**Parameters:**
- `ownerId` (path, required): integer

**Response (직접 배열 반환):**
```json
[
  {
    // MissionResponse 객체
  }
]
```

### GET `/api/v1/missions/creator/{creatorId}`
해당 유저가 생성자(creator)인 미션 목록

**Parameters:**
- `creatorId` (path, required): integer

**Response (직접 배열 반환):**
```json
[
  {
    // MissionResponse 객체
  }
]
```

---

## 5. Mission Verification Controller

### GET `/api/v1/missions/{missionId}/verifications`
미션 검증 내역 조회

**Parameters:**
- `missionId` (path, required): integer

**Response (직접 배열 반환):**
```json
[
  {
    "id": 0,
    "mission": { /* Mission 객체 */ },
    "child": { /* User 객체 */ },
    "verificationType": "string",
    "content": "string",
    "submittedAt": "2025-12-08T04:20:11.738Z",
    "reviewedBy": { /* User 객체 */ },
    "reviewedAt": "2025-12-08T04:20:11.738Z",
    "status": "string",
    "rejectReason": "string"
  }
]
```

### POST `/api/v1/missions/{missionId}/verifications`
검증 제출

**Parameters:**
- `missionId` (path, required): integer
- `childId` (query, required): integer
- `verificationType` (query, required): string
- `content` (query, optional): string

**Response (직접 객체 반환):**
```json
{
  "id": 0,
  "mission": { /* Mission 객체 */ },
  "child": { /* User 객체 */ },
  "verificationType": "string",
  "content": "string",
  "submittedAt": "2025-12-08T04:20:11.738Z",
  "status": "string"
}
```

### PATCH `/api/v1/missions/{missionId}/verifications/{verificationId}/approve`
검증 승인

**Parameters:**
- `missionId` (path, required): integer
- `verificationId` (path, required): integer
- `parentId` (query, required): integer

**Response (직접 객체 반환):**
```json
{
  // MissionVerification 객체
}
```

### PATCH `/api/v1/missions/{missionId}/verifications/{verificationId}/reject`
검증 거절

**Parameters:**
- `missionId` (path, required): integer
- `verificationId` (path, required): integer
- `parentId` (query, required): integer
- `reason` (query, required): string

**Response (직접 객체 반환):**
```json
{
  // MissionVerification 객체
}
```

---

## 6. Mission Progress Controller

### GET `/api/v1/mission-progress/{missionId}`
미션 진행도 조회

**Parameters:**
- `missionId` (path, required): integer

**Response (직접 배열 반환):**
```json
[
  {
    "id": 0,
    "mission": { /* Mission 객체 */ },
    "user": { /* User 객체 */ },
    "progressAmount": 0.0,
    "progressPercentage": 0.0,
    "lastActivityAt": "2025-12-08T04:20:11.738Z"
  }
]
```

### POST `/api/v1/mission-progress/{missionId}`
미션 진행도 업데이트

**Parameters:**
- `missionId` (path, required): integer
- `userId` (query, required): integer
- `progressAmount` (query, optional): number
- `progressPercentage` (query, optional): number

**Response (직접 객체 반환):**
```json
{
  "id": 0,
  "mission": { /* Mission 객체 */ },
  "user": { /* User 객체 */ },
  "progressAmount": 0.0,
  "progressPercentage": 0.0,
  "lastActivityAt": "2025-12-08T04:20:11.738Z"
}
```

### GET `/api/v1/mission-progress/user/{userId}`
특정 유저의 미션 활동 기록

**Parameters:**
- `userId` (path, required): integer

**Response (직접 배열 반환):**
```json
[
  {
    // MissionProgress 객체
  }
]
```

---

## 7. Transaction Controller

### POST `/api/v1/transactions`
거래 생성

**Request Body:**
```json
{
  "accountId": 0,
  "type": "string",
  "amount": 0.0,
  "category": "string",
  "description": "string",
  "relatedMissionId": 0
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 0,
    "accountId": 0,
    "type": "string",
    "amount": 0.0,
    "balanceAfter": 0.0,
    "category": "string",
    "description": "string",
    "createdAt": "2025-12-08T04:20:11.747Z"
  }
}
```

### POST `/api/v1/transactions/transfer`
계좌 간 송금

**Request Body:**
```json
{
  "fromAccountId": 0,     // required
  "toAccountId": 0,       // required
  "amount": 0.0,          // required
  "description": "string"
}
```

**Response:**
```json
{
  "success": true,
  "data": null
}
```

### GET `/api/v1/transactions/account/{accountId}`
특정 계좌의 거래 내역 조회

**Parameters:**
- `accountId` (path, required): integer

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 0,
      "accountId": 0,
      "type": "string",
      "amount": 0.0,
      "balanceAfter": 0.0,
      "category": "string",
      "description": "string",
      "createdAt": "2025-12-08T04:20:11.747Z"
    }
  ]
}
```

---

## 8. Savings Goal Controller

### POST `/api/v1/savings-goals`
저축 목표 생성

**Request Body:**
```json
{
  "userId": 0,            // required
  "goalName": "string",   // required
  "targetAmount": 0.0,    // required
  "targetDate": "2025-12-08T04:20:11.751Z"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "createdAt": "2025-12-08T04:20:11.738Z",
    "updatedAt": "2025-12-08T04:20:11.738Z",
    "id": 0,
    "user": { /* User 객체 */ },
    "mission": { /* Mission 객체 */ },
    "goalName": "string",
    "targetAmount": 0.0,
    "currentAmount": 0.0,
    "targetDate": "2025-12-08T04:20:11.738Z",
    "status": "IN_PROGRESS",  // IN_PROGRESS, ACHIEVED, CANCELLED
    "achievedAt": "2025-12-08T04:20:11.738Z"
  }
}
```

### GET `/api/v1/savings-goals/{goalId}`
저축 목표 단건 조회

**Parameters:**
- `goalId` (path, required): integer

**Response:**
```json
{
  "success": true,
  "data": {
    // SavingsGoal 객체
  }
}
```

### GET `/api/v1/savings-goals/user/{userId}`
유저의 모든 저축 목표 조회

**Parameters:**
- `userId` (path, required): integer

**Response:**
```json
{
  "success": true,
  "data": [
    {
      // SavingsGoal 객체
    }
  ]
}
```

---

## 9. Family Controller

### GET `/api/v1/families`
가족 목록 조회

**Response (직접 배열 반환):**
```json
[
  {
    "id": 0,
    "familyName": "string",
    "inviteCode": "string",
    "onCreate": "2025-12-08T04:20:11.784Z"
  }
]
```

### POST `/api/v1/families`
가족 생성

**Request Body:**
```json
{
  "userId": 0,
  "familyName": "string"
}
```

**Response (직접 객체 반환):**
```json
{
  "id": 0,
  "familyName": "string",
  "inviteCode": "string",
  "onCreate": "2025-12-08T04:20:11.786Z"
}
```

### POST `/api/v1/families/join`
가족 초대 코드로 가입

**Request Body:**
```json
{
  "userId": 0,
  "inviteCode": "string"
}
```

**Response (직접 객체 반환):**
```json
{
  "id": 0,
  "family": { /* Family 객체 */ },
  "user": { /* User 객체 */ },
  "role": "string",
  "primaryParent": false,
  "invitedBy": { /* User 객체 */ },
  "invitedAt": "2025-12-08T04:20:11.738Z",
  "acceptedAt": "2025-12-08T04:20:11.738Z",
  "status": "string"
}
```

### GET `/api/v1/families/{familyId}`
가족 단건 조회

**Parameters:**
- `familyId` (path, required): integer

**Response (직접 객체 반환):**
```json
{
  "id": 0,
  "familyName": "string",
  "inviteCode": "string",
  "onCreate": "2025-12-08T04:20:11.784Z"
}
```

---

## 10. Family Member Controller

### GET `/api/v1/family-members`
전체 가족 구성원 조회

**Response (직접 배열 반환):**
```json
[
  {
    // FamilyMember 객체
  }
]
```

### GET `/api/v1/family-members/{id}`
구성원 단건 조회

**Parameters:**
- `id` (path, required): integer

**Response (직접 객체 반환):**
```json
{
  // FamilyMember 객체
}
```

### GET `/api/v1/family-members/user/{userId}`
해당 유저의 가족 구성 관계 조회

**Parameters:**
- `userId` (path, required): integer

**Response (직접 배열 반환):**
```json
[
  {
    // FamilyMember 객체
  }
]
```

### GET `/api/v1/family-members/family/{familyId}`
가족 ID로 구성원 목록 조회

**Parameters:**
- `familyId` (path, required): integer

**Response (직접 배열 반환):**
```json
[
  {
    // FamilyMember 객체
  }
]
```

---

## 11. Friend Controller

### GET `/api/v1/friends/{userId}/friends`
친구 목록 조회

**Parameters:**
- `userId` (path, required): integer

**Response (직접 배열 반환):**
```json
[
  {
    "createdAt": "2025-12-08T04:20:11.738Z",
    "updatedAt": "2025-12-08T04:20:11.738Z",
    "id": 0,
    "user": { /* User 객체 */ },
    "friendUser": { /* User 객체 */ },
    "status": "string"
  }
]
```

---

## 주요 특이사항

### 1. 응답 포맷 불일치
대부분의 API는 공통 응답 포맷(`{success, data, error}`)을 사용하지만, 많은 GET API들이 데이터를 직접 반환합니다. 위의 "예외 API 목록"을 참고하세요.

### 2. 데이터 타입
- **number**: JSON의 number 타입 (JavaScript의 Number, Swift의 Double)
- **integer**: 정수형 (int64)
- **date**: "yyyy-MM-dd" 형식
- **date-time**: ISO8601 형식 ("2025-12-08T04:20:11.738Z")

### 3. 인증
- **Bearer Token**: 대부분의 API는 `Authorization: Bearer {accessToken}` 헤더 필요
- **Refresh Token**: 로그아웃은 `Refresh-Token` 헤더 사용

### 4. 중요한 필드 타입 변경
- **Mission API**: `targetAmount`, `rewardAmount`가 **number (Double)** 타입
- **Account API**: `balance`, `initialBalance`가 **number (Double)** 타입
- **Transaction API**: `amount`가 **number (Double)** 타입
- **Savings API**: `targetAmount`, `currentAmount`가 **number (Double)** 타입
