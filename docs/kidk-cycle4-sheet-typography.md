# KIDK Cycle4 — Sheet Typography/Spacing 정합 (06/07)

## 작업 개요
- 대상: `MissionSelectionSheet`(06-city-selection), `MissionCreation`(07-city-creation)
- 목표: 텍스트/HUD 밀도(행간, 여백, 문구 위치) 미세 정합
- 레퍼런스: `/Users/piri/Desktop/kidk_figma`
- 비교 루프: 2회 수행 (`iter1`, `iter2`)
- 빌드: Debug 빌드 성공

## 코드 변경

### 1) `MissionSelectionSheetViewController.swift`
- 헤더 블록 상단/자간 밀도 조정
  - title top: `34 -> 30`
  - subtitle top gap: `6 -> 4`
- 카드 블록 밀도 조정
  - 카드 높이: `78 -> 76`
  - subtitle 아래 카드 시작 간격: `Spacing.md -> Spacing.sm`
- 하단 CTA 블록 간격 조정
  - quiz 카드와 버튼 간격: `Spacing.lg -> Spacing.md`
  - safe area 하단 여백: `Spacing.md -> Spacing.xs`

### 2) `MissionCardButton.swift`
- 카드 내부 텍스트 위계/밀도 조정
  - title font: `.s14/.medium -> .s16/.semibold`
  - icon bg size: `52 -> 50`
  - icon size: `28 -> 26`
  - badge top: `12 -> 10`
  - badge-title gap: `4 -> 2`

### 3) `MissionCreationViewController.swift`
- 전체 레이아웃 상수화(`Layout`) 및 섹션 간격 재정의
- 상단 영역(타이틀/학교 이미지/친구)
  - title top: `32 -> 20`
  - title-image gap: `16`
  - school size: `224x132 -> 230x136`
  - avatar size: `60` 유지(최종), spacing: `8`
  - avatar/add 버튼 corner radius: `30`
- 섹션 간격/카드 높이
  - mission card height: `72`
  - goal input height: `56`
  - amount height: `88`
  - daily label ↔ mission card: `Spacing.sm`
- 타이포(매일 미션 카드 본문)
  - missionDescription: `.s14/.medium -> .s16/.semibold`
  - lineHeight: `120`
- 스크롤/하단 버튼 간격
  - scroll bottom to button: `-Spacing.xs`
  - bottom buttons safe-area inset: `Spacing.xs`

### 4) 자동 비교 스크립트 추가
- 파일: `scripts/figma_cycle4_sheet_capture_compare.py`
- 기능:
  - 06/07 시나리오 자동 실행 후 시뮬레이터 캡처
  - figma 원본 정규화(해상도/패딩)
  - `side-by-side`, `diff`, `metrics.csv/md` 생성
- `KIDK_APP_PATH` 환경변수 지원 추가(올바른 DerivedData 앱 경로 강제)

## 비교 결과 (Metrics)

### Iter1
- `docs/figma-compare/cycle4-sheet/iter1/metrics.csv`
- 06-city-selection: **SSIM 0.6767 / PSNR 12.74**
- 07-city-creation: **SSIM 0.7393 / PSNR 14.26**

### Iter2
- `docs/figma-compare/cycle4-sheet/iter2/metrics.csv`
- 06-city-selection: **SSIM 0.6774 / PSNR 12.76**
- 07-city-creation: **SSIM 0.7662 / PSNR 15.05**

### 개선폭 (Iter2 - Iter1)
- 06-city-selection: SSIM **+0.0007**, PSNR **+0.02**
- 07-city-creation: SSIM **+0.0269**, PSNR **+0.79**

## 산출물
- `docs/figma-compare/cycle4-sheet/iter1/*`
- `docs/figma-compare/cycle4-sheet/iter2/*`
  - `figma-raw/`, `figma-normalized/`, `simulator/`, `side-by-side/`, `diff/`, `metrics.csv`, `metrics.md`
- `docs/kidk-cycle4-sheet-typography.md` (본 문서)

## 빌드
- 명령: `xcodebuild -project KIDK.xcodeproj -scheme KIDK -configuration Debug -destination 'id=2CCF9C01-2F2D-4D71-9D09-8841896C057E' build`
- 결과: **BUILD SUCCEEDED**
- 로그:
  - `/tmp/kidk_build_debug_cycle4_sheet_iter1.log`
  - `/tmp/kidk_build_debug_cycle4_sheet_iter2.log`

## 메모
- `simctl terminate`는 앱 미실행 상태에서 `found nothing to terminate` 메시지가 간헐 출력되나, 캡처/비교 파이프라인 동작에는 영향 없음.
- 커밋/푸시는 수행하지 않음.
