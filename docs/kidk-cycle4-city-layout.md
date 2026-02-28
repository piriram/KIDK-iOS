# KIDK Cycle4 - City Layout Figma Match (05/06/08)

## 작업 범위
- 대상 코드: `KIDK/Presentation/View/Mission/KidkCity/KIDKCityViewController.swift`
- 대상 오브젝트: 학교(`schoolNode`), 마트(`martNode`), 캐릭터(`characterNode`)
- 대상 화면:
  - `05-city-base`
  - `06-city-selection`
  - `08-city-building-detail`
- Figma 원본: `/Users/piri/Desktop/kidk_figma`
- 정규화 규칙: `docs/kidk-figma-normalization-rules.md`

---

## 자동 캡처/비교 파이프라인
반복 비교를 위해 아래 스크립트를 추가/사용했다.

- `scripts/figma_cycle4_city_layout_capture_compare.py`

기능:
1. `--figma-snapshot` 시나리오별 시뮬레이터 캡처
2. Figma 원본을 시뮬레이터 해상도(1206x2622)로 정규화
3. side-by-side / diff 이미지 생성
4. SSIM/PSNR 계산 후 `metrics.csv`, `metrics.md` 생성

산출물 루트:
- `docs/figma-compare/cycle4-city-layout/iter1/*`
- `docs/figma-compare/cycle4-city-layout/iter2/*`

---

## Iteration 기록

### Iter1 (탐색: 오브젝트 확대/재배치)
적용값:
- school: `x 0.472, y 0.69, size 0.68w/0.34h`
- mart: `x 0.695, y 0.31, size 0.44w/0.27h`
- character: `x 0.17, y 0.34, 136x136`

결과 (`iter1/metrics.csv`):
- 05-city-base: SSIM **0.6425**, PSNR **10.43**
- 06-city-selection: SSIM **0.6597**, PSNR **12.59**
- 08-city-building-detail: SSIM **0.5805**, PSNR **11.24**

판단:
- 학교/마트를 과하게 키운 영향으로 전체 균형 저하.
- 캐릭터 위치도 Figma 대비 이탈이 큼.

### Iter2 (최종: 균형 복원 + 캐릭터 우측 상단 정렬)
최종 적용값:
- school: `x 0.49, y 0.675, size 0.63w/0.315h`
- mart: `x 0.74, y 0.28, size 0.34w/0.22h`
- character: `x 0.77, y 0.685, 136x136`

결과 (`iter2/metrics.csv`):
- 05-city-base: SSIM **0.6554**, PSNR **10.56**
- 06-city-selection: SSIM **0.6577**, PSNR **12.36**
- 08-city-building-detail: SSIM **0.5771**, PSNR **11.10**

요약:
- 05는 Iter1 대비 개선(특히 캐릭터 위치 정합).
- 06/08은 오버레이·상태 UI 영향으로 지표 변동이 작고, 오브젝트 중심 체감 정렬 위주로 확정.

---

## 최종 코드 변경점
파일: `KIDK/Presentation/View/Mission/KidkCity/KIDKCityViewController.swift`

`layoutScene()` 내 최종 값:
- `schoolNode.position = CGPoint(x: size.width * 0.49, y: size.height * 0.675)`
- `schoolNode.size = aspectFitSize(... CGSize(width: size.width * 0.63, height: size.height * 0.315))`
- `martNode.position = CGPoint(x: size.width * 0.74, y: size.height * 0.28)`
- `martNode.size = aspectFitSize(... CGSize(width: size.width * 0.34, height: size.height * 0.22))`
- `characterNode.position = CGPoint(x: size.width * 0.77, y: size.height * 0.685)`
- `characterNode.size = aspectFitSize(... CGSize(width: 136, height: 136))`

---

## 빌드 검증
Debug 빌드 성공 확인:
- `xcodebuild -project KIDK.xcodeproj -scheme KIDK -configuration Debug -destination 'id=2CCF9C01-2F2D-4D71-9D09-8841896C057E' build`
- 결과: `** BUILD SUCCEEDED **`

(커밋/푸시는 수행하지 않음)
