# KIDK City 스모크 리포트 v1 (2026-03-10)

기준 브랜치: `feat/#1`
기준 PR: https://github.com/piriram/KIDK-iOS/pull/3

## 1) 빌드 상태

- [x] Debug build (iOS Simulator, generic)
- 결과: `BUILD SUCCEEDED`

## 2) 기능 점검 (1차)

### City Core
- [x] `kidk_city_layout.json` 로딩 기반 배치
- [x] 캐릭터 탭 이동
- [x] 건물 접근 이동(집/학교/마트)
- [x] 맵 경계 clamp

### Progress/HUD
- [x] progressTrackView 비율/여백 리디자인
- [x] 목업 80% 프리뷰 적용(DEBUG)

### State/Event
- [x] `CityProgress` 모델 연결
- [x] `missionRewardCompleted` payload 연결
- [x] idempotencyKey 중복 방지

### Account Tab
- [x] 상단 navigation header 숨김 처리

## 3) 기기군 점검 현황

- [ ] iPhone SE
- [ ] iPhone 기본형
- [ ] iPhone Pro Max

> 메모: 기기별 위치/스케일 값은 튜닝 라운드에서 확정 예정.

## 4) 이슈/리스크

- 좌표 튜닝 미완료로 기기별 미세 정렬 차이 가능
- 승인/이체/연출 실패 분기 UX는 문구 표준화 완료, 액션 연결은 후속

## 5) 다음 액션

1. 3기기 기준값 수집 후 `kidk_city_layout.json` v2 반영
2. 승인/이체 실패 재시도 액션 연결
3. 스모크 리포트 v2 갱신
