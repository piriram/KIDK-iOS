# KIDK City TODO List

작성일: 2026-03-04

## Phase A — Debug 튜닝 도구

- [x] `#if DEBUG` 디버그 패널 UI 추가
- [x] `bgScale` 슬라이더 연결
- [x] `bgOffsetX`, `bgOffsetY` 슬라이더 연결
- [x] `school xRatio/yRatio` 슬라이더 연결
- [x] `mart xRatio/yRatio` 슬라이더 연결
- [x] Reset 버튼
- [x] JSON Export/Copy 버튼

## Phase B — 좌표 체계 표준화

- [x] 배경 display rect 계산 함수 도입 (aspectFill 기준)
- [x] 건물 좌표를 `xRatio/yRatio` 기반으로 변환
- [ ] anchor 기준 통일
- [ ] 기존 하드코딩 위치 제거

## Phase C — 데이터 분리

- [ ] `kidk_city_layout.json` 생성
- [ ] map/buildings 스키마 반영
- [ ] 로딩/검증 로직 추가

## Phase D — 수동 튜닝

- [ ] 사용자 1차 튜닝 값 수집
- [ ] 전달값 반영
- [ ] 재실행 후 재현 확인

## Phase E — 스모크 테스트

- [ ] iPhone SE
- [ ] iPhone 기본형
- [ ] iPhone Pro Max
- [ ] 학교 탭 → 시트
- [ ] 마트 잠금 토스트
- [ ] 홈 버튼 복귀

## Phase F — 마무리

- [ ] 결과 문서 업데이트
- [ ] 이슈(A/B/C) 분류
- [ ] 후속 액션 등록
