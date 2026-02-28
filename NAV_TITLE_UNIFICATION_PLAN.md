# Navigation Title Unification Plan
> KIDK-iOS — 네비게이션 타이틀 위치·스타일 통일화 계획
> 작성일: 2026-02-28 | 브랜치: Feat/game-gpt

---

## 목차

1. [현황 분석 (As-Is)](#1-현황-분석-as-is)
2. [근본 원인 분석](#2-근본-원인-분석)
3. [영향 받는 화면 목록](#3-영향-받는-화면-목록)
4. [통일화 전략 (To-Be)](#4-통일화-전략-to-be)
5. [마이그레이션 순서](#5-마이그레이션-순서)
6. [리스크 포인트](#6-리스크-포인트)
7. [회귀 체크리스트](#7-회귀-체크리스트)
8. [검증 단계](#8-검증-단계)

---

## 1. 현황 분석 (As-Is)

### 1.1 네비게이션 아키텍처 개요

```
AppCoordinator
├── AuthCoordinator
└── MainTabBarCoordinator (아이)
    ├── AccountCoordinator  → UINavigationController (navBar HIDDEN)
    ├── MissionCoordinator  → UINavigationController (navBar HIDDEN)
    └── SettingsCoordinator → UINavigationController (navBar HIDDEN)

ParentTabBarController (부모)
├── Tab 0 → UINavigationController (navBar HIDDEN)
├── Tab 1 → UINavigationController (navBar HIDDEN)
└── Tab 2 → UINavigationController (navBar HIDDEN)
```

- 모든 탭의 루트 NavigationController는 **`setNavigationBarHidden(true)`** 상태
- 화면별로 navBar 노출 여부를 각자 제어 → 일관성 없음

### 1.2 타이틀 표현 방식 현황 (5가지 혼재)

| 방식 | 화면 | 파일 |
|------|------|------|
| **① UIKit Large Title** | WalletViewController, ParentApprovalViewController, ParentChildWalletViewController, ParentChildInfoViewController | `prefersLargeTitles = true` |
| **② UIKit Inline Title** | SavingsViewController, SavingsDetailViewController, TransferViewController, ReceiptScanViewController, MissionVerificationViewController, VerificationDetailViewController | `title = "..."` (기본값) |
| **③ 완전 커스텀 UIView 헤더** | MissionViewController, AccountViewController | 직접 UIView 생성·레이아웃 |
| **④ 게임 HUD 오버레이** | KIDKCityViewController | SpriteKit 위에 커스텀 HUD |
| **⑤ navigationItem.title + 부분 커스텀** | ProfileViewController | navigationItem.title + 추가 커스텀 뷰 |

### 1.3 BaseViewController 전역 설정

```swift
// BaseViewController.swift (라인 57-64)
let appearance = UINavigationBarAppearance()
appearance.configureWithOpaqueBackground()
appearance.backgroundColor = .kidkDarkBackground
appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
```

전역 appearance는 존재하지만 **navBar가 숨겨진 상태에서는 적용되지 않으므로** 커스텀 헤더와 스타일이 분리되어 있음.

---

## 2. 근본 원인 분석

### 원인 A — "navBar 전체 숨김" 정책의 부작용

```swift
// MainTabBarCoordinator.swift 라인 32, 38, 44
accountNav.setNavigationBarHidden(true, animated: false)
missionNav.setNavigationBarHidden(true, animated: false)
settingsNav.setNavigationBarHidden(true, animated: false)
```

루트에서 navBar를 숨겼기 때문에 각 화면이 **독자적으로 헤더 영역을 만들어야 했고**, 개발자마다 다른 방식을 선택했다.

### 원인 B — 높이·상단 여백 기준점 불일치

| 방식 | 헤더 높이 | 상단 기준 |
|------|---------|---------|
| 커스텀 UIView 헤더 (MissionVC) | 고정 88pt | `superview.top` |
| Large Title NavBar | 시스템 자동 (~96pt) | SafeArea top |
| Inline Title NavBar | 시스템 자동 (~44pt) | SafeArea top |
| KIDKCity HUD | 가변 | `safeAreaLayoutGuide.top` |

→ 화면 간 이동 시 타이틀이 **다른 Y 좌표**에 나타남.

### 원인 C — Large/Inline 전환 규칙 부재

`prefersLargeTitles = true` 사용 기준이 없어 아이 탭(Inline)과 부모 탭(Large)이 혼용됨.
같은 앱에서 두 스타일이 공존하면 사용자는 "어디에 있는지" 계층감을 잃는다.

### 원인 C-2 — viewWillAppear/viewWillDisappear의 비대칭 처리

```swift
// KIDKCityViewController
override func viewWillAppear() { navigationController?.setNavigationBarHidden(true) }
override func viewWillDisappear() { navigationController?.setNavigationBarHidden(false) }
```

일부 화면만 appear/disappear에서 navBar를 토글하여, pop 애니메이션 중 타이틀이 **순간 깜빡**이거나 잘못된 위치에 나타나는 현상 발생.

### 원인 D — 커스텀 헤더 컴포넌트 미공유

MissionViewController가 만든 커스텀 헤더와 AccountViewController의 커스텀 헤더가 **서로 다른 코드**로 구현되어 있어, 폰트·색상·높이가 미세하게 다르다.

---

## 3. 영향 받는 화면 목록

### 3.1 아이(Child) 앱

| # | 화면 | 파일 | 현재 방식 | 문제 |
|---|------|------|---------|------|
| 1 | AccountViewController | Account/AccountViewController.swift | 커스텀 UIView 헤더 | 높이·폰트 독자 정의 |
| 2 | WalletViewController | Wallet/WalletViewController.swift | Large Title navBar | 아이 탭에서만 Large Title |
| 3 | SavingsViewController | Saving/SavingsViewController.swift | Inline Title navBar | Large Title 미사용 |
| 4 | SavingsDetailViewController | Saving/SavingsDetailViewController.swift | Inline Title | 뒤로가기 버튼 위치 혼재 |
| 5 | MissionViewController | Mission/MissionViewController.swift | 커스텀 UIView 헤더 88pt | AccountVC 헤더와 높이 다름 |
| 6 | KIDKCityViewController | Mission/KidkCity/KIDKCityViewController.swift | 게임 HUD | navBar 토글 → 깜빡임 |
| 7 | MissionVerificationViewController | Mission/MissionVerificationViewController.swift | Inline (fullScreen modal) | 모달 내 타이틀 위치 다름 |
| 8 | MissionCreationViewController | Mission/MissionCreationViewController.swift | Inline | 진입 경로 2개 (Push/Sheet) |
| 9 | ProfileViewController | Profile/ProfileViewController.swift | navigationItem.title + 커스텀 | 혼합 사용 |
| 10 | TransferViewController | Wallet/TransferViewController.swift | Inline | 일관성 없음 |
| 11 | ReceiptScanViewController | Wallet/ReceiptScanViewController.swift | Inline | 일관성 없음 |
| 12 | SettingsViewController | Settings/SettingsViewController.swift | (확인 필요) | (확인 필요) |

### 3.2 부모(Parent) 앱

| # | 화면 | 파일 | 현재 방식 | 문제 |
|---|------|------|---------|------|
| 13 | ParentApprovalViewController | Parent/ParentApprovalViewController.swift | Large Title | 아이 앱과 스타일 불일치 |
| 14 | ParentChildWalletViewController | Parent/ParentChildWalletViewController.swift | Large Title | 동상이몽 |
| 15 | ParentChildInfoViewController | Parent/ParentChildInfoViewController.swift | Large Title | 동상이몽 |
| 16 | VerificationDetailViewController | Parent/VerificationDetailViewController.swift | Inline | Push detail인데 Inline |

---

## 4. 통일화 전략 (To-Be)

### 4.1 디자인 규칙 (Design Rules)

```
Rule 1. 타이틀 스타일은 "계층 위치"로 결정한다.
  - 탭 루트(Root) 화면  → "커스텀 KIDKHeaderView" (통일 컴포넌트)
  - 2단계 Push 화면     → Inline navBar title (표준)
  - 모달 화면           → Inline navBar title + Close 버튼 (우측)

Rule 2. 타이틀 Y 좌표 기준점을 통일한다.
  - 모든 커스텀 헤더: safeAreaLayoutGuide.top 기준, 높이 56pt
  - 표준 navBar: UIKit 기본값 (prefersLargeTitles = false)

Rule 3. Large Title 사용 금지 (아이·부모 앱 모두)
  - Large Title은 게임 앱의 분위기와 어울리지 않음
  - 부모 탭도 Inline으로 통일

Rule 4. navBar 토글은 appear/disappear가 아닌 Coordinator가 담당한다.
  - KIDKCityViewController처럼 화면 스스로 navBar를 on/off하지 않음
  - Coordinator가 push 전에 상태를 설정

Rule 5. 뒤로가기 버튼 텍스트는 항상 숨긴다.
  - appearance.backButtonAppearance 설정으로 텍스트 제거
```

### 4.2 통일 컴포넌트 설계

#### KIDKNavigationHeaderView (신규 공통 컴포넌트)

```swift
// 위치: KIDK/Presentation/View/Common/KIDKNavigationHeaderView.swift
final class KIDKNavigationHeaderView: UIView {
    // 높이 상수
    static let height: CGFloat = 56

    // 서브뷰
    private let titleLabel: UILabel   // 중앙 정렬 또는 좌측 정렬 (옵션)
    private let leftButton: UIButton? // 뒤로가기 / 닫기 (옵션)
    private let rightButton: UIButton? // 메뉴 / 액션 (옵션)

    // 초기화
    init(title: String, leftAction: ButtonConfig? = nil, rightAction: ButtonConfig? = nil)
}
```

이 컴포넌트를 사용하는 화면:
- MissionViewController (현재 직접 구현 → 교체)
- AccountViewController (현재 직접 구현 → 교체)
- KIDKCityViewController (게임 HUD 제외 상단 타이틀 영역만 → 교체)

#### BaseViewController 업데이트

```swift
// BaseViewController.swift
// 1. prefersLargeTitles 전역 비활성화 추가
navigationController?.navigationBar.prefersLargeTitles = false

// 2. 뒤로가기 텍스트 전역 제거 추가
let backAppearance = UIBarButtonItemAppearance()
backAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
appearance.backButtonAppearance = backAppearance
```

### 4.3 기술적 접근 방식

#### Phase 1 — 기반 작업 (전제 조건)

1. **BaseViewController** appearance에 `prefersLargeTitles = false` 추가
2. **KIDKNavigationHeaderView** 공통 컴포넌트 생성
3. **Coordinator 프로토콜**에 navBar 상태 관리 메서드 정의

#### Phase 2 — 커스텀 헤더 화면 교체

1. `MissionViewController` 커스텀 헤더 → `KIDKNavigationHeaderView`로 교체
2. `AccountViewController` 커스텀 헤더 → `KIDKNavigationHeaderView`로 교체

#### Phase 3 — Large Title → Inline 전환

1. `WalletViewController` `prefersLargeTitles = true` 제거
2. `ParentApprovalViewController` `prefersLargeTitles = true` 제거
3. `ParentChildWalletViewController` `prefersLargeTitles = true` 제거
4. `ParentChildInfoViewController` `prefersLargeTitles = true` 제거

#### Phase 4 — KIDKCity navBar 토글 리팩터

1. `KIDKCityViewController`의 `viewWillAppear/viewWillDisappear` navBar 토글 제거
2. `MissionCoordinator.showKIDKCity()`에서 push 전에 navBar 숨김 처리
3. pop 시 Coordinator에서 복원

#### Phase 5 — 모달 헤더 통일

1. `MissionVerificationViewController` navBar close 버튼 위치/스타일 표준화
2. `MissionCreationViewController` Push/Sheet 두 진입 경로에서 헤더 일관성 확인

---

## 5. 마이그레이션 순서

```
우선순위 기준:
  HIGH   = 모든 사용자가 매 세션 보는 화면
  MEDIUM = 사용 빈도 높으나 진입 조건 있음
  LOW    = 특수 화면 또는 모달
```

| 순서 | Phase | 작업 | 화면 | 우선순위 | 예상 복잡도 |
|------|-------|------|------|---------|-----------|
| 1 | 1 | BaseViewController appearance 업데이트 | 전체 | HIGH | 낮음 |
| 2 | 1 | KIDKNavigationHeaderView 컴포넌트 생성 | (신규) | HIGH | 중간 |
| 3 | 2 | MissionViewController 헤더 교체 | MissionVC | HIGH | 중간 |
| 4 | 2 | AccountViewController 헤더 교체 | AccountVC | HIGH | 중간 |
| 5 | 3 | WalletViewController Large→Inline | WalletVC | HIGH | 낮음 |
| 6 | 4 | KIDKCity navBar 토글 Coordinator 이관 | KIDKCityVC, MissionCoordinator | MEDIUM | 높음 |
| 7 | 3 | Parent 탭 전체 Large→Inline | 4개 화면 | MEDIUM | 낮음 |
| 8 | 5 | MissionVerificationVC 모달 헤더 | MissionVerificationVC | MEDIUM | 낮음 |
| 9 | 5 | MissionCreationVC 경로별 일관성 | MissionCreationVC | LOW | 중간 |
| 10 | 5 | ProfileViewController 헤더 정리 | ProfileVC | LOW | 낮음 |

---

## 6. 리스크 포인트

### 🔴 HIGH RISK

#### R-1: KIDKCityViewController navBar 토글 타이밍

**문제:** `viewWillAppear`/`viewWillDisappear`에서 navBar를 on/off하면 UIKit 내부 상태와 충돌할 수 있음. Pop 제스처(swipe back) 중 navBar가 비정상 위치에 렌더링됨.

**해결 방안:**
```swift
// MissionCoordinator에서 처리
func showKIDKCity() {
    navigationController.setNavigationBarHidden(true, animated: true)
    let vc = KIDKCityViewController(...)
    navigationController.pushViewController(vc, animated: true)
}

// KIDKCityViewController에서 제거
// (viewWillAppear/viewWillDisappear의 setNavigationBarHidden 호출 삭제)
```

**검증:** swipe-back 제스처 + 버튼 뒤로가기 양쪽 테스트 필수

---

#### R-2: Large Title → Inline 전환 후 레이아웃 깨짐

**문제:** `WalletViewController` 등 Large Title 화면은 스크롤 뷰의 contentInset이 Large Title 높이를 기준으로 설정되어 있을 수 있음. Inline 전환 시 **콘텐츠가 navBar 뒤로 가려질 수 있음**.

**해결 방안:**
- 전환 전 `safeAreaInsets`와 `contentInset` 값 확인
- `adjustedContentInset` 기반으로 레이아웃이 되어 있는지 확인
- 스크롤뷰 상단 여백 하드코딩 여부 점검

---

#### R-3: ProfileViewController 혼합 방식 충돌

**문제:** `navigationItem.title`과 커스텀 서브뷰를 동시에 사용하면, navBar appearance 업데이트 시 의도치 않은 중복 렌더링 발생 가능.

**해결 방안:** ProfileVC를 Phase 2에서 KIDKNavigationHeaderView로 완전 교체하거나, navigationItem.title을 제거하고 커스텀 뷰만 사용하도록 결정 후 진행.

---

### 🟡 MEDIUM RISK

#### R-4: MissionCreationViewController 두 진입 경로

Push(KIDKCityVC에서)와 Sheet(MissionVerificationVC에서) 두 경로로 진입하므로, 헤더 상태가 경로마다 다를 수 있음. 양쪽 경로를 모두 테스트해야 함.

#### R-5: 부모 앱 Large → Inline 시 UX 변화

부모 앱 사용자는 현재 Large Title에 익숙할 수 있음. Inline으로 전환 시 화면이 작아 보이는 체감이 있으므로, 디자인팀 확인 후 진행 권장.

---

### 🟢 LOW RISK

#### R-6: BaseViewController appearance 변경의 전역 영향

BaseViewController의 appearance 변경은 모든 자식 VC에 영향을 줌. 단, 이미 `standardAppearance`와 `scrollEdgeAppearance` 모두 설정되어 있으므로 추가 변경의 영향 범위는 제한적.

---

## 7. 회귀 체크리스트

마이그레이션 완료 후 각 화면에서 다음을 확인한다.

### 7.1 공통 체크 (전체 화면)

- [ ] 타이틀 텍스트가 잘리지 않고 완전히 표시되는가
- [ ] 타이틀 Y 좌표가 모든 화면에서 동일한가 (56pt 헤더 기준)
- [ ] 다크/라이트 배경에서 텍스트 색상이 올바른가
- [ ] iPhone SE(작은 화면)에서 레이아웃이 깨지지 않는가
- [ ] iPhone Pro Max(큰 화면)에서 불필요한 여백이 없는가

### 7.2 화면 전환 체크

- [ ] Push 애니메이션 중 타이틀 깜빡임 없음
- [ ] Pop(뒤로가기) 애니메이션 중 타이틀 깜빡임 없음
- [ ] Swipe-back 제스처(interactive pop) 중 navBar 상태 이상 없음
- [ ] Modal present 시 타이틀이 올바른 위치에 나타남
- [ ] Modal dismiss 후 이전 화면 타이틀이 정상 복원됨

### 7.3 화면별 체크

| 화면 | 체크 항목 |
|------|---------|
| AccountVC | 커스텀 헤더 높이 56pt, 폰트·색상 일치 |
| WalletVC | Inline 전환 후 스크롤 콘텐츠 잘림 없음 |
| SavingsVC | 타이틀 위치 WalletVC와 일치 |
| SavingsDetailVC | 뒤로가기 버튼 텍스트 없음 |
| MissionVC | 커스텀 헤더 → KIDKNavigationHeaderView 교체 후 메뉴 버튼 동작 |
| KIDKCityVC | Push/Pop 시 navBar 깜빡임 없음, 게임 HUD 가려짐 없음 |
| MissionVerificationVC | fullScreen 모달 내 Close 버튼 위치 올바름 |
| MissionCreationVC | Push 진입 / Sheet 진입 양쪽에서 헤더 동일 |
| ProfileVC | navigationItem.title 중복 렌더링 없음 |
| ParentApprovalVC | Inline 전환 후 레이아웃 이상 없음 |
| ParentChildWalletVC | ChildInfoHeaderView와 navBar 중첩 없음 |
| VerificationDetailVC | Push detail 뒤로가기 버튼 올바름 |

### 7.4 접근성 체크

- [ ] VoiceOver 활성화 시 타이틀이 올바르게 읽힘
- [ ] Dynamic Type 크기 변경 시 타이틀이 잘리거나 넘치지 않음

---

## 8. 검증 단계

### Step 1: 단위 검증 (컴포넌트 단위)

```
KIDKNavigationHeaderView 생성 후:
1. 다양한 제목 길이 테스트 (1자 ~ 20자)
2. 좌우 버튼 유무 조합별 레이아웃 확인
3. safeAreaLayoutGuide 기준 높이 56pt 확인
4. backgroundColor, titleColor가 디자인 토큰과 일치하는지 확인
```

### Step 2: 화면 단위 검증

```
Phase별 작업 완료 직후 해당 화면 캡처:
- 기기: iPhone 16 Pro (기본) + iPhone SE 3세대 (최소)
- 확인: 타이틀 Y 좌표 = safeAreaTop + 16pt (기대값)
- 도구: Xcode View Debugger로 뷰 계층 확인
```

### Step 3: 화면 간 전환 검증

```
주요 내비게이션 경로 전체 수동 테스트:
경로 A: AccountVC → WalletVC → TransferVC → (뒤로) → (뒤로)
경로 B: AccountVC → SavingsVC → SavingsDetailVC → (뒤로) → (뒤로)
경로 C: MissionVC → KIDKCityVC → (swipe back) → MissionVC
경로 D: MissionVC → KIDKCityVC → MissionCreationVC(Sheet) → (닫기) → KIDKCityVC
경로 E: MissionVC → MissionVerificationVC(modal) → (닫기) → MissionVC
경로 F: ParentApprovalVC → VerificationDetailVC → (뒤로)

각 경로에서:
- 타이틀 위치 일관성 확인
- 애니메이션 중 깜빡임 없음 확인
```

### Step 4: 스냅샷 비교 검증 (선택, 팀 여건에 따라)

```swift
// XCTest + swift-snapshot-testing 사용 시
func testNavTitlePosition_WalletViewController() {
    let vc = WalletViewController(...)
    assertSnapshot(matching: vc, as: .image(on: .iPhone13Pro))
}
```

화면별 스냅샷을 Phase 작업 전·후로 비교하여 의도치 않은 레이아웃 변화 감지.

### Step 5: 최종 통합 검증

```
전체 마이그레이션 완료 후:
1. 아이 앱 전체 플로우 E2E 수동 테스트
2. 부모 앱 전체 플로우 E2E 수동 테스트
3. 디자인팀과 함께 UI 리뷰 세션
4. 회귀 체크리스트 100% 통과 확인
5. PR 리뷰 후 main 머지
```

---

## 부록: 파일 위치 빠른 참조

| 역할 | 파일 경로 |
|------|---------|
| 탭바 (아이) | `KIDK/Presentation/View/MainTabBarController.swift` |
| 탭바 (부모) | `KIDK/Presentation/View/Parent/ParentTabBarController.swift` |
| 탭바 Coordinator | `KIDK/Presentation/Coordinator/MainTabBarCoordinator.swift` |
| 기반 VC (appearance) | `KIDK/Presentation/View/Base/BaseViewController.swift` |
| [신규] 공통 헤더 | `KIDK/Presentation/View/Common/KIDKNavigationHeaderView.swift` |
| Account Coordinator | `KIDK/Presentation/Coordinator/AccountCoordinator.swift` |
| Mission Coordinator | `KIDK/Presentation/Coordinator/MissionCoordinator.swift` |
| Savings Coordinator | `KIDK/Presentation/Coordinator/SavingsCoordinator.swift` |
| MissionVC (헤더 교체 대상) | `KIDK/Presentation/View/Mission/MissionViewController.swift` |
| KIDKCityVC (토글 제거 대상) | `KIDK/Presentation/View/Mission/KidkCity/KIDKCityViewController.swift` |
| WalletVC (Large→Inline) | `KIDK/Presentation/View/Wallet/WalletViewController.swift` |

---

*이 문서는 소스 파일을 수정하지 않고 분석·계획만 담은 플래닝 문서입니다.*
*구현은 팀 리뷰 및 승인 후 별도 브랜치에서 진행하세요.*
