# KIDK Figma 기반 iOS 구현 점검 보고서 (옵션 제안)

작성일: 2026-03-01
범위:
- 디자인 시안: `/Users/piri/Desktop/kidk_figma`
- iOS 프로젝트: `/Users/piri/shared/active/KIDK-iOS`
- 본 문서는 **분석/옵션 제안 전용** (코드 수정 없음)

---

## 1) kidk_figma 이미지 목록 및 화면 분류

### 1-1. 원본 파일 현황
- 총 PNG: **45개**
  - 화면/버튼 시안: **12개**
  - asset 폴더 아이콘(1x/2x/3x 포함): **33개**

### 1-2. 화면 시안 분류 (주요 10개 + 소형 2개)

| 구분 | 파일 | 추정 화면명/상태 | 비고 |
|---|---|---|---|
| A1 | `3. 내계좌/전.png` | 내계좌 탭 (미션 생성 전) | 저금통 카드: “친구들과 함께 저축 목표를 설정…” |
| A2 | `11. 내계좌/후.png` | 내계좌 탭 (미션 생성 후) | 저금통 카드: “여름방학 놀이공원 가기! GO” |
| B1 | `4. 미션 탭/전.png` | 미션 탭 (empty 상태) | “키득시티에서 목표를 설정해요” |
| B2 | `12. 미션 탭/후.png` | 미션 탭 (진행중 미션 존재) | 진행중 카드 + 인증하기 |
| C1 | `5. 기본 맵 화면.png` | 키득시티 맵 기본 화면 | 맵/건물/캐릭터/HUD |
| C2 | `6. 금액 가이드...png` | 미션 선택 시트 | 추천 미션 3개 + 직접 설정 |
| C3 | `7. 금액 가이드...png` | 미션 생성(상세 설정) | 친구/일일미션/목표/금액 설정 |
| C4 | `8. 건물1 미션 화면.png` | 건물 미션 상세(추정) | 보상 금액 + 미션 설명 + 참여자 표시 |
| C5 | `9. 미션 진행 중 화면.png` | 미션 진행중 카드(확장) | 원형 진행률 + 목표 문구 |
| C6 | `10. 미션 진행 완료 화면.png` | 미션 완료 상태 | 완료 CTA 존재 |
| D1 | `Group 427320476.png` | 소형 UI 요소(추정) | 136x60 |
| D2 | `친구 추가.png` | 친구 추가 버튼 라벨(추정) | 183x44 |

### 1-3. `asset/` 폴더 주요 에셋 세트(베이스명 기준)
- `ABC` (퀴즈/학습 계열 아이콘 추정)
- `Video`
- `Pencil`, `Game_Pencil`
- `Game_Clock`
- `Game_Mart_Icon`
- `Game_buble_and_arrow`
- `frend1`, `friend2`, `frend3` (친구 아바타)
- `friend_plus_icon`

---

## 2) KIDK-iOS 대응 화면(ViewController/View) 매핑

| Figma 화면 | 현재 iOS 대응 파일 | 구현 적합도 | 갭/메모 |
|---|---|---|---|
| 내계좌 전/후 (A1/A2) | `AccountViewController`, `AccountCardFactory`, `AccountCardView` | 중~높음 | 구조는 유사. 카드 문구/상태 전환은 있으나 아이콘/타이포/간격 미세 차이 존재 |
| 미션 탭 전/후 (B1/B2) | `MissionViewController`, `MissionCardView`, `MissionCardCell` | 중~높음 | empty/진행중 상태 모두 존재. 다만 디자인 정밀도(버튼/배지/아바타/세부 텍스트) 차이 |
| 미션 진행중/완료 (C5/C6) | `MissionCardView`, `CircularProgressView` | 중간 | 진행중 원형 게이지는 존재. **완료 전용 상태 UI(완료 버튼/메시지) 분기 부족** |
| 기본 맵 (C1) | `KIDKCityViewController`, 내부 `KidkCityScene` | 중간 | 맵 구조는 존재하나 시안의 오버레이/연출 요소(버블+화살표/시계/연필 등) 부족 |
| 미션 선택 시트 (C2) | `MissionSelectionSheetViewController`, `MissionCardButton` | 중간 | 레이아웃은 유사. **미션 아이콘 에셋 키 누락**으로 시안 동일도 저하 |
| 미션 생성 상세 (C3) | `MissionCreationViewController` | 중간 | 흐름은 맞음. **친구 아바타/추가 버튼 에셋 키 누락**, 세부 타이포/간격 보정 필요 |
| 건물1 미션 상세 (C4) | (직접 대응 화면 없음) | 낮음 | 현재 구조상 별도 상세 화면/오버레이가 명확히 없음. 신규 상세 컴포넌트 필요 가능성 큼 |
| 하단 탭 아이콘 | `MainTabBarController` | 낮음~중간 | 코드 키(`tab_account_selected` 등)와 실제 xcassets 키 불일치(현재 `...selected22` 등) |

추가 점검 포인트:
- `kidk_character_side_walk_1.imageset`가 `kidk_city_mart.png`를 가리키고 있어, 캐릭터 애니메이션 자산 매핑 이상 가능성 높음.

---

## 3) 구현 옵션 제안 (최소 3안)

## 옵션 A. 정밀복제형 (Pixel-close)
- 접근: Figma 10개 핵심 화면을 기준으로 미션/맵/탭/카드 컴포넌트를 재정렬 및 상태별 UI를 세분화
- 장점:
  - 디자인 일치도 최고
  - QA 시 “시안 대비 오차” 이슈 최소화
- 단점:
  - 레이아웃/컴포넌트 수정 폭 큼
  - 화면 간 상태 분기(전/후/진행/완료) 구현 비용 큼
- 작업량/리스크: **높음 / 중~높음**
- 일정(대략): **8~12 작업일**

## 옵션 B. 하이브리드형 (핵심화면 정밀 + 나머지 구조 유지)
- 접근: 기존 VC 구조 유지, 차이가 큰 영역만 정밀 보정
  - 우선순위: 미션 탭 카드 상태(전/후/진행/완료), 미션 선택/생성 시트, 탭 아이콘, 맵 오버레이
- 장점:
  - 일정 대비 체감 품질 개선 큼
  - 리팩토링 리스크 상대적으로 낮음
- 단점:
  - 일부 화면은 완전 동일하지 않을 수 있음
- 작업량/리스크: **중간 / 중간**
- 일정(대략): **4~7 작업일**

## 옵션 C. 현 구조 유지형 (스타일/에셋 보강 중심)
- 접근: 기존 레이아웃은 최대 유지하고 에셋 교체/문구/간격 소폭 보정 위주
- 장점:
  - 빠른 적용 가능
  - 회귀 리스크 낮음
- 단점:
  - 시안과 “거의 동일” 목표 달성은 어려움
  - 미션 상세(건물1) 같은 신규 UX는 커버 한계
- 작업량/리스크: **낮음 / 낮음**
- 일정(대략): **2~4 작업일**

> 권장: 현재 상태에서 “거의 동일” 목표를 현실적으로 맞추려면 **옵션 B**가 가장 균형적.

---

## 4) 에셋 점검 (누락/불일치 추정)

## 4-1. 코드에서 참조하지만 Xcode Asset Catalog에 없는 키 (우선 보강 필요)

| 누락 키(코드 참조) | 필요 화면/용도 | 권장 소스(추정) | 권장 Asset key |
|---|---|---|---|
| `kidk_mission_video` | 미션 선택/생성 아이콘 | `asset/Video(.png,@2x,@3x)` | `kidk_mission_video` |
| `kidk_mission_study` | 미션 선택/생성 아이콘 | `asset/Pencil` 또는 `asset/Game_Pencil` | `kidk_mission_study` |
| `kidk_mission_quiz` | 미션 선택/생성 아이콘 | `asset/ABC(.png,@2x,@3x)` | `kidk_mission_quiz` |
| `kidk_mission_savings` | 미션 생성(.savings) 아이콘 | **원본 미확인(추가 필요)** | `kidk_mission_savings` |
| `kidk_friend_avatar_1` | 미션 생성-친구 | `asset/frend1` | `kidk_friend_avatar_1` |
| `kidk_friend_avatar_2` | 미션 생성-친구 | `asset/friend2` | `kidk_friend_avatar_2` |
| `kidk_friend_avatar_3` | 미션 생성-친구 | `asset/frend3` | `kidk_friend_avatar_3` |
| `tab_account_selected` | 하단 탭(선택) | 탭 아이콘 원본 필요 | `tab_account_selected` |
| `tab_mission_selected` | 하단 탭(선택) | 탭 아이콘 원본 필요 | `tab_mission_selected` |
| `tab_settings_unselected` | 하단 탭(비선택) | 탭 아이콘 원본 필요 | `tab_settings_unselected` |
| `tab_settings_selected` | 하단 탭(선택) | 탭 아이콘 원본 필요 | `tab_settings_selected` |

## 4-2. Figma에는 있으나 iOS 쪽 활용/매핑이 불명확한 에셋

| Figma asset | 사용 추정 화면 | 권장 key |
|---|---|---|
| `Game_Clock` | 맵/미션 진행 HUD 보조 아이콘 | `kidk_game_clock` |
| `Game_Mart_Icon` | 맵 내 건물/마트 포인트 | `kidk_game_mart_icon` |
| `Game_buble_and_arrow` | 진행 상태 버블/콜아웃 | `kidk_game_bubble_arrow` |
| `friend_plus_icon` | 친구 추가 버튼 아이콘 | `kidk_friend_add_icon` |
| `친구 추가.png` | 친구 추가 버튼 라벨/배경 | `kidk_friend_add_label` |

## 4-3. 현재 Catalog 내 품질 리스크(명칭/매핑)
- `tab_account_selected22`, `tab_mission_selected22`, `tab_settings_unselected22` 등 키 네이밍이 코드와 불일치
- `tab_account_selected22` 내부 파일명이 `tab_account_unselected.png`로 되어 있어 의미 불일치
- `kidk_character_side_walk_1`가 `kidk_city_mart.png`를 참조 (자산 연결 오류 가능성 높음)

---

## 5) 사용자 요청용 에셋 체크리스트 (바로 전달용)

아래 에셋들을 보내주세요 (가능하면 **1x/2x/3x PNG 세트** 또는 벡터 PDF/SVG + 가이드 포함):

- [ ] 미션 아이콘 4종
  - `kidk_mission_video`
  - `kidk_mission_study`
  - `kidk_mission_quiz`
  - `kidk_mission_savings` (현재 원본 미확인)
- [ ] 친구 아바타 3종 + 추가 아이콘
  - `kidk_friend_avatar_1`, `kidk_friend_avatar_2`, `kidk_friend_avatar_3`
  - `kidk_friend_add_icon`
- [ ] 하단 탭 아이콘 선택/비선택 세트
  - account: selected/unselected
  - mission: selected/unselected
  - settings: selected/unselected
- [ ] 키득시티 오버레이 아이콘
  - `kidk_game_clock`
  - `kidk_game_mart_icon`
  - `kidk_game_bubble_arrow`
  - (필요 시) 연필 계열 보조 아이콘
- [ ] 건물1 미션 상세 화면용 배경/일러스트/배지 리소스
  - 보상 배지, 설명 카드 배경, 참여자 표시 리소스

권장 전달 포맷:
- 파일명 규칙: 최종 Asset key와 동일
- 투명 배경 PNG 우선
- 아이콘은 최소 3배수(@3x) 기준 원본 함께 제공

---

## 6) 결론 요약
- 현재 KIDK-iOS는 **기본 흐름(내계좌/미션탭/키득시티/미션생성)**은 이미 갖춰져 있어, 완전 신규 구축은 불필요.
- 다만 “시안과 거의 동일” 목표 관점에서는
  1) 미션 상태별 디테일 UI(특히 완료 상태),
  2) 건물1 미션 상세 화면,
  3) 에셋 키 누락/불일치 정리
  가 핵심 갭.
- 일정/리스크 균형상 **옵션 B(하이브리드)**를 권장.

