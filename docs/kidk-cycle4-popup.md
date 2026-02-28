# KIDK Cycle4 - 미션 완료 팝업 UI 정합 개선

## 작업 범위
- 대상: `KIDKCityViewController` 미션 완료 팝업(선물박스)
- 참조 시안: `/Users/piri/Desktop/kidk_figma/10. 미션 진행 완료 화면.png`
- 요구사항: 비율/여백/텍스트 밀도/버튼 위치 보정 + 비교 캡처 2회 + Debug build

---

## 반영 내용

### 1) 비율/여백 보정
- 팝업 세로 위치: `centerY +34` → `+8` (상단 과다 여백 완화)
- 타이틀 상단: `28` → `30`
- 타이틀-설명 간격: `18` → `14`
- 설명-선물 일러스트 간격: `22` → `12`
- 선물 일러스트: `232x232` → `238x238` (팝업 내 점유율 증가)
- 일러스트-버튼 간격: `22` → `14`
- 하단 버튼 여백: `-Spacing.lg` → `-Spacing.sm` (시안 대비 하단 정렬 보정)

### 2) 텍스트 밀도/정렬 보정
- 타이틀 폰트: `.s18` → `.s20`, 중앙 정렬
- 설명 폰트: `.s14` 유지, weight `medium` → `bold`, lineHeight `132` → `138`, 중앙 정렬
- `configureMissionCompletedPopupText()` 추가로 타이틀/설명을 attributed text로 재적용(정렬/행간 고정)

### 3) 버튼 위치/애니메이션 보정
- 버튼 높이: `56` → `58`
- 딤 강도: `0.45` → `0.52`
- 팝업 show 애니메이션: 단순 fade/translate → spring(0.32s, damping 0.88) + 약한 scale-in
- 팝업 hide 애니메이션: scale-out + translate + easeIn (0.18s)

---

## 비교 캡처 (2회)

### Iter1
- 시뮬레이터: `docs/figma-compare/cycle4-popup/iter1/simulator/10-mission-completed.png`
- 나란히 비교: `docs/figma-compare/cycle4-popup/iter1/side-by-side/10-mission-completed.png`
- diff: `docs/figma-compare/cycle4-popup/iter1/diff/10-mission-completed.png`
- metrics: `docs/figma-compare/cycle4-popup/iter1/metrics.md`
  - SSIM **0.7183**, PSNR **13.64**

### Iter2
- 시뮬레이터: `docs/figma-compare/cycle4-popup/iter2/simulator/10-mission-completed.png`
- 나란히 비교: `docs/figma-compare/cycle4-popup/iter2/side-by-side/10-mission-completed.png`
- diff: `docs/figma-compare/cycle4-popup/iter2/diff/10-mission-completed.png`
- metrics: `docs/figma-compare/cycle4-popup/iter2/metrics.md`
  - SSIM **0.7322**, PSNR **14.00**

> Iter2에서 Iter1 대비 정합도 지표가 상승했습니다.

---

## Debug Build
- 명령: `xcodebuild -project KIDK.xcodeproj -scheme KIDK -configuration Debug -destination 'id=2CCF9C01-2F2D-4D71-9D09-8841896C057E' build`
- 결과: **BUILD SUCCEEDED**
- 로그: `/tmp/kidk_build_debug_cycle4_popup_iter2.log`

---

## 수정 파일
- `KIDK/Presentation/View/Mission/KidkCity/KIDKCityViewController.swift`
- `scripts/figma_cycle4_popup_capture_compare.py`
- `docs/figma-compare/cycle4-popup/iter1/*`
- `docs/figma-compare/cycle4-popup/iter2/*`
- `docs/kidk-cycle4-popup.md`
