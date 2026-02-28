# KIDK Figma Visual Match - Cycle 2 (Normalized)

작성일: 2026-03-01  
브랜치: `Feat/kidk-figma-hybrid`

## 1) 작업 요약
- 규칙 문서(`docs/kidk-figma-normalization-rules.md`) 기준으로 **contains + padding / non-stretch** 정규화 파이프라인 적용
- 우선 화면 6개를 선정해 Iteration 2회(Iter1 → 수정 → Iter2) 비교 수행
- 산출물 생성:
  - `docs/figma-compare/cycle2/iter1/...`
  - `docs/figma-compare/cycle2/iter2/...`
  - 각 iter 폴더에 `figma-raw`, `figma-normalized`, `simulator`, `side-by-side`, `diff`, `metrics.csv`

## 2) 정규화/캡처 파이프라인
- 스크립트: `scripts/figma_cycle2_capture_compare.py`
- 대상 디바이스: iPhone 16 Pro Simulator (1206x2622)
- 정규화: `scale=...:force_original_aspect_ratio=decrease + pad` (왜곡 없음)
- 상태바 고정: 9:41, Wi-Fi/배터리 오버라이드
- 캡처 시나리오: `--figma-snapshot <scenario>`

## 3) 비교 대상 화면 (6)
1. `05-city-base`
2. `06-city-selection`
3. `07-city-creation`
4. `08-city-building-detail`
5. `09-mission-in-progress`
6. `10-mission-completed`

## 4) Iteration 결과

### Iter1 (기준)
| screen | SSIM | PSNR |
|---|---:|---:|
| 05-city-base | 0.6615 | 10.59 |
| 06-city-selection | 0.6692 | 12.53 |
| 07-city-creation | 0.7362 | 14.07 |
| 08-city-building-detail | 0.6179 | 11.52 |
| 09-mission-in-progress | 0.4090 | 6.60 |
| 10-mission-completed | 0.6098 | 10.88 |

### Iter2 (수정 후)
| screen | SSIM | PSNR | ΔSSIM |
|---|---:|---:|---:|
| 05-city-base | 0.6618 | 10.63 | +0.0003 |
| 06-city-selection | 0.6692 | 12.53 | +0.0000 |
| 07-city-creation | 0.7288 | 13.88 | -0.0074 |
| 08-city-building-detail | 0.6170 | 11.51 | -0.0009 |
| 09-mission-in-progress | 0.4885 | 7.86 | **+0.0795** |
| 10-mission-completed | 0.6168 | 11.92 | **+0.0070** |

- 평균 SSIM: `0.6173 → 0.6304` (**+0.0131**)
- 평균 PSNR: `11.03 → 11.39` (**+0.36**)

## 5) 차이 체크리스트 & 수정 내역

### A. building detail/진행 화면 정합
- [x] 건물 상세 오버레이 보상 문구: `보상 500원` → `보상 2000원`
- [x] 진행/완료 스냅샷 시나리오를 city overlay 기반으로 맞춤 (mission tab 기반 시나리오 대비 개선)
- [x] 참여자 아바타 fallback을 `kidk_profile_one`으로 조정(SF Symbol보다 톤 유사)

### B. 생성 화면 시안 톤 정합
- [x] 친구/아이콘 카드/입력 박스 보더, 코너 라운드, 내부 패딩 보정
- [x] 미션 아이콘 컨테이너 구조 및 fallback 표시 개선

### C. 남은 주요 차이(구조/에셋)
- [ ] 완료 화면은 Figma의 선물박스 완료 팝업 구조가 아직 미구현
- [ ] 맵 오브젝트 스케일/좌표(학교, 마트, 캐릭터)와 원본 시안 간 차이
- [ ] 일부 아이콘은 placeholder/fallback로 대체 중

## 6) 1차(Iter1) 대비 개선점
1. `09-mission-in-progress`가 city overlay 기준으로 전환되며 SSIM 큰 폭 개선(+0.0795)
2. `10-mission-completed`도 동일한 overlay 흐름으로 전환되어 PSNR 개선(+1.04)
3. 건물 상세 보상/참여자 톤이 Figma 문구/색감에 더 근접
4. 생성 화면 카드/보더/아이콘 컨테이너가 시안의 밀도에 가까워짐

## 7) 아직 남은 갭 TOP5
1. **완료 팝업(선물박스) 미구현**: Figma `10` 화면 핵심 상태가 아직 불일치
2. **맵 리소스/배치 불일치**: 학교·마트·캐릭터 위치/크기/디테일 차이
3. **아이콘 원본 부재**: `kidk_mission_*`, `kidk_game_*` 일부 fallback 사용
4. **친구 아바타 정합**: 현재 동일 프로필 fallback이라 다양성/스타일 차이
5. **텍스트 미세 타이포**: 라인브레이크/폰트 weight/자간 차이 일부 잔존

## 8) Debug 빌드 확인
실행 커맨드:
```bash
xcodebuild -project KIDK.xcodeproj -scheme KIDK -configuration Debug -destination 'id=2CCF9C01-2F2D-4D71-9D09-8841896C057E' build
```
결과:
- `** BUILD SUCCEEDED **`
- 로그: `/tmp/kidk_build_debug_cycle2_iter2.log`

## 9) Cycle2 작업 변경 파일
- `KIDK/Debug/FigmaSnapshotScenario.swift` (신규)
- `KIDK/Presentation/View/Mission/KidkCity/KIDKCityViewController.swift`
- `KIDK/Presentation/View/Mission/KidkCity/MissionCreationViewController.swift`
- `scripts/figma_cycle2_capture_compare.py` (신규)
- `docs/kidk-figma-implementation-options.md` (에셋 요청 최신화)
- `docs/kidk-figma-visual-match-cycle2.md` (본 보고서)
- `docs/figma-compare/cycle2/iter1/*`, `docs/figma-compare/cycle2/iter2/*` (비교 산출물)
