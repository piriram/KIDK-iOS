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

---

## Phase G — 2026-03-09 완성 제안서 적용 (MVP 고정)

기준 문서: `KIDK_CITY_COMPLETION_PROPOSAL_2026-03-09.md`

### G-1. Sprint 1 (정합 + 상태기반 완성)
- [ ] `CityProgress` 모델 정의 (`currentLevel`, `exp`, `unlockedZones`, `lastRewardedMissionId`, `updatedAt`)
- [ ] `missionRewardCompleted` payload 스키마 정의 (`missionId`, `rewardAmount`, `rewardType`, `childId`, `timestamp`, `idempotencyKey`)
- [ ] 보상→성장 매핑 테이블(JSON/표) v1 작성
- [ ] 승인/이체/연출 실패 분기 UX 1차 적용
- [ ] 시티 정합 기준값 JSON v1 + 스모크 리포트 v1

### G-2. Sprint 2 (관측 + 포트폴리오 완성)
- [ ] 퍼널 이벤트 정의 (`mission_created`, `verification_submitted`, `verification_approved`, `reward_transferred`, `city_progress_updated`)
- [ ] QA 시나리오(성공/실패/복구) 정식화
- [ ] 기기군 회귀 체크리스트 고정
- [ ] 포트폴리오 패키지(흐름도/상태전이/복구정책) 업데이트

### G-3. MVP 범위 고정
- [ ] 포함: 부모-자녀 2자 구조, 단일 동시 미션, 승인→이체→도시 반영, Lv1/10/20/30 오픈
- [ ] 제외: 친구/팀 미션, 고급 AI 추천, 시즌 이벤트

### G-4. 이번 주 즉시 실행 5항목
- [ ] `CityProgress` 데이터 모델 + 이벤트 payload 스키마 확정
- [ ] `kidk_city_layout.json` 파일 분리 및 scene 로더 연결
- [ ] 기준 3기기 튜닝 1차 (값 수집/반영)
- [ ] 실패 분기 UI 메시지 표준화
- [ ] 스모크 리포트 + 포트폴리오 문서 1차 업데이트
