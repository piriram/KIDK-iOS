# KIDK Cycle 4 - Tab Icons 정리

## 범위
- 대상 코드: `KIDK/Presentation/View/MainTabBarController.swift`
- 대상 에셋: `KIDK/Resource/Assets.xcassets/tab_*`
- 목표: 탭바 아이콘 24x24 정규화/정렬 안정화, selected/unselected 매핑 점검, 레거시 alias 정리

---

## 문제 원인

1. **아이콘 소스 크기 불일치(30x31)**
   - 현재 `tab_*` SVG 원본은 대부분 `30x31`.
   - 탭바 목표 사이즈(24x24)와 비율/크기가 달라 축소 과정에서 소수점 좌표가 발생할 수 있고, 디바이스 스케일에 따라 미세한 블러/흔들림 가능성이 있음.

2. **매핑 코드가 문자열 리터럴 분산 구조**
   - 탭별 selected/unselected 키와 fallback이 하드코딩으로 분산되어 있어 추후 교체 시 실수 가능성이 있었음.

3. **레거시 잔여 파일 존재**
   - 이미지셋 내부에 `Contents.json`에 등록되지 않은 파일이 남아 있었음.
   - 확인된 잔여 파일:
     - `tab_account_unselected.imageset/Vector.svg`
     - `tab_mission_unselected.imageset/COCO.svg`

---

## 수정 사항

### 1) MainTabBarController 정리
- `TabSpec` enum 도입으로 탭별 정보를 한곳에서 관리:
  - title
  - `unselectedAssetKey`
  - `selectedAssetKey`
  - fallback SF Symbol
- selected/unselected 매핑을 enum 기반 반복 처리로 변경해 오매핑 위험 감소.

### 2) 렌더링 안정화(24x24 정규화)
- 아이콘 정규화 로직 유지 + 개선:
  - 목표 크기 `24x24`
  - `UIGraphicsImageRendererFormat.scale = UIScreen.main.scale` 명시
  - 중앙 정렬 후 `pixelAlignedRect` 처리로 픽셀 경계 정렬
  - 최종 `alwaysTemplate` 유지(탭 상태 색상은 tint 계열로 제어)

### 3) TabBar Appearance 고정
- `UITabBarAppearance`를 사용해 `standardAppearance` + `scrollEdgeAppearance` 동일 적용.
- selected/unselected 아이콘/타이틀 컬러를 appearance에 명시.
- iOS 버전/스크롤 상태에 따른 외형 편차를 줄임.

### 4) 레거시 alias 파일 정리
- 아래 미참조 파일 삭제:
  - `tab_account_unselected.imageset/Vector.svg`
  - `tab_mission_unselected.imageset/COCO.svg`
- 현재 `tab_*` 이미지셋은 `Contents.json` 기준 미참조 파일 없음 확인.

---

## 검증 결과

### A. 24x24 정규화 경로
- 코드 상 모든 탭 아이콘이 `normalizeTabIcon`을 반드시 통과하도록 고정.
- 정규화 후 사이즈는 `24x24` 타겟 기준으로 렌더링됨.

### B. selected/unselected 매핑 점검
- 매핑 결과:
  - account: `tab_account_unselected` / `tab_account_selected`
  - mission: `tab_mission_unselected` / `tab_mission_selected`
  - settings: `tab_settings_unselected` / `tab_settings_selected`
- 코드 경로상 매핑 이상 없음.

### C. Debug 빌드
- 실행 명령:
  - `xcodebuild -project KIDK.xcodeproj -scheme KIDK -configuration Debug -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build`
- 결과: `** BUILD SUCCEEDED **`
- 비고: 기존 프로젝트 경고(Actor isolation/Deprecated API)는 존재하나 이번 변경으로 인한 신규 빌드 실패는 없음.

---

## 남은 에셋 이슈(디자인 원본 관점)

1. **selected/unselected SVG가 실제로 동일 파일 내용**
   - 현재 3쌍 모두 해시 기준 동일.
   - 상태 차이는 템플릿 tint 컬러에 의존.
   - 만약 상태별 모양 차이(채움/외곽선 등)가 필요하면 디자이너 원본 교체 필요.

2. **원본 자체는 30x31 비율 유지 중**
   - 런타임 정규화로 표시는 안정화했지만, 이상적인 기준은 원본도 24x24(또는 배수) 정렬.
   - 추후 디자인 납품 시 `24x24 / 48x48 / 72x72` 스펙으로 교체 권장.
