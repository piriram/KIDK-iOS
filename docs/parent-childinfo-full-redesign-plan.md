# ParentChildInfo(아이 정보 탭) 풀 리디자인 계획서

작성일: 2026-02-28  
대상 프로젝트: `/Users/piri/shared/active/KIDK-iOS`  
대상 화면: 부모 로그인 후 진입하는 `아이 정보` 탭 (`ParentChildInfo`)

> 본 문서는 **계획서만** 다루며, 코드 수정/커밋은 포함하지 않는다.  
> 전제: 기존 기능(로그아웃, 통계 표시, 완료 미션 표시)은 유지한다.

---

## 1) 현재 ParentChildInfo 구현 분석

## 1-1. 현재 정보 구조(UI 구성)

현재 화면은 `UIScrollView + UIStackView`에 카드들을 세로로 적층하는 구조다.

- 파일: `KIDK/Presentation/View/Parent/ParentChildInfoViewController.swift`
- 핵심 레이아웃(115~134줄):
  1. `ChildInfoHeaderView` (아이 프로필/레벨/KP)
  2. `MonthlyStatsSummaryView` (지출/저축/한도 사용률)
  3. 완료 미션 섹션 헤더 + 카드
  4. 계정 카드 + 로그아웃 버튼

즉, 현재는 **카드 단위 나열형 레이아웃**이며, 상하 길이가 길고 섹션 간 정보 계층(우선순위)의 대비가 상대적으로 약하다.

## 1-2. 데이터 바인딩/흐름 분석

- 파일: `KIDK/Presentation/ViewModel/Parent/ParentChildInfoViewModel.swift`
- Input: `viewDidLoad` 1회 트리거
- Output:
  - `childInfo: Driver<ChildInfo>`
  - `monthlyStats: Driver<MonthlyStats>`
  - `completedMissions: Driver<[Mission]>`
  - `isLoading`, `error`

데이터 구성 방식:

1) **아이 정보**
- `createMockChildInfo()` 기반으로 이름/레벨/KP를 구성
- 계좌 목록에서 총 잔액(`totalBalance`)만 합산 반영

2) **통계**
- `totalSpending = 45000`, `totalSavings = 25000`, `dailyLimit = 10000`으로 현재는 하드코딩(mock)
- `usagePercentage` 역시 해당 mock 값으로 계산

3) **완료 미션**
- `missionRepository.fetchMissionsByStatus(.completed, for: "child-001")`
- 완료 상태 미션만 가져오고 VC에서 `prefix(5)`로 5개까지 표시

## 1-3. 기능 분석 (요구 3개 항목 중심)

### A. 로그아웃 기능
- 파일: `ParentChildInfoViewController.swift` 392~419줄
- 동작:
  - 확인 Alert 노출
  - `authRepository.saveAutoLoginPreference(false)`
  - `authRepository.saveLoginCredentials(email: "")`
  - `.userLoggedOut` Notification 발행

유지 포인트:
- 확인 알럿 UX
- 세션/자동로그인 해제
- 로그아웃 후 앱 플로우 전환 트리거(현재는 Notification 발행 방식)

### B. 통계 기능
- 파일: `MonthlyStatsSummaryView.swift`
- 표시 항목:
  - 총 지출
  - 총 저축
  - 월 한도 사용률(% 텍스트 + 원형 프로그레스)
  - 일일 사용 한도

현 상태 특징:
- 원형 그래프가 200pt 고정(115~119줄)이라 작은 화면에서 세로 밀도가 높아짐
- 데이터 소스는 현재 mock 중심

### C. 완료 미션 표시 기능
- 파일: `ParentChildInfoViewController.swift` 261~388줄
- 동작:
  - 상단 배지에 완료 개수 표시
  - 최근 완료 미션 최대 5개 행 렌더링
  - 0개면 빈 상태 카드 노출

유지 포인트:
- 완료 개수/리스트/빈 상태 3요소 유지
- 최대 5개 제한 유지

## 1-4. 현재 구조의 개선 필요점

1. **정보 계층 약함**: 요약/통계/리스트/액션이 모두 유사한 카드 톤으로 나열됨  
2. **시각적 밀도 비효율**: 큰 원형 그래프 + 다단 카드로 세로 길이 증가  
3. **작은 화면 안정성 리스크**: 고정 크기 컴포넌트(예: 200pt 그래프) 의존  
4. **바인딩 응집도 부족**: ViewModel 데이터가 UI 섹션별 상태로 묶이지 않음  
5. **확장성 제한**: 현재 스택뷰 직접 조립 방식은 섹션 확장/재정렬 비용이 큼

---

## 2) 리디자인 제안 (기존 레이아웃 유지 금지 반영)

## 2-1. 새 화면 구조(IA)

기존의 단순 카드 적층을 버리고, **섹션 기반 콘텐츠 + 고정 하단 액션바** 구조로 재편한다.

```text
[커스텀 네비게이션 헤더: 아이 정보]

[Collection/List 콘텐츠 영역]
  1) 상단 요약 영역
  2) 통계 카드 영역
  3) 완료 미션 리스트/빈 상태

[고정 하단 액션 영역]
  - 로그아웃 안내 + 로그아웃 버튼
```

핵심 차이:
- 기존: 액션 카드도 스크롤 내부
- 변경: **하단 액션 영역 고정**(항상 접근 가능)

## 2-2. 화면 구성 방식(기술 제안)

`ParentChildInfoViewController`를 아래 구조로 재구성:

- 상단: `KIDKNavigationHeaderView` 유지
- 본문: `UICollectionView`(또는 섹션형 리스트)로 3개 콘텐츠 섹션 관리
- 하단: `ParentChildInfoActionBarView` 고정
- 스크롤 인셋: 하단 액션바 높이만큼 `contentInset`/`scrollIndicatorInsets` 적용

이 방식은 섹션 확장성(예: 통계 카드 추가, 미션 행 타입 분기)에 유리하고, 작은 화면 대응이 쉽다.

---

## 3) 섹션별 상세 UI 설계

## 3-1. 상단 요약 영역 (Summary)

목표: 화면 진입 즉시 “누구의 정보인지 + 핵심 상태”를 1눈에 파악

구성:
- 프로필 이미지
- 아이 이름(강조)
- 보조 텍스트(예: 닉네임 또는 “우리 아이”)
- 핵심 칩/메트릭 2~3개
  - 레벨
  - 보유 KP
  - (선택) 총 잔액

표현 원칙:
- 타이틀 폰트 > 메트릭 폰트 > 보조 텍스트 계층 명확화
- 현재 `ChildInfoHeaderView`보다 상단 여백/텍스트 밀도 최적화
- 한 줄/두 줄 대응(이름 길어도 안전)

## 3-2. 통계 카드 영역 (Stats)

목표: 숫자 이해 속도 개선 + 작은 화면에서도 안정적인 밀도

구성(권장 2x2 카드):
- 카드1: 총 지출
- 카드2: 총 저축
- 카드3: 월 한도 사용률(%)
- 카드4: 일일 한도

시각화:
- 기존 대형 원형 그래프 대신
  - 카드 내 미니 프로그레스 바/퍼센트 강조
  - 또는 compact ring(소형) 채택
- 작은 화면(iPhone mini/SE 폭)에서는 1열 스택으로 자동 전환

## 3-3. 완료 미션 리스트/빈 상태 (Completed Missions)

목표: 완료 내역을 빠르게 스캔 가능하게 구성

구성:
- 섹션 헤더: “완료 미션” + 완료 개수 배지
- 리스트: 최근 완료 5개
  - 미션 제목
  - 보상 금액
  - 상태 배지(완료)
- 빈 상태:
  - 아이콘 + 안내 텍스트 2줄
  - “아직 완료 미션이 없어요” 메시지 유지

동작 유지:
- 최대 5개 표시 유지 (`prefix(5)`)
- 0개일 때 빈 상태 표시 유지

## 3-4. 하단 액션 영역 (Bottom Action)

목표: 파괴적 액션(로그아웃)의 가시성/안전성 확보

구성:
- 설명 텍스트(로그아웃 안내)
- `로그아웃` 버튼(Destructive 스타일)
- Safe Area 대응 고정 바

UX:
- 탭 영역 최소 44pt 이상
- 기존과 동일하게 확인 Alert 필수
- 버튼은 스크롤에 묻히지 않도록 고정

---

## 4) 디자인 목표와 적용 기준

| 디자인 목표 | 적용 기준 | 구현 가이드 |
|---|---|---|
| 가독성 | 주요 숫자/이름의 즉시 인지 | 요약 카드 타이포 대비 강화, 보조텍스트 명도 낮춤 |
| 정보 계층 | 요약 > 통계 > 완료 미션 > 액션 순서 고정 | 섹션 단위 간격/헤더 스타일 차등 적용 |
| 시각적 밀도 | 같은 정보량을 더 짧은 세로 길이로 | 대형 원형 그래프 축소/대체, 카드 내용 압축 |
| 작은 화면 안정성 | 320~375폭에서 줄바꿈/잘림 없이 동작 | 카드 2열→1열 전환, 고정 높이 최소화 |
| iOS 사용성 | 터치/접근성/스크롤 품질 | 44pt 탭 타깃, 접근성 라벨, 하단 고정 액션 + 인셋 |

---

## 5) 파일별 수정 계획 (구현 가능한 수준)

## 5-1. 기존 파일 수정(필수)

1. `KIDK/Presentation/View/Parent/ParentChildInfoViewController.swift`
- 역할: 화면 골격 전면 재구성(핵심)
- 변경 내용:
  - `UIScrollView + UIStackView` 기반 제거
  - 섹션형 콘텐츠 뷰(컬렉션/리스트) 도입
  - 하단 고정 `ActionBar` 배치
  - 기존 바인딩(`childInfo`, `monthlyStats`, `completedMissions`)을 섹션 데이터로 매핑
  - 로그아웃 알럿/실행 로직 유지

2. `KIDK/Presentation/ViewModel/Parent/ParentChildInfoViewModel.swift`
- 역할: 섹션 렌더링에 필요한 상태 가공
- 변경 내용:
  - 기존 Output 유지 + (권장) `viewState` 형태로 UI 가공 모델 제공
  - 통계 계산/완료 미션 정렬/제한 로직을 함수로 분리
  - 하드코딩 의존(`child-001`, mock stat)은 1차 유지 가능하나 주석/분리로 명확화

3. `KIDK/Presentation/Coordinator/MainTabBarCoordinator.swift` (조건부)
- 역할: ViewModel init 인자 확장 시 연결
- 변경 내용(필요 시): child 식별값 전달 경로 추가

## 5-2. 신규 파일 추가(권장)

1. `KIDK/Presentation/View/Parent/ParentChildInfoSummaryCardView.swift`
- 상단 요약 카드 전용 뷰

2. `KIDK/Presentation/View/Parent/ParentChildInfoStatsGridView.swift`
- 통계 카드 2x2(또는 반응형 1열) 전용 뷰

3. `KIDK/Presentation/View/Parent/ParentChildInfoMissionRowView.swift`
- 완료 미션 단일 행 UI

4. `KIDK/Presentation/View/Parent/ParentChildInfoMissionEmptyView.swift`
- 완료 미션 0건 상태 UI

5. `KIDK/Presentation/View/Parent/ParentChildInfoActionBarView.swift`
- 하단 고정 액션 영역(설명 + 로그아웃 버튼)

6. `KIDK/Presentation/ViewModel/Parent/ParentChildInfoViewState.swift` (또는 ViewModel 내부 중첩)
- 섹션 렌더링용 상태 모델

## 5-3. 기존 보조 뷰 정리(2차)

아래 파일은 새 설계 적용 후 사용처를 점검해 단계적으로 정리 가능:
- `ChildInfoHeaderView.swift`
- `MonthlyStatsSummaryView.swift`
- `MissionCompletionBadge.swift`

(단, 즉시 삭제보다 “새 화면 안정화 후 정리”를 권장)

---

## 6) 단계별 구현 순서

## Phase 0. 사전 고정
- 기존 기능 유지 기준 정의
  - 로그아웃 Alert/실행 유지
  - 통계 4항목 표시 유지
  - 완료 미션 최대 5개 + 빈 상태 유지

## Phase 1. 상태 모델 정리(ViewModel)
- `ParentChildInfoViewState` 정의
- 기존 Output 데이터를 섹션 친화형으로 변환
- 로직 분리(통계 계산, 미션 리스트 가공)

## Phase 2. 새 UI 컴포넌트 구현
- Summary/Stats/MissionRow/Empty/ActionBar 뷰 개별 구현
- 샘플 데이터로 레이아웃 검증

## Phase 3. ViewController 재구성
- 컬렉션/리스트 섹션 구성
- 하단 고정 액션바 + safe area 인셋 연결
- 기존 update 메서드를 snapshot/apply 방식으로 교체

## Phase 4. 바인딩/인터랙션 연결
- ViewModel Output → 섹션 렌더링 연결
- 로딩/에러/로그아웃 액션 연결
- 기존 로그아웃 확인 플로우 유지

## Phase 5. 작은 화면/접근성 튜닝
- 320~375폭에서 레이아웃 붕괴 여부 점검
- Dynamic Type, VoiceOver 라벨, 버튼 터치 영역 점검

## Phase 6. 회귀 검증
- 부모 탭 진입 → 아이 정보 노출
- 완료 미션 0개/1~5개/5개 초과 시나리오
- 로그아웃 플로우 전체 확인
- 로딩/에러 표시 확인

---

## 7) QA 체크리스트 (기능 유지 관점)

- [ ] 아이 이름/레벨/KP(및 잔액 표시 시 잔액) 정상 표시
- [ ] 통계 4요소(지출/저축/사용률/일일 한도) 정상 표시
- [ ] 완료 미션이 6개 이상이어도 5개까지만 표시
- [ ] 완료 미션 0개면 빈 상태 UI 노출
- [ ] 로그아웃 버튼 탭 시 확인 Alert 노출
- [ ] 확인 시 자동로그인 해제 및 로그아웃 후속 플로우 정상
- [ ] 작은 화면에서 요소 겹침/잘림 없음
- [ ] 탭바 + 하단 액션바 + 스크롤 인셋 충돌 없음

---

## 8) 리스크 및 대응

1. **하단 고정 액션바와 탭바 충돌**
- 대응: safeArea 기준 제약 + `contentInset.bottom` 명시

2. **기존 mock 데이터와 새 UI 기대치 불일치**
- 대응: 1차는 기존 데이터 구조 유지, 표시 규칙만 개선

3. **완료 미션 행 높이 변동으로 스크롤 점프**
- 대응: 추정 높이/자동 레이아웃 우선순위 안정화

4. **로그아웃 후속 처리 경로 불명확성**
- 대응: 기존 Notification 방식 유지하되, 회귀 테스트에서 실제 화면 전환 검증 필수

---

## 9) 결론

이번 리디자인은 **레이아웃을 완전히 재구성**하되, 기능 동작은 유지하는 방향이다.

- 정보 구조: 요약 → 통계 → 완료 미션 → 하단 액션
- UX 핵심: 가독성/정보 계층/작은 화면 안정성/고정 액션 접근성
- 구현 전략: ViewModel 상태 정리 + 섹션형 UI + 단계적 마이그레이션

이 계획대로 진행하면 기존 기능 회귀 리스크를 낮추면서도, ParentChildInfo 탭을 “부모가 빠르게 이해하고 즉시 행동할 수 있는 화면”으로 개선할 수 있다.
