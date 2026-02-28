# KIDK SpriteKit Game Implementation Plan (키득 게임 기능 구현 계획서)

## 0. 목표
키득 기획서의 게임 관련 기능(게임 화면, 미션 게이지 상승, 미션/리포트 연동, 저축 목표 시각화, 키득 시티 해금)을 **SpriteKit 중심**으로 iOS 앱에 안정적으로 통합한다.

## 0-1. 서버 연동 원칙 (중요)
- 본 문서는 **클라이언트(SpriteKit/iOS) 구현 계획 중심**이다.
- 미션 상태 전이, 보상 적립/정산, 승인 처리, 에러 코드, 재시도 정책 등 **서버 계약이 필요한 항목은 서버 API 문서를 단일 기준(Source of Truth)으로 확인**한다.
- 문서와 서버 API 문서가 충돌할 경우, **서버 API 문서를 우선**한다.

## 0-2. 서버 연동 기준선 (Backend Team 가이드 반영, 2026-02-15)
- Base URL: `http://43.202.165.98:8080` (개발 단계 HTTP)
- Health Check: `GET /actuator/health`
- Swagger UI: `https://kidk.kro.kr/swagger-ui/index.html`
- 앱(개발 빌드)에서 ATS 예외 설정 필요 여부를 확인한다 (`NSAppTransportSecurity`).

### 인증 규칙
- 로그인/회원가입 제외 모든 API는 `Authorization: Bearer {Access_Token}` 필수
- 요청 기본 헤더: `Content-Type: application/json`
- 인증 에러 코드 기준:
  - `AUTH_001` (401): 토큰 누락/무효
  - `AUTH_003` (403): 권한 없음

### 주요 엔드포인트 기준
- Auth
  - `POST /api/v1/auth/login`
  - `POST /api/v1/auth/register`
  - `POST /api/v1/auth/refresh`
- User
  - `GET /api/v1/users/me`
  - `PUT /api/v1/users/me`
- Family
  - `GET /api/v1/families/me`
  - `POST /api/v1/families`
- Mission
  - `GET /api/v1/missions`
  - `POST /api/v1/missions`
- Transaction
  - `GET /api/v1/transactions` (필터링 지원)

### 표준 에러 응답 파싱 기준
```json
{
  "success": false,
  "error": {
    "code": "AUTH_001",
    "message": "유효하지 않은 토큰입니다."
  }
}
```
- iOS 클라이언트는 `success == false`일 때 `error.code`, `error.message`를 단일 에러 처리 경로로 전달한다.

---

## 1. 기획 기능 → 구현 모듈 매핑

### 1) 게임 화면
- **구현 모듈**: `GameViewController` + `SKView` + `KidkCityScene`
- **핵심 요소**
  - 도시 배경(타일/레이어)
  - 캐릭터(아이 아바타)
  - 상호작용 오브젝트(은행, 상점, 미션 게시판)
  - HUD(코인/게이지/오늘 미션 상태)

### 2) 미션 생성/진행/완료
- **구현 모듈**: `MissionEngine`, `MissionRepository`, `MissionStateStore`
- **핵심 요소**
  - 미션 타입: 저축/소비/퀴즈/영상
  - 상태: created → inProgress → completed → approved
  - 부모 승인 필요 플로우(기존 인증/네트워크 계층 재사용)

### 3) 미션 게이지 상승
- **구현 모듈**: `GaugeSystem` + `GaugeHUDNode`
- **핵심 요소**
  - 미션 완료 시 포인트 적립
  - 게이지 증가 애니메이션(파티클 + progress bar)
  - 레벨업 임계치 도달 시 해금 이벤트 트리거

### 4) 저축 목표 설정/진행 시각화
- **구현 모듈**: `SavingsGoalTracker` + `GoalProgressNode`
- **핵심 요소**
  - 목표 금액 대비 달성률(%)
  - 목표 달성 단계별 도시 오브젝트 변화(예: 저금통 건물 업그레이드)

### 5) 미션 리포트
- **구현 모듈**: `MissionReportBuilder` + UIKit 리포트 화면
- **핵심 요소**
  - 기간별 수행률
  - 미션 타입별 성과
  - 게임 내 보상/레벨 변화 히스토리

### 6) 키득 시티(레벨 해금)
- **구현 모듈**: `CityUnlockSystem` + `CityMapData`
- **핵심 요소**
  - 레벨별 해금 규칙
  - 해금 연출(카메라 줌, 이펙트, 안내 모달)
  - 저장/복원(앱 재실행 시 동일 상태 유지)

---

## 2. 기술 아키텍처 설계

## 2-1. Scene 구조
- `BaseGameScene` (공통 입력 처리, 카메라, pause/resume)
- `KidkCityScene` (메인 도시)
- `MiniGameScene` (퀴즈/간단 액션용 확장 슬롯)

## 2-2. 데이터 흐름
- 기존 MVVM/RxSwift 계층과 분리하지 않고 연결:
  - UI(ViewController) ↔ ViewModel ↔ UseCase ↔ Repository ↔ API/DB
  - SpriteKit은 ViewController 내부에서 **렌더링 레이어** 역할
- 상태 단일화:
  - `GameState`(게이지, 레벨, 해금, 미션 진행) 단일 모델 유지

## 2-3. 영속화
- 로컬: Realm/CoreData 중 프로젝트 표준 저장소 사용
- 서버 동기화:
  - 미션 완료/승인/보상 지급 이벤트 단위 업로드
  - 오프라인 큐(재시도) 적용
  - 요청/응답 스키마, 상태 코드, 권한/토큰 정책은 서버 API 문서 기준으로 구현

## 2-4. 보안/무결성/동기화 보강
- **서버 authoritative 정산 원칙**
  - 클라이언트는 진행 상태를 표시하되, 보상/레벨/해금 최종 확정은 서버 기준으로 동기화
  - 세부 확정 시점(예: approved 반영 조건)은 서버 API 문서 기준으로 적용
- **오프라인 이벤트 멱등성(idempotency)**
  - 각 이벤트에 `eventId(UUID)` 부여
  - 재전송/중복 전송 시에도 동일 이벤트는 1회만 반영되도록 서버 API 규격 확인 후 구현
- **GameState 로컬 무결성**
  - 게이지/레벨/해금 상태 저장 시 무결성 검증(체크섬/서명) 적용
  - 무결성 실패 시 서버 기준 상태로 복원
- **상태 전이 원자성**
  - `미션 완료 -> 게이지 증가 -> 해금` 단계는 단일 전이 단위로 처리
  - 중간 실패 시 롤백/재시도 규칙 적용
- **동기화 충돌 처리**
  - 다기기/오프라인 복귀 상황에서 충돌 정책(최신 서버 시간 우선/재계산 우선)을 API 문서 기준으로 확정

---

## 3. 구현 단계 (Sprint Plan)

## Sprint 1 — 게임 화면 베이스(1주)
- `GameViewController` 생성, `SKView` 임베딩
- `KidkCityScene` 기본 배경/카메라/HUD 구성
- 터치 입력(탭/드래그) 이벤트 라우팅
- 목표 산출물
  - 도시 화면 진입 가능
  - FPS 55+ 유지(기본 iPhone 기준)

## Sprint 2 — 미션 엔진 + 게이지(1주)
- `MissionEngine` 상태 머신 구현
- 미션 완료 이벤트와 게이지 시스템 연결
- 게이지 상승 애니메이션 추가
- 목표 산출물
  - 더미/실데이터로 미션 1개 완료 시 HUD 변화 확인

## Sprint 3 — 저축 목표 + 키득 시티 해금(1주)
- 목표 달성률 계산 및 HUD 반영
- 해금 조건 충족 시 신규 지역 오픈
- 해금 연출 및 튜토리얼 팝업
- 목표 산출물
  - 레벨업→구역 해금 E2E 동작

## Sprint 4 — 리포트 + 부모 승인 연동(1주)
- 리포트 데이터 집계/표시
- 부모 승인 상태 반영(approved 전/후 보상 차등)
- 오류/재시도/오프라인 처리
- 관측성 이벤트 로깅(전이 실패, 중복 차단, 복구 성공) 추가
- 목표 산출물
  - 미션 생성→완료→승인→리포트 반영 전체 흐름 완료

## Sprint 5 — 안정화/최적화(3~5일)
- Texture atlas 최적화
- 메모리/배터리 튜닝
- 테스트 코드/QA 시나리오 점검
- 성능 예산 측정(FPS/메모리/발열) 및 저사양 모드 기준 확정

---

## 4. 구현 상세 체크리스트

- [ ] SpriteKit 리소스 구조 확정 (`Assets.xcassets` + atlas)
- [ ] 게임 루프와 앱 생명주기 연동(`sceneWillResignActive` 등)
- [ ] 미션 상태 머신 단위 테스트
- [ ] 게이지/레벨 계산 로직 테스트
- [ ] 서버 에러/토큰 만료 시 롤백 정책 정의
- [ ] 접근성(글자 크기, 색 대비) 최소 기준 반영
- [ ] 저사양 기기 품질 옵션(이펙트 강도 조절)
- [ ] 이벤트 `eventId` 기반 중복 반영 방지 구현(세부 규격은 서버 API 문서 기준)
- [ ] GameState 무결성 검증 및 불일치 복원 경로 구현
- [ ] 상태 전이 원자성(완료→적립→해금) 보장 및 실패 복구 시나리오 구현
- [ ] 동기화 충돌 정책(다기기/오프라인) 적용
- [ ] 관측성 이벤트 스키마 정의(성공/실패/복구)
- [ ] 아동 데이터 최소 수집/보존/삭제 정책 점검 및 부모 동의 이력 연동 확인

---

## 5. QA 기준 (Definition of Done)

1. 미션 완료 시 게이지가 일관되게 상승하고, 앱 재시작 후 값이 유지된다.
2. 레벨 임계치 도달 시 도시 해금이 중복/누락 없이 1회만 실행된다.
3. 부모 승인 전후 보상 규칙이 리포트와 동일하게 반영된다.
4. 오프라인 재전송/중복 요청 상황에서도 동일 이벤트가 중복 반영되지 않는다.
5. GameState 무결성 실패 시 안전하게 서버 기준값으로 복구된다.
6. 핵심 플로우 자동화 테스트(생성→완료→승인→리포트)가 통과한다.
7. 성능 예산(FPS 55+, 메모리/발열 기준) 충족.
8. README에 게임 모듈 구조/실행법/리소스 규칙 업데이트 완료.

---

## 6. 리스크 & 대응

- **리스크 A: SpriteKit-UIKit 상태 불일치**
  - 대응: `GameState` 단일 소스 유지, Scene은 렌더 전담

- **리스크 B: 애니메이션 과다로 성능 저하**
  - 대응: 파티클 상한, atlas 사용, offscreen node 정리

- **리스크 C: 미션 승인 지연으로 UX 혼선**
  - 대응: pending 상태 명확 표기 + 로컬 임시 보상 정책 분리

- **리스크 D: 오프라인 재시도로 인한 중복 적립**
  - 대응: `eventId` 멱등 처리 + 서버 응답 기반 중복 차단

- **리스크 E: 저장 데이터 변조/불일치**
  - 대응: 로컬 무결성 검증 + 서버 상태 재동기화

- **리스크 F: 다기기 동기화 충돌**
  - 대응: 서버 API 문서 기준 충돌 해소 정책 적용 + 재계산 루틴 제공

---

## 7. 우선 구현 대상 (MVP)
1) 게임 화면 진입
2) 미션 1종(저축) 완료
3) 게이지 상승 + 레벨업 1단계
4) 구역 1개 해금
5) 미션 리포트 기본 화면

MVP 완료 후 퀴즈/영상 미션, 이벤트성 미니게임을 확장한다.
