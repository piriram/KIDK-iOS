# KIDK 누락/요청필요 에셋 파일명 가이드

기준: `docs/kidk-figma-implementation-options.md` (Cycle 3, 9-2 “아직 요청 필요한 항목”)

아래 항목만 디자이너가 그대로 저장해서 전달하면 됩니다.

---

## 1) 탭 아이콘 정식 세트 (교체 필요)

- [ ] Asset key: `tab_account_selected`
  - 파일명(1x): `tab_account_selected.png`
  - 파일명(2x): `tab_account_selected@2x.png`
  - 파일명(3x): `tab_account_selected@3x.png`
  - 권장 사이즈/비율: **24x24 / 48x48 / 72x72 px, 1:1, 투명 배경**
  - 사용 화면: **하단 탭바 > 내 계좌 탭 선택 상태**

- [ ] Asset key: `tab_mission_selected`
  - 파일명(1x): `tab_mission_selected.png`
  - 파일명(2x): `tab_mission_selected@2x.png`
  - 파일명(3x): `tab_mission_selected@3x.png`
  - 권장 사이즈/비율: **24x24 / 48x48 / 72x72 px, 1:1, 투명 배경**
  - 사용 화면: **하단 탭바 > 미션 탭 선택 상태**

- [ ] Asset key: `tab_settings_unselected`
  - 파일명(1x): `tab_settings_unselected.png`
  - 파일명(2x): `tab_settings_unselected@2x.png`
  - 파일명(3x): `tab_settings_unselected@3x.png`
  - 권장 사이즈/비율: **24x24 / 48x48 / 72x72 px, 1:1, 투명 배경**
  - 사용 화면: **하단 탭바 > 설정 탭 비선택 상태**

- [ ] Asset key: `tab_settings_selected`
  - 파일명(1x): `tab_settings_selected.png`
  - 파일명(2x): `tab_settings_selected@2x.png`
  - 파일명(3x): `tab_settings_selected@3x.png`
  - 권장 사이즈/비율: **24x24 / 48x48 / 72x72 px, 1:1, 투명 배경**
  - 사용 화면: **하단 탭바 > 설정 탭 선택 상태**

---

## 2) 미션 아이콘 원본 교체

- [ ] Asset key: `kidk_mission_savings`
  - 파일명(1x): `kidk_mission_savings.png`
  - 파일명(2x): `kidk_mission_savings@2x.png`
  - 파일명(3x): `kidk_mission_savings@3x.png`
  - 권장 사이즈/비율: **28x28 / 56x56 / 84x84 px 권장(아이콘은 중앙 배치), 1:1 권장**
  - 사용 화면: **미션 생성 시트(일일 미션 아이콘), 미션 카드(저축 미션 아이콘)**

---

## 3) 완료 팝업 선물박스 원본 교체

- [ ] Asset key: `kidk_mission_completed_gift`
  - 파일명(1x): `kidk_mission_completed_gift.png`
  - 파일명(2x): `kidk_mission_completed_gift@2x.png`
  - 파일명(3x): `kidk_mission_completed_gift@3x.png`
  - 권장 사이즈/비율: **280x220 / 560x440 / 840x660 px, 14:11 비율 권장**
  - 사용 화면: **키득시티 > 미션 완료 팝업 일러스트**

---

## 4) 건물1(학교) 상세 전용 일러스트 (신규 키 제안)

> 이 2개는 최신 문서에 “요청 필요”로 남아 있으나 코드 key가 아직 고정되지 않아,
> 아래 key로 전달하면 바로 Asset Catalog 등록/연동하기 좋습니다.

- [ ] Asset key(제안): `kidk_building_mission_detail_bg`
  - 파일명(1x): `kidk_building_mission_detail_bg.png`
  - 파일명(2x): `kidk_building_mission_detail_bg@2x.png`
  - 파일명(3x): `kidk_building_mission_detail_bg@3x.png`
  - 권장 사이즈/비율: **가로형 카드 배경(약 1.35:1), 9-slice(늘림) 대응 권장**
  - 사용 화면: **키득시티 > 학교 건물 탭 시 노출되는 미션 상세 오버레이 배경**

- [ ] Asset key(제안): `kidk_building_mission_reward_badge`
  - 파일명(1x): `kidk_building_mission_reward_badge.png`
  - 파일명(2x): `kidk_building_mission_reward_badge@2x.png`
  - 파일명(3x): `kidk_building_mission_reward_badge@3x.png`
  - 권장 사이즈/비율: **72x24 / 144x48 / 216x72 px 기준, 3:1 권장**
  - 사용 화면: **키득시티 > 학교 건물 미션 상세 오버레이의 ‘보상’ 배지 영역**

---

### 전달 시 주의
- PNG 투명 배경 권장
- 파일명은 **Asset key와 100% 동일**하게 저장
- 아이콘은 외곽 여백 포함해도 되지만, 중심 정렬 기준으로 제작