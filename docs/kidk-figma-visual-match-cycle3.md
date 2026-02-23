# KIDK Figma Visual Match - Cycle 3 (Top5 Gap Focus)

작성일: 2026-03-01  
브랜치: `Feat/kidk-figma-hybrid`

## 1) Cycle3 목표/범위
Cycle2 잔여 갭 TOP5를 우선 개선:
1. 완료 팝업(선물박스) 상태 UI 구현/정합
2. 맵 오브젝트(학교/마트/캐릭터) 배치·스케일 보정
3. fallback 아이콘 톤 보정
4. 친구 아바타 스타일 정합
5. 타이포 미세 조정(줄바꿈/line-height/weight)

대상 화면(6):
- `05-city-base`
- `06-city-selection`
- `07-city-creation`
- `08-city-building-detail`
- `09-mission-in-progress`
- `10-mission-completed`

산출물:
- `docs/figma-compare/cycle3/iter1/...`
- `docs/figma-compare/cycle3/iter2/...`
- side-by-side / diff / metrics.csv 생성 완료

---

## 2) 핵심 구현 변경

### A. 완료 팝업(선물박스) 상태 구현
- `KIDKCityViewController`에 완료 팝업 카드 신규 구현
  - 제목/설명/선물박스 이미지/완료 버튼
  - dim 배경 + show/hide 애니메이션
  - Debug 스냅샷 액션 `showMissionCompletedPopup` 추가
- `FigmaSnapshotScenario`에서 `mission-completed`는 완료 팝업 상태로 캡처하도록 변경

### B. 맵 오브젝트 배치/스케일 보정
- 학교/마트/캐릭터의 위치 및 크기 파라미터 재조정
- 기존 대비 Figma와 겹침이 큰 축(학교 상단/캐릭터 주변)을 중심으로 보정

### C. fallback/아이콘 톤 보정 + 실제 에셋 매핑
- fallback SF Symbol에 pointSize/weight/tint 일관화 적용
- Figma `asset/` 기반으로 아래 에셋 실매핑:
  - `kidk_mission_video`, `kidk_mission_study`, `kidk_mission_quiz`
  - `kidk_friend_avatar_1~3`, `kidk_friend_add_icon`
  - `kidk_game_clock`, `kidk_game_mart_icon`, `kidk_game_bubble_arrow`
- `kidk_mission_savings`는 원본 부재로 wallet 기반 임시 매핑

### D. 친구 아바타 스타일 정합
- 생성 화면/건물 상세의 아바타 border/background/corner/size 톤 조정
- stack 높이/간격 미세 보정

### E. 타이포 미세 조정
- lineHeight 적용/통일(가이드 문구, 설명 문구, 시트 타이틀 등)
- mission description은 텍스트 갱신 시에도 스타일 재적용하도록 보강

---

## 3) Iteration 결과 (정규화 기준)

### Iter1
| screen | SSIM | PSNR |
|---|---:|---:|
| 05-city-base | 0.6615 | 10.59 |
| 06-city-selection | 0.6687 | 12.53 |
| 07-city-creation | 0.7288 | 13.88 |
| 08-city-building-detail | 0.6170 | 11.51 |
| 09-mission-in-progress | 0.4885 | 7.86 |
| 10-mission-completed | 0.6168 | 11.92 |

### Iter2 (수정 후)
| screen | SSIM | PSNR | ΔSSIM(vs Iter1) |
|---|---:|---:|---:|
| 05-city-base | 0.6529 | 10.52 | -0.0086 |
| 06-city-selection | 0.6643 | 12.46 | -0.0044 |
| 07-city-creation | 0.7333 | 13.94 | +0.0045 |
| 08-city-building-detail | 0.6147 | 11.50 | -0.0023 |
| 09-mission-in-progress | 0.6168 | 9.91 | **+0.1283** |
| 10-mission-completed | 0.6692 | 12.12 | **+0.0524** |

평균:
- SSIM: `0.6302 → 0.6585` (**+0.0283**)
- PSNR: `11.38 → 11.74` (**+0.36**)

---

## 4) Cycle2 대비 개선 수치
기준: `cycle2/iter2` vs `cycle3/iter2`

| screen | Cycle2 SSIM | Cycle3 SSIM | ΔSSIM | Cycle2 PSNR | Cycle3 PSNR | ΔPSNR |
|---|---:|---:|---:|---:|---:|---:|
| 05-city-base | 0.6618 | 0.6529 | -0.0089 | 10.63 | 10.52 | -0.11 |
| 06-city-selection | 0.6692 | 0.6643 | -0.0049 | 12.53 | 12.46 | -0.07 |
| 07-city-creation | 0.7288 | 0.7333 | +0.0045 | 13.88 | 13.94 | +0.06 |
| 08-city-building-detail | 0.6170 | 0.6147 | -0.0023 | 11.51 | 11.50 | -0.01 |
| 09-mission-in-progress | 0.4885 | 0.6168 | **+0.1283** | 7.86 | 9.91 | **+2.05** |
| 10-mission-completed | 0.6168 | 0.6692 | **+0.0524** | 11.92 | 12.12 | **+0.20** |

평균 개선:
- **SSIM +0.0282** (0.6304 → 0.6585)
- **PSNR +0.35** (11.39 → 11.74)

---

## 5) TOP5 타겟 달성도
1. 완료 팝업(선물박스): **구현 완료** (시나리오 캡처 반영)
2. 맵 오브젝트 배치·스케일: **부분 개선** (학교/마트/캐릭터 보정)
3. fallback 아이콘 톤: **개선 + 다수 실에셋 치환 완료**
4. 친구 아바타 스타일: **개선 완료**
5. 타이포 미세 조정: **개선 완료**

---

## 6) 남은 갭 TOP3
1. **맵 오브젝트 정밀 좌표/스케일**
   - 학교/마트/캐릭터가 Figma 대비 아직 미세 오프셋 존재(특히 05/06/08)
2. **완료 팝업 일러스트 정합**
   - 현재 선물박스는 화면 크롭 기반 임시 에셋이라 원본 일러스트 비율/코인 배치 차이 존재
3. **시트/맵 텍스트·HUD 밀도 미세 차이**
   - 카드/배지의 행간·여백·문구 위치가 일부 화면에서 여전히 차이

---

## 7) Debug 빌드
실행 커맨드:
```bash
xcodebuild -project KIDK.xcodeproj -scheme KIDK -configuration Debug -destination 'id=2CCF9C01-2F2D-4D71-9D09-8841896C057E' build
```
결과:
- `** BUILD SUCCEEDED **`
- 로그: `/tmp/kidk_build_debug_cycle3_iter2.log`

---

## 8) Cycle3 변경 파일 목록 (작업 범위)
> 참고: 브랜치에 기존 변경분이 이미 존재하여, 아래는 Cycle3에서 직접 터치한 핵심 파일만 표기

### 코드
- `KIDK/Debug/FigmaSnapshotScenario.swift`
- `KIDK/Presentation/View/Mission/KidkCity/KIDKCityViewController.swift`
- `KIDK/Presentation/View/Mission/KidkCity/MissionCreationViewController.swift`
- `KIDK/Presentation/View/Mission/KidkCity/MissionSelectionSheetViewController.swift`
- `KIDK/Presentation/View/Mission/MissionCardButton.swift`

### 비교/자동화
- `scripts/figma_cycle3_capture_compare.py`
- `docs/figma-compare/cycle3/iter1/*`
- `docs/figma-compare/cycle3/iter2/*`

### 에셋
- 수정:
  - `KIDK/Resource/Assets.xcassets/kidk_character_side_walk_1.imageset/Contents.json`
  - `KIDK/Resource/Assets.xcassets/kidk_character_side_walk_1.imageset/kidk_character_side_walk_1.png`
  - `KIDK/Resource/Assets.xcassets/kidk_character_side_walk_1.imageset/kidk_city_mart.png` (삭제)
- 신규 imageset:
  - `kidk_mission_video.imageset`
  - `kidk_mission_study.imageset`
  - `kidk_mission_quiz.imageset`
  - `kidk_mission_savings.imageset`
  - `kidk_mission_completed_gift.imageset`
  - `kidk_friend_avatar_1.imageset`
  - `kidk_friend_avatar_2.imageset`
  - `kidk_friend_avatar_3.imageset`
  - `kidk_friend_add_icon.imageset`
  - `kidk_game_clock.imageset`
  - `kidk_game_mart_icon.imageset`
  - `kidk_game_bubble_arrow.imageset`

### 문서
- `docs/kidk-figma-visual-match-cycle3.md` (본 보고서)
- `docs/kidk-figma-implementation-options.md` (Cycle3 에셋 요청 현행화)
