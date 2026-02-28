# Parent 영역 전체 UI 통일(아이 정보 탭 Timeline Progress 톤) 실행 계획서

작성일: 2026-02-28  
대상 프로젝트: `/Users/piri/shared/active/KIDK-iOS`  
범위:
- `ParentApprovalViewController`
- `ParentChildWalletViewController`
- `ParentChildInfoViewController`
- 부모 플로우 공통 Parent 컴포넌트/헤더/카드

> 본 문서는 **실행 계획만** 다룬다. (코드 수정/커밋/푸시 없음)

---

## 1) 현재 부모 탭 3개 UI 구조/공통점/불일치 분석

### 1-1. 탭별 현재 구조

### A. 승인 대기 탭 (`ParentApprovalViewController`)
- 구조: `상단 헤더 + UITableView + 중앙 EmptyView`
- 리스트: `VerificationCardCell -> VerificationCardView`
- 강점
  - `viewWillAppear` + pull-to-refresh + 알림(.verificationApproved/.verificationRejected) 기반 갱신
  - 카드 선택 시 상세 화면 push 동작 명확
- 한계
  - Timeline 맥락(시간 흐름/진행감) 표현이 약함
  - Empty 상태가 다른 부모 탭과 스타일 불일치(단독 이모지/문구)

### B. 아이 지갑 탭 (`ParentChildWalletViewController`)
- 구조: `상단 헤더 + ScrollView/StackView`
  - `ChildInfoHeaderView`
  - 총 잔액 `AccountCardView`
  - 최근 거래 `SectionHeaderView + UITableView(TransactionCell)`
- 강점
  - 계좌 합산/최근 거래 핵심 정보는 존재
- 한계
  - 최근 거래가 Timeline이 아닌 표형 셀 톤
  - 거래 0건 Empty 상태가 사실상 없음(높이 0)
  - 정보 위계가 “요약-진행-타임라인” 구조로 정리되어 있지 않음

### C. 아이 정보 탭 (`ParentChildInfoViewController`)
- 구조: `상단 헤더 + ScrollView + 하단 고정 액션바(로그아웃)`
  - 월 성장 요약 카드
  - Child 헤더
  - 통계 카드 3개
  - 완료 미션 Timeline 카드
- 강점
  - 이미 Timeline + Progress 톤이 반영되어 기준 탭으로 쓰기 좋음
  - 고정 액션바(로그아웃) UX가 명확
- 한계
  - `MonthlyGrowthSummaryView`, `TimelineStatCardView` 등이 VC 내부 private 클래스라 재사용 어려움
  - 일부 톤(카드 배경/배지/여백 규칙)이 다른 부모 탭과 완전 통일되지 않음

---

### 1-2. 부모 3탭 공통점
- 다크 테마 기반 (`kidkDarkBackground`, `cardBackground` 계열)
- 상단 `KIDKNavigationHeaderView` 사용
- 카드 중심 정보 전달
- Rx 바인딩 기반 데이터 갱신

---

### 1-3. 불일치 포인트(통일 필요)
1. **레이아웃 패턴 불일치**: Table 중심(승인), Stack+Table 혼합(지갑), Timeline 중심(정보)
2. **카드 표면 스타일 불일치**: `cardBackground`, `#2C2C2E`, 알파 배경 혼용
3. **배지 스타일 불일치**: 상태 배지 크기/코너/텍스트 규칙 탭마다 다름
4. **섹션 헤더 밀도 불일치**: 어떤 화면은 title-only, 어떤 화면은 title+subtitle
5. **빈 상태 UX 불일치**: 승인/정보는 있음, 지갑은 사실상 없음
6. **Timeline 감성 불일치**: 정보 탭만 “진행감/시간축”이 살아 있음
7. **컴포넌트 재사용성 낮음**: 정보 탭 핵심 UI가 VC 내부 private 구현

---

## 2) 통일 디자인 시스템 제안 (Timeline Progress Parent UI Kit)

기준: **아이 정보 탭의 Timeline Progress 느낌**을 부모 3탭 공통 언어로 확장

### 2-1. 타이포
- Page Title: `s20 bold`
- Section Title: `s20 bold`
- Section Subtitle: `s14 regular`
- Card Value(핵심 숫자): `s18~s32 bold` (영역별 제한)
- Card Body: `s14 regular`
- Caption/Meta(날짜, 보조): `s12 regular/medium`

### 2-2. 카드
- **Primary Card**: `background = cardBackground`, `radius = 16`, 내부 padding = 16~20
- **Inset Card(행/보조)**: `kidkDarkBackground alpha 0.35~0.45`, `radius = 12`
- **Interactive Card**: 눌림 피드백(알파/스케일) 통일

### 2-3. 배지
- 높이 고정 24~28, 좌우 패딩형(min width 방식)
- 상태색 규칙 통일
  - Pending: neutral(gray)
  - Approved/입금성: green
  - Rejected/출금성: pink/red
- 텍스트 스타일: `s12 bold`

### 2-4. 섹션 헤더
- `아이콘 + 제목 + (선택)서브타이틀` 기본형
- 섹션 간 간격 규칙 고정
  - Section-to-Section: 24
  - Header-to-Content: 8~12

### 2-5. 여백
- 페이지 좌우: 20 (`Spacing.md`)
- 카드 내부: 16 (`Spacing.sm`) 기본
- Timeline row 간: 12 (`Spacing.xs`)

### 2-6. 버튼
- Primary/Destructive 버튼 높이: 50 이상
- CornerRadius: 12
- 로그아웃은 Destructive 유지 + 확인 Alert 필수

### 2-7. 빈 상태
- 공통 `ParentEmptyStateCard` 패턴
  - 아이콘
  - 제목
  - 설명
  - (옵션) 액션 버튼
- 탭별 문구만 다르게, 구조는 동일

---

## 3) 파일별 수정 목록 + 변경 목적

## 3-1. 기존 파일 수정

1. `KIDK/Presentation/View/Parent/ParentChildInfoViewController.swift`
- 목적: 기준 디자인(아이 정보 탭)의 재사용 가능한 구조로 분리
- 변경 포인트:
  - VC 내부 private 뷰(`MonthlyGrowthSummaryView`, `TimelineStatCardView` 등) 외부 컴포넌트화
  - 기존 시각 톤 유지 + 공통 토큰 적용
  - 로그아웃 액션바 구조는 유지

2. `KIDK/Presentation/View/Parent/ParentChildWalletViewController.swift`
- 목적: 지갑 탭을 Timeline Progress 톤으로 전환
- 변경 포인트:
  - 최근 거래 영역을 Timeline row 기반으로 교체
  - 거래 0건 공통 Empty 상태 적용
  - 요약 카드/헤더/여백 규칙을 정보 탭 기준으로 정렬

3. `KIDK/Presentation/View/Parent/ParentApprovalViewController.swift`
- 목적: 승인 대기 탭도 Timeline 맥락(시간 흐름) 강화
- 변경 포인트:
  - 카드 리스트를 Timeline row 스타일로 정렬
  - Empty 상태를 공통 컴포넌트로 교체
  - 기존 pull-to-refresh / 선택 push 로직은 유지

4. `KIDK/Presentation/View/Parent/ChildInfoHeaderView.swift`
- 목적: 부모 공통 상단 요약 헤더 스타일 통일
- 변경 포인트:
  - 카드 내부 타이포/메트릭 간격/배경 강도 통일

5. `KIDK/Presentation/View/Parent/VerificationCardView.swift`
- 목적: 승인 카드의 배지/메타/썸네일 영역을 Parent Timeline 카드 규격에 맞춤
- 변경 포인트:
  - 상태 배지/보조텍스트/패딩 규칙 표준화

6. `KIDK/Presentation/View/Common/SectionHeaderView.swift`
- 목적: Parent 섹션 헤더 스타일 프리셋 제공
- 변경 포인트:
  - Parent 전용 configure 스타일(아이콘/subtitle 가이드) 지원

7. `KIDK/Presentation/ViewModel/Parent/ParentChildWalletViewModel.swift`
- 목적: Wallet UI 변경에도 데이터 계약 유지
- 변경 포인트:
  - 최근 거래 정렬/개수 제한/빈 상태 판단용 가공값 명시화

8. `KIDK/Presentation/ViewModel/ParentApprovalViewModel.swift`
- 목적: 승인 리스트 Timeline 렌더링용 표시 모델 안정화
- 변경 포인트:
  - 표시용 메타(상태/시간/제목) 매핑 책임 정리

9. `KIDK/Presentation/Coordinator/MainTabBarCoordinator.swift` (필요 시)
- 목적: 부모 로그아웃 후 루트 전환 보장
- 변경 포인트:
  - `ParentChildInfo` 로그아웃 이벤트가 Coordinator logout 경로로 연결되는지 명시 검증

---

## 3-2. 신규 파일 추가(권장)

1. `KIDK/Presentation/View/Parent/ParentTimelineSummaryCardView.swift`
- 아이 정보 탭 상단 성장 요약 카드 공통화

2. `KIDK/Presentation/View/Parent/ParentTimelineStatCardView.swift`
- 지표 카드(지출/저축/사용률) 공통화

3. `KIDK/Presentation/View/Parent/ParentTimelineRowView.swift`
- 승인/거래/완료미션 공용 Timeline row 베이스

4. `KIDK/Presentation/View/Parent/ParentStatusBadgeView.swift`
- 상태 배지 공통 컴포넌트

5. `KIDK/Presentation/View/Parent/ParentEmptyStateCardView.swift`
- 빈 상태 공통 컴포넌트

6. `KIDK/Presentation/View/Parent/ParentDesignTokens.swift`
- Parent 전용 토큰(카드 패딩/배지 높이/타이포 alias) 정리

> 참고: `MonthlyStatsSummaryView.swift`, `MissionCompletionBadge.swift`는 사용처 재확인 후 단계적 정리(삭제/통합) 후보

---

## 4) 단계별 구현 순서 (리스크 낮은 순)

### Phase 1. 공통 토큰/컴포넌트 추출 (UI 동일 유지)
- 정보 탭 내부 private 뷰를 외부 파일로 분리
- 기존 화면 출력이 동일한지 먼저 확인

### Phase 2. 공통 헤더/배지/빈상태 적용
- `SectionHeaderView`, `ParentStatusBadgeView`, `ParentEmptyStateCardView`부터 적용
- 로직 변경 없이 스타일 일관성 확보

### Phase 3. 아이 지갑 탭 Timeline화
- 거래 리스트를 Timeline row 구조로 전환
- 기존 데이터 바인딩(최근 5개, 새로고침) 유지

### Phase 4. 승인 대기 탭 Timeline화
- 승인 카드를 Timeline 톤으로 정렬
- 선택 시 상세 push, pull-to-refresh, 알림 기반 갱신 유지

### Phase 5. 로그아웃/탭 이동 회귀 보강
- 부모 로그아웃 플로우 실제 화면 전환 확인
- 탭 전환/복귀 시 데이터 갱신 동작 점검

### Phase 6. 잔여 컴포넌트 정리
- 중복 컴포넌트 제거/통합
- 미사용 파일 정리(2차)

---

## 5) 기능 유지 체크포인트 (바인딩/로그아웃/탭 이동)

### 5-1. 바인딩 유지

### 승인 대기
- [ ] `viewWillAppear` 진입 시 목록 로드
- [ ] pull-to-refresh 시 목록 재조회
- [ ] 셀 선택 → 상세 화면 push
- [ ] 승인/거절 알림 수신 후 목록 자동 갱신

### 아이 지갑
- [ ] `viewDidLoad`, refresh 트리거 시 데이터 로드
- [ ] 총 잔액 = 계좌 합계 일치
- [ ] 최근 거래 개수 제한(현재 정책 5개) 유지

### 아이 정보
- [ ] childInfo/monthlyStats/completedMissions 바인딩 유지
- [ ] 완료 미션 정렬(최신순) 및 최대 표시 개수 정책 유지

---

### 5-2. 로그아웃 유지
- [ ] 로그아웃 버튼 탭 시 확인 Alert 노출
- [ ] Confirm 시 `saveAutoLoginPreference(false)` 호출 유지
- [ ] Confirm 시 `saveLoginCredentials(email: "")` 호출 유지
- [ ] 로그아웃 후 로그인 화면 복귀 경로 실동작 확인

---

### 5-3. 탭 이동 유지
- [ ] Parent 탭 순서/아이콘/타이틀 유지(승인 대기-아이 지갑-아이 정보)
- [ ] 각 탭의 Navigation stack 독립성 유지
- [ ] 승인 상세 push 후 탭 전환/복귀 시 상태 이상 없음

---

## 6) 빌드 확인 포인트

### 6-1. 컴파일 빌드
- 권장 명령:
```bash
xcodebuild -project /Users/piri/shared/active/KIDK-iOS/KIDK.xcodeproj \
  -scheme KIDK \
  -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  build
```

### 6-2. 수동 스모크 시나리오
1. 부모 계정 로그인 → 3탭 정상 진입
2. 승인 대기 탭: 목록/빈상태/상세 진입
3. 아이 지갑 탭: 총잔액/최근거래/빈상태
4. 아이 정보 탭: 성장요약/통계/타임라인/로그아웃
5. 로그아웃 수행 후 로그인 화면 복귀

### 6-3. UI 안정성
- [ ] 작은 화면(예: iPhone SE급)에서 줄바꿈/겹침 없음
- [ ] Dynamic Type 확대 시 카드 레이아웃 붕괴 없음
- [ ] 스크롤 인디케이터/하단 액션바/SafeArea 충돌 없음

---

## 7) 의사결정 포인트(착수 전 확정 필요)

1. 최근 거래/승인/완료미션의 **표시 개수 정책 통일 여부**
   - 현재: 거래 5개, 완료미션 7개, 승인 무제한
2. 부모 로그아웃의 **공식 라우팅 방식**
   - Notification 유지 vs Coordinator delegate로 일원화
3. 미사용 컴포넌트(`MonthlyStatsSummaryView`, `MissionCompletionBadge`) 처리 시점
   - 1차 유지 후 2차 정리 권장

---

## 결론

- 기준 디자인은 `ParentChildInfo`의 Timeline Progress 톤으로 잡고,
- 이를 승인/지갑 탭까지 확장해 **부모 3탭을 하나의 시각 언어**로 통일한다.
- 구현은 **컴포넌트 추출 → 저위험 스타일 통일 → 탭별 전환 → 회귀 검증** 순으로 진행한다.
- 핵심은 “보이는 UI 통일”과 함께 기존 바인딩/로그아웃/탭 이동 동작을 **깨지지 않게 유지**하는 것이다.
