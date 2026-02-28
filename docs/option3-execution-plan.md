# KIDK-iOS 옵션3 실행 계획서 (하이브리드)

작성일: 2026-02-28  
대상 프로젝트: `/Users/piri/shared/active/KIDK-iOS`

---

## 0) 목표/범위

이 문서는 **옵션3**(하이브리드)를 실제 구현하기 위한 실행 계획서다.

- **루트 화면**: 공통 커스텀 헤더(`KIDKRootHeaderView`) 사용
- **상세 화면**: 시스템 `UINavigationBar` + **inline title** 사용
- **nav/tab 상태**: 각 VC에서 직접 토글하지 않고, **Coordinator 중앙관리**

> 현재 단계는 계획만 수행하며, 코드 수정/커밋은 수행하지 않음.

---

## 1) 수정 대상 파일 목록(예상) + 변경 목적

아래는 실제 구현 시 수정/추가가 예상되는 파일들이다.

## A. 신규 파일 (예상)

1. `KIDK/Presentation/View/Common/KIDKRootHeaderView.swift`
   - 목적: 루트 공통 헤더 컴포넌트 신설 (타이틀 + 좌/우 액션 버튼 옵션)

2. `KIDK/Presentation/Coordinator/NavigationChromePolicy.swift`
   - 목적: 화면별 nav/tab 상태를 표현하는 정책 모델 정의
   - 예: `navBarHidden`, `tabBarHidden`, `titleMode(.inline)`

3. `KIDK/Presentation/Coordinator/NavigationChromeManager.swift`
   - 목적: `UINavigationControllerDelegate` 기반으로 화면 전환 시 nav/tab 상태를 중앙 적용

4. `KIDK/Presentation/Coordinator/ScreenChromeRegistry.swift` (또는 MainTabBarCoordinator 내부 private 매핑)
   - 목적: 화면군별 정책 매핑(루트/상세/게임/모달)

---

## B. 기존 파일 수정 (핵심)

### Coordinator 계층

1. `KIDK/Presentation/Coordinator/MainTabBarCoordinator.swift`
   - 목적:
     - 각 탭 `UINavigationController`에 `NavigationChromeManager` 연결
     - child/parent 모두 동일한 정책 엔진으로 nav/tab 제어
     - 기존 `setNavigationBarHidden(true)` 초기 고정 로직을 정책 기반으로 이관

2. `KIDK/Presentation/Coordinator/AccountCoordinator.swift`
   - 목적:
     - Account 탭 내 push 경로를 coordinator 경유로 정리(가능 범위)
     - 루트/상세 chrome 정책 적용 지점 명확화

3. `KIDK/Presentation/Coordinator/MissionCoordinator.swift`
   - 목적:
     - KIDKCity 진입/이탈 상태를 coordinator 정책으로 관리
     - VC 내부 nav/tab 토글 제거 후 정책 적용

4. `KIDK/Presentation/Coordinator/SavingsCoordinator.swift`
   - 목적:
     - savings 상세 이동 시 상세 정책(inline + tab hide 여부) 일관 적용

5. `KIDK/Presentation/Coordinator/SettingsCoordinator.swift`
   - 목적:
     - 설정 루트 정책(커스텀 헤더 + nav hidden) 적용

> 선택(권장): 부모 탭도 전용 coordinator 분리
- `ParentApprovalCoordinator.swift` (신규)
- `ParentWalletCoordinator.swift` (신규)
- `ParentInfoCoordinator.swift` (신규)

이렇게 분리하면 부모 탭도 child 탭과 동일하게 중앙관리 구조가 됨.

---

### Base/UI 공통

6. `KIDK/Presentation/Base/BaseViewController.swift`
   - 목적:
     - 전역 appearance 정리(large title 기본 비활성, back button 텍스트 정책)
     - 단, 화면별 hidden/show 결정은 coordinator가 담당

---

### 루트 화면(커스텀 헤더 적용 대상)

7. `KIDK/Presentation/View/Account/AccountViewController.swift`
   - 목적: 루트 공통 헤더 적용 + 기존 상단 구조와 간격 재정렬

8. `KIDK/Presentation/View/Mission/MissionViewController.swift`
   - 목적: 현재 개별 커스텀 navigationBar를 공통 헤더로 교체

9. `KIDK/Presentation/View/Settings/SettingsViewController.swift`
   - 목적: 단일 titleLabel 기반 상단영역을 공통 헤더로 교체

10. `KIDK/Presentation/View/Parent/ParentApprovalViewController.swift`
    - 목적: large title 제거 후 루트 공통 헤더 적용

11. `KIDK/Presentation/View/Parent/ParentChildWalletViewController.swift`
    - 목적: large title 제거 후 루트 공통 헤더 적용

12. `KIDK/Presentation/View/Parent/ParentChildInfoViewController.swift`
    - 목적: large title 제거 후 루트 공통 헤더 적용

---

### 상세 화면(inline 정책 정리 대상)

13. `KIDK/Presentation/View/Wallet/WalletViewController.swift`
    - 목적: `prefersLargeTitles = true` 제거, inline title로 통일

14. `KIDK/Presentation/View/Saving/SavingsViewController.swift`
    - 목적: inline title 유지 + coordinator 정책과 충돌 제거

15. `KIDK/Presentation/View/Saving/SavingsDetailViewController.swift`
    - 목적: inline detail 표준 확인 및 중복 타이틀 여부 점검

16. `KIDK/Presentation/View/Wallet/TransferViewController.swift`
    - 목적: 상단 내부 `titleLabel`과 시스템 title 중복 해소(시스템 inline 기준으로 정리)

17. `KIDK/Presentation/View/Wallet/ReceiptScanViewController.swift`
    - 목적: 상단 내부 `titleLabel` 중복 해소 + inline 기준 정리

18. `KIDK/Presentation/View/Profile/ProfileViewController.swift`
    - 목적: `setNavigationBarHidden(false)` 직접 호출 제거(정책 기반)

19. `KIDK/Presentation/View/Parent/VerificationDetailViewController.swift`
    - 목적: inline detail 정책 확인 및 tab hide/show 정책 일치

20. `KIDK/Presentation/View/Mission/MissionVerificationViewController.swift`
    - 목적: 모달 내 inline/close 버튼 정책 확인

21. `KIDK/Presentation/View/Mission/KidkCity/KIDKCityViewController.swift`
    - 목적: `viewWillAppear/viewWillDisappear`의 nav/tab 직접 토글 제거

---

### 탭 컨테이너

22. `KIDK/Presentation/View/MainTabBarController.swift`
23. `KIDK/Presentation/View/Parent/ParentTabBarController.swift`
- 목적: 중앙관리 매니저가 tab 상태 반영할 때 충돌 없도록 최소 조정

---

## 2) 단계별 구현 순서

## Phase 1 — 기반 정책 레이어 구축
1. `NavigationChromePolicy / Manager` 신규 구현
2. `MainTabBarCoordinator`에서 각 탭 navController에 manager 주입
3. 화면군 매핑 테이블 등록 (루트/상세/게임/모달)
4. `BaseViewController` appearance 최소 정리(large title off 기본값)

**완료 조건**: 화면 전환 시 VC 내부 직접 토글 없이도 nav/tab 상태가 정책대로 반영됨.

---

## Phase 2 — 루트 공통 헤더 컴포넌트 도입
1. `KIDKRootHeaderView` 구현 (타이틀/좌우 액션)
2. Child 루트 3개(Account/Mission/Settings) 적용
3. Parent 루트 3개(Approval/ChildWallet/ChildInfo) 적용

**완료 조건**: 모든 탭 루트 화면 상단이 동일한 컴포넌트/높이/여백 규칙 사용.

---

## Phase 3 — 상세 화면 inline 정책 통일
1. Wallet/Parent 루트의 large title 제거
2. detail 화면(Transfer/ReceiptScan 등)의 중복 타이틀 제거
3. 기존 detail title은 `title`/`navigationItem.title`로 통일

**완료 조건**: 상세 진입 시 시스템 inline title만 표시되고 large title 미사용.

---

## Phase 4 — VC 직접 제어 코드 제거
1. `KIDKCityViewController`의 nav/tab 직접 토글 제거
2. `ProfileViewController`, 필요 시 `SignupViewController`의 직접 nav 제어 제거
3. 정책/코디네이터 외부에서 `setNavigationBarHidden`, `tabBar.isHidden` 호출 금지 규칙 적용

**완료 조건**: nav/tab 상태 변경 코드가 coordinator/manager에만 존재.

---

## Phase 5 — 회귀 테스트 및 배포 준비
1. Child/Parent 핵심 동선 수동 테스트
2. interactive pop(스와이프 백) 시 깜빡임 여부 확인
3. archive/build 검증 및 TestFlight 업로드

---

## 3) nav/tab 상태 중앙관리 규칙

아래 규칙을 `ScreenChromeRegistry` 기준으로 고정한다.

| 화면군 | 대상 화면(예시) | Navigation Bar | Tab Bar |
|---|---|---|---|
| **Root-Child** | Account, Mission, Settings | **Hidden** (공통 커스텀 헤더 사용) | **Show** |
| **Root-Parent** | ParentApproval, ParentChildWallet, ParentChildInfo | **Hidden** (공통 커스텀 헤더 사용) | **Show** |
| **Detail-Push** | Wallet, Savings, SavingsDetail, Profile, Transfer, ReceiptScan, VerificationDetail 등 | **Show (inline)** | **Hide** *(권장)* |
| **FullScreen/Game** | KIDKCity | **Hidden** | **Hidden** |
| **Modal-EmbeddedNav** | MissionVerification(FullScreen+Nav), 기타 모달 | **Show (inline)** | Host tab 영향 없음 |

### 정책 적용 우선순위
1. 명시 정책(VC type 매핑)
2. 명시 정책 없으면 depth 기반 fallback
   - root(depth=1): nav hidden + tab show
   - detail(depth>1): nav inline + tab hide

---

## 4) large title / inline 정책 통일안

1. **Large Title 전면 비활성화**
   - `prefersLargeTitles = false`
   - 기존 `WalletViewController`, `Parent*RootVC`의 large title 설정 제거

2. **루트 화면은 시스템 nav title 미사용**
   - 루트는 `KIDKRootHeaderView`가 타이틀 책임
   - 따라서 nav bar는 hidden

3. **상세 화면은 시스템 inline title만 사용**
   - `navigationItem.largeTitleDisplayMode = .never`
   - 내부 상단 대제목(`titleLabel`)이 시스템 title과 중복되면 제거/격하

4. **모달도 inline 기준 통일**
   - 닫기/뒤로 액션은 `navigationItem` 버튼으로 관리

---

## 5) 빌드 커맨드 및 TestFlight 업로드 커맨드 후보

사전 확인 결과(현재 저장소 기준):
- `fastlane/` 디렉토리 없음
- `Fastfile`, `Appfile`, `Gymfile` 없음
- 배포 스크립트(`*.sh`) 없음
- Scheme: `KIDK` (xcodebuild 확인)

따라서 **xcodebuild 기반**을 기본 후보로 제시한다.

## 5-1. 로컬 빌드 후보

```bash
# 패키지 해석
xcodebuild -resolvePackageDependencies -project KIDK.xcodeproj -scheme KIDK

# Debug 시뮬레이터 빌드
xcodebuild \
  -project KIDK.xcodeproj \
  -scheme KIDK \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  clean build
```

## 5-2. Release Archive 후보

```bash
xcodebuild \
  -project KIDK.xcodeproj \
  -scheme KIDK \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -archivePath build/KIDK.xcarchive \
  clean archive
```

## 5-3. IPA Export 후보

```bash
xcodebuild \
  -exportArchive \
  -archivePath build/KIDK.xcarchive \
  -exportOptionsPlist ExportOptions-AppStore.plist \
  -exportPath build/export
```

> `ExportOptions-AppStore.plist`는 프로젝트에 현재 없으므로 신규 생성 필요.

## 5-4. TestFlight 업로드 후보

### A안: xcrun altool (API Key)
```bash
xcrun altool --upload-app --type ios \
  --file build/export/KIDK.ipa \
  --apiKey $APP_STORE_CONNECT_API_KEY_ID \
  --apiIssuer $APP_STORE_CONNECT_ISSUER_ID
```

### B안: iTMSTransporter
```bash
xcrun iTMSTransporter -m upload \
  -assetFile build/export/KIDK.ipa \
  -apiKey $APP_STORE_CONNECT_API_KEY_ID \
  -apiIssuer $APP_STORE_CONNECT_ISSUER_ID
```

### C안(향후 fastlane 도입 시)
```bash
bundle exec fastlane pilot upload \
  --ipa build/export/KIDK.ipa \
  --skip_waiting_for_build_processing true
```

---

## 6) 리스크와 롤백 포인트

## 주요 리스크

1. **interactive pop 중 nav/tab 깜빡임**
   - 원인: 기존 VC 직접 토글 코드와 중앙 정책 충돌
   - 대응: VC 직접 토글 코드 완전 제거 후 delegate 단일화

2. **상단 여백 깨짐(루트 헤더 교체 후)**
   - 원인: 기존 상단 제약 조건이 safeArea 기준으로 하드코딩
   - 대응: 루트 헤더 하단 anchor 기준으로 컨텐츠 시작점 재배치

3. **상세 화면 title 중복 노출**
   - 원인: 내부 `titleLabel` + 시스템 inline 동시 존재
   - 대응: 대상 화면(Transfer/ReceiptScan 등) 우선 제거

4. **부모 플로우의 push 경로 분산**
   - 원인: VC 내부 push 코드 존재
   - 대응: 최소한 chrome 정책은 delegate에서 강제, 이후 push ownership 단계적 coordinator 이관

5. **tab hide 정책 UX 변경**
   - 원인: 기존엔 일부 detail에서 tab 보이던 흐름
   - 대응: QA에서 동선별 사용성 확인 후 예외 화면 화이트리스트 적용

---

## 롤백 포인트 (단계별)

- **RP1 (Phase 1 직후)**: `NavigationChromeManager` 연결만 revert하면 기존 동작 복귀
- **RP2 (Phase 2 직후)**: `KIDKRootHeaderView` 적용 화면별로 개별 되돌리기 가능
- **RP3 (Phase 3 직후)**: large title 제거 커밋 단위로 복원 가능
- **RP4 (Phase 4 직후)**: VC 직접 토글 제거분만 선택 revert 가능

권장: Phase별 PR/커밋 분리로 롤백 비용 최소화

---

## 구현 체크리스트 (Codex 실행용)

- [ ] `NavigationChromePolicy/Manager` 신규 추가
- [ ] MainTabBarCoordinator에 중앙 chrome 주입
- [ ] Root 공통 헤더 컴포넌트 생성
- [ ] Child/Parent 루트 6개 화면 헤더 교체
- [ ] Large title 설정 전량 제거
- [ ] 상세 화면 중복 title 정리
- [ ] KIDKCity/Profile의 직접 nav/tab 제어 제거
- [ ] Build + Archive + Upload 명령 검증

---

이 문서는 **옵션3 구현 실행 계획**이며, 코드 변경은 포함하지 않는다.
