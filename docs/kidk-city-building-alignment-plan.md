# KIDK 키득시티 건물-배경 정합 계획서

작성일: 2026-03-04 (Asia/Seoul)

## 1) 목적

기기별 화면 비율/해상도 차이(iPhone SE ~ Pro Max)에서도 **키득시티 건물 위치가 배경 이미지와 일관되게 정합**되도록 좌표 시스템과 검증 체계를 표준화한다.

---

## 2) 문제 정의

현재/잠재 이슈:

- 기기마다 aspect ratio가 달라 배경의 표시 방식이 달라짐
- `aspectFill` 시 이미지 일부 크롭 → 건물 위치가 상대적으로 밀림
- safe area(노치/다이내믹 아일랜드/홈 인디케이터) 차이로 좌표 기준이 흔들림
- 건물 anchor 기준이 통일되지 않으면 같은 좌표라도 시각 위치 불일치
- 시각 위치와 터치 영역(hitbox)이 동일 기준이 아니면 UX 불안정

핵심 원인:

- 건물 좌표를 “화면 좌표”로 관리하거나,
- 배경 표시 영역(display rect) 계산 없이 단순 비율 배치할 때 정합이 깨짐

---

## 3) 설계 원칙 (결정사항)

### 원칙 A. 좌표는 “배경 내부 좌표계” 기준으로 관리

- 기준 배경 원본 크기(`imageWidth`, `imageHeight`)를 단일 진실원(SSOT)로 사용
- 건물 좌표 저장 형식:
  - 권장: `xRatio`, `yRatio` (0~1)
  - 선택: `xPx`, `yPx` (원본 픽셀)

### 원칙 B. 런타임에서 배경 표시 영역(display rect) 계산 후 변환

- 배경의 `contentMode` 정책을 명시 (`aspectFit` 또는 `aspectFill`)
- 컨테이너 내 실제 배경 표시 사각형을 계산
- 건물 좌표는 display rect로 변환하여 최종 배치

### 원칙 C. Anchor/Hitbox 분리

- 건물 anchor를 공통 규칙으로 통일 (권장: 바닥 중심)
- 터치 영역은 시각 sprite와 분리하여 UX 보정 가능하게 설계

### 원칙 D. 기기별 하드코딩 보정 최소화

- `if iPhoneXX` 분기 금지
- 구조적 변환으로 해결하고, 최후 수단으로만 미세 오프셋 테이블 적용

---

## 4) 좌표 변환 표준

### 4-1. 용어

- `containerRect`: 실제 렌더링 컨테이너(게임 뷰) 영역
- `imageSize`: 배경 원본 크기
- `displayRect`: container 안에서 배경 이미지가 실제 표시되는 영역
- `worldPoint`: 배경 내부 좌표(비율 또는 픽셀)
- `screenPoint`: 화면에 최종 렌더링되는 좌표

### 4-2. displayRect 계산

#### Aspect Fit

- `scale = min(containerW / imageW, containerH / imageH)`
- `displayW = imageW * scale`
- `displayH = imageH * scale`
- `displayX = containerMinX + (containerW - displayW) / 2`
- `displayY = containerMinY + (containerH - displayH) / 2`

#### Aspect Fill

- `scale = max(containerW / imageW, containerH / imageH)`
- `displayW = imageW * scale`
- `displayH = imageH * scale`
- `displayX = containerMinX + (containerW - displayW) / 2`
- `displayY = containerMinY + (containerH - displayH) / 2`

### 4-3. 좌표 매핑

- ratio 저장 시:
  - `screenX = displayX + xRatio * displayW`
  - `screenY = displayY + yRatio * displayH`
- px 저장 시:
  - `screenX = displayX + (xPx / imageW) * displayW`
  - `screenY = displayY + (yPx / imageH) * displayH`

---

## 5) SpriteKit 적용 가이드 (KIDKCity)

권장 구조:

- `worldNode`: 배경 + 건물 노드
- `cameraNode`: 화면 표시 제어(줌/이동)
- HUD/버튼: UIKit 또는 오버레이 레이어로 분리

정책:

- 건물 좌표는 `worldNode` 기준 고정
- 카메라와 디바이스 비율 변화는 `scene/camera`가 흡수
- 화면 회전 정책(권장: 세로 고정) 명확화

---

## 6) 데이터 스키마 제안

```json
{
  "map": {
    "id": "kidk_city_v1",
    "imageWidth": 2048,
    "imageHeight": 1536,
    "contentMode": "aspectFit"
  },
  "buildings": [
    {
      "id": "school",
      "xRatio": 0.6445,
      "yRatio": 0.5469,
      "anchor": "bottomCenter",
      "zIndex": 20,
      "hitbox": { "width": 96, "height": 72, "offsetX": 0, "offsetY": -8 }
    }
  ]
}
```

---

## 7) 구현 계획

### Phase 1. 기준 정립

1. 키득시티 배경 기준 원본 크기 확정
2. `contentMode` 정책 확정 (`aspectFit` 우선 권장)
3. anchor 표준 정의 (`bottomCenter`)

### Phase 2. 변환 유틸 도입

1. `displayRect` 계산 유틸 추가
2. ratio/px → screen 좌표 변환 유틸 추가
3. 건물 배치 경로를 단일 유틸로 통합

### Phase 3. 데이터 분리

1. 건물 좌표를 코드 하드코딩에서 JSON/설정 파일로 분리
2. 로딩 시 검증(범위 0~1, 중복 id, 누락 필드) 추가

### Phase 4. 디버그 도구

1. 건물 중심점/anchor/hitbox 시각화 토글
2. 드래그 기반 미세 조정 모드
3. 좌표 export(JSON) 기능

### Phase 5. QA 자동화

1. 대표 기기군 스냅샷 비교
   - 소형(예: SE), 표준, 대형(Pro Max)
2. 기준 스냅샷 대비 오차 허용 범위 정의
3. 회귀 테스트에 포함

---

## 8) QA 체크리스트

- [ ] 모든 대표 기기에서 건물 바닥점이 배경 기준점과 일치
- [ ] 잠금/해금 건물 상태 전환 시 위치 흔들림 없음
- [ ] hitbox가 시각 요소와 과도하게 어긋나지 않음
- [ ] safe area 변화(노치/홈인디케이터)에도 정합 유지
- [ ] Mission 진입/복귀/시트 오픈 후에도 좌표 드리프트 없음

---

## 9) 리스크 및 대응

### R1. 디자인 배경 리소스 교체

- 대응: 맵 버전(`kidk_city_v1`) 관리 + 좌표 세트 버전 분리

### R2. `aspectFill` 전환 요구

- 대응: displayRect 기반 매핑 유지하면 로직 재사용 가능

### R3. 기기별 미세 오차

- 대응: 원칙적으로 변환 로직 해결, 불가 시 최소 오프셋 테이블 한정 적용

---

## 10) 최종 권고

키득시티는 다음 조합으로 운영한다.

1. **배경 내부 정규화 좌표(xRatio/yRatio)** 채택
2. **displayRect 기반 변환**을 단일 경로로 강제
3. **anchor 통일 + hitbox 분리**
4. **디버그 오버레이 + 스냅샷 회귀검증** 도입

이 방식이면 iPhone 사이즈가 달라도 배경-건물 정합을 구조적으로 유지할 수 있다.
