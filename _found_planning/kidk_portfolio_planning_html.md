# {{PAGE_INTRO}} / 10 — 키득 (KIDK)

## 헤더
- 앱: 키득 (KIDK)
- 한줄 설명: 게임형 어린이 금융 교육 앱
- QR: App Store

## 스크린샷 라벨
- 프로젝트 홈
- 키컬러 편집
- 합성 미리보기
- 미션 생성
- 도시 레벨업
- 리포트

## 기획 의도
- Problem: 초등학교 3~6학년은 용돈 관리·저축을 체계적으로 배울 기회가 부족하고, 전통 금융 교육은 흥미를 유발하지 못하며 외부 API 기반 앱은 프라이버시 리스크가 있다.
- Solution: 게임화된 가상 경제(키득 시티)와 미션 기반 학습, 온디바이스 <span class="text-bold">Foundation Models</span> 코칭으로 흥미와 프라이버시를 동시에 충족하고, 부모가 승인·모니터링할 수 있는 협업 구조를 제공한다.

## 프로젝트 정보
- 개발 기간: 2025.11 - (진행중)
- 플랫폼: iOS 18.0+
- 역할: iOS 개발 및 서버 기획
- 상태: App Store 예정
- 태그: 어린이 금융, 게임화, 온디바이스 AI, OCR, 인증

## 핵심 기능
1. 온디바이스 AI 코칭: <span class="text-bold">Foundation Models</span>로 소비 패턴을 로컬 분석해 맞춤 조언 제공
2. 미션 기반 금융 학습: 저축·소비·퀴즈·영상 미션, 부모가 생성·승인·모니터링
3. 키득 시티: 레벨별 해금되는 가상 도시에서 금융 개념 체험
4. 영수증 OCR & 협업: <span class="text-bold">Vision OCR</span>로 자동 분류, 소비 리포트, 부모 승인 한도 설정

## 기술 스택
- UI: UIKit, SnapKit, SwiftUI
- Architecture: MVVM, Coordinator, Clean Architecture
- Data: Core Data, Realm, Firebase Custom Token
- Reactive: RxSwift, Combine

---

# {{PAGE_IMPL}} / 10 — 키득 (KIDK) 핵심 구현

## 01 Keychain 기반 토큰 보안 저장
UserDefaults 저장을 Keychain으로 전환해 토큰 탈취 리스크를 차단했다.

**문제**
초기에는 <span class="text-bold">Access Token</span>과 <span class="text-bold">Refresh Token</span>을 <span class="text-bold">UserDefaults</span>에 저장해 자동 로그인이 동작했지만, 보안 검토에서 저장 방식 자체가 취약하다는 문제가 확인되었다. <span class="text-bold">UserDefaults</span>는 평문이라 탈옥 기기나 백업 파일에서 읽힐 수 있고, 토큰이 노출되면 계정 위장 API 호출이나 무제한 토큰 갱신으로 이어질 수 있었다. 따라서 로그인 편의성과 별개로 토큰 저장소를 보안 저장소로 전환해야 했다.


**접근**
시스템 레벨 암호화 저장소인 <span class="text-bold">Keychain</span>을 도입해 토큰을 보관했다. 보안 API를 래핑한 클래스를 만들고 <span class="text-bold">Access Token</span>과 <span class="text-bold">Refresh Token</span>을 구분해 저장했으며, 저장 시도 시 이미 존재하는 항목은 자동으로 업데이트하도록 했다. 저장소 인터페이스를 분리해 테스트 환경에서는 실제 보안 저장소 대신 임시 메모리를 사용하도록 했다. 로그아웃은 두 토큰을 모두 삭제하는 단일 메서드로 구현했으며, 서버 요청 실패 여부와 관계없이 로컬 데이터는 항상 정리되도록 보장했다.

**결과**
<span class="text-bold">Keychain</span> 도입으로 토큰 탈취 위험이 제거되었다. <span class="text-bold">UserDefaults</span> 사용 시 백업 파일에서 평문 토큰을 추출할 수 있었으나, <span class="text-bold">Keychain</span> 적용 후 암호화된 저장소로 보호되어 동일한 공격 방법이 차단되었다. 탈옥 기기에서도 추가 공격 없이는 토큰에 접근할 수 없게 되었고, 아동 용돈 데이터를 다루는 앱의 보안 요구사항을 충족했다. 저장소 추상화를 통해 다른 민감 데이터도 동일한 보안 수준으로 보호할 수 있는 기반이 마련되었다.

## 02 Firebase-백엔드 이중 인증 흐름 통합

앱 로그인 과정을 하나의 흐름으로 통합

**문제**
<span class="text-bold">Firebase Authentication</span>과 백엔드 <span class="text-bold">JWT</span>를 함께 쓰는 구조에서, 사용자는 Firebase로 로그인하지만 API 호출에는 백엔드가 발급한 <span class="text-bold">Access Token/Refresh Token</span>이 필요했다. 
따라서 <span class="text-bold">Firebase 로그인 → ID Token/UID 획득 → 백엔드 JWT 교환 → Keychain 저장</span>을 <span class="text-bold">순차적으로</span> 처리해야 했고, 단계별 실패 원인(Firebase/백엔드)을 구분해 안내해야 했다.

**접근**
Firebase의 비동기 API를 <span class="text-bold">RxSwift</span> 스트림으로 변환해, Firebase 로그인 성공 결과(<span class="text-bold">ID Token/UID</span>)를 다음 단계의 백엔드 로그인으로 <span class="text-bold">체이닝</span>하는 <span class="text-bold">2단계 흐름</span>을 구성했다. 
각 단계의 실패는 스트림에서 <span class="text-bold">에러로 전파</span>해 체인을 즉시 중단시키고, 오류 출처에 따라 메시지를 분기했다. 
모든 단계 성공 시 사용자 정보 저장과 <span class="text-bold">Keychain</span> 토큰 저장을 한 번에 마무리하고, 자동 로그인 상태에 따라 이메일 자동 채움도 함께 처리했다.

**결과**
콜백 중첩 없이 <span class="text-bold">Firebase → 백엔드</span> 순차 흐름이 코드에서 명확해졌고, 실패 지점에 따라 사용자에게 일관된 안내가 가능해졌다. 
사용자는 하나의 로그인만 수행하면 내부적으로 토큰 교환과 저장까지 완료되어, 두 인증 시스템을 <span class="text-bold">투명하게</span> 사용할 수 있게 됐다.





## 03 REST API 통신 계층과 토큰 인터셉터 기반 인증 자동화

공통 응답 규격과 요청 인터셉터로 <span class="text-bold">20개 엔드포인트</span>의 통신/인증 처리를 한 흐름으로 통일했다.

**문제**
Spring/AWS 백엔드의 <span class="text-bold">REST API 20개</span>를 iOS에서 연결해야 했는데, 엔드포인트마다 성공/실패 응답 형태가 달라 디코딩과 에러 처리가 화면마다 흩어졌다. 
초기에는 <span class="text-bold">API 3개</span>를 구현하는 데 각각 평균 <span class="text-bold">2시간</span>이 걸려, 같은 방식이면 최소 <span class="text-bold">40시간</span>이 필요해 일정 위험이 컸다. 
또한 <span class="text-bold">401</span> 처리(토큰 만료/권한 부족) 기준이 <span class="text-bold">ViewModel</span>마다 반복되어 사용자 메시지와 UI 분기 기준이 일관되지 않았고, 요청마다 올바른 토큰을 넣어야 해 실수 가능성도 있었다.

**접근**
백엔드 팀과 응답을 <span class="text-bold">공통 포맷</span>으로 통일해, 모든 API가 <span class="text-bold">성공 데이터</span> 또는 <span class="text-bold">실패 정보(상태/코드/메시지)</span>를 같은 규격으로 내려주도록 합의했다. 
iOS에서는 <span class="text-bold">NetworkService</span>가 이 공통 포맷을 한 번에 해석해 <span class="text-bold">성공이면 데이터</span>, <span class="text-bold">실패면 오류</span>로 변환해 화면에는 동일한 기준으로 전달되게 했다. 
인증은 <span class="text-bold">RequestInterceptor</span>로 요청 직전에 헤더를 자동 구성하도록 바꾸고, 엔드포인트마다 <span class="text-bold">인증 필요 여부</span>와 <span class="text-bold">사용 토큰(액세스/리프레시)</span>만 선언하면 상황에 맞게 주입되도록 했다. 
토큰은 <span class="text-bold">TokenManager</span>가 <span class="text-bold">Keychain</span>에서 관리해 갱신 이후에도 항상 최신 값이 적용되도록 정리했다.

**결과**
응답 처리와 에러 기준이 통일되면서 원인 추적 시간이 평균 <span class="text-bold">30분</span>에서 <span class="text-bold">5분</span>으로 단축됐고, API 1개당 구현 시간도 <span class="text-bold">2시간</span>에서 <span class="text-bold">20분</span>으로 줄었다. 
그 결과 <span class="text-bold">20개 엔드포인트</span>를 <span class="text-bold">1주</span> 안에 마무리하고 UI 개선에 시간을 돌릴 수 있었으며, 모든 화면에서 <span class="text-bold">동일한 오류 메시지/동작</span>을 유지했다. 
또한 인터셉터가 토큰 선택과 주입을 자동화해 토큰 타입 실수를 예방했다.

## 04 Vision 프레임워크 기반 영수증 OCR 자동 파싱

키워드 기반 컨텍스트 분석과 자동 입력 후 검증 워크플로우로 입력 시간 75% 단축

**문제**
아이들이 영수증 금액과 상호명을 매번 직접 입력해야 해 번거로웠고, 초등학생 사용자는 숫자 입력 실수가 잦아 입력이 길어지면 사용을 포기하곤 했다. 
OCR로 자동 생성하면 시간을 줄일 수 있지만, 영수증이 <span class="text-bold">구겨짐/반사/일부 누락</span> 상태면 Vision 인식 정확도가 떨어졌다. 
특히 금액을 잘못 읽으면 잔액이 크게 왜곡될 수 있어, <span class="text-bold">자동 입력</span>과 <span class="text-bold">사용자 확인</span>의 경계를 설계해야 했다.

**접근**
<span class="text-bold">Vision</span> 텍스트 인식을 <span class="text-bold">accurate</span>로 설정하고 한글/영어를 함께 켜 혼합 텍스트의 인식 정확도를 우선했다. 
<span class="text-bold">Document Camera</span>로 영수증 경계를 감지하고 보정해 입력 이미지를 안정적으로 확보했다. 
금액은 <span class="text-bold">합계/총액/결제금액/total</span> 같은 키워드를 먼저 찾고 주변 <span class="text-bold">3줄</span> 이내 숫자를 선택하되, 실패 시 <span class="text-bold">가장 큰 숫자</span>를 후보로 두는 규칙으로 파싱했다. 
상호명은 상단 <span class="text-bold">5줄</span>에서 조건을 만족하는 텍스트를 선택해 주소·전화번호 오인식을 줄였고, 결과는 자동 채움 후 사용자가 수정할 수 있게 하면서 <span class="text-bold">필수 값 검증</span>을 통과해야 저장되도록 했다.

**결과**
입력 시간이 <span class="text-bold">30초</span>에서 <span class="text-bold">8초</span>로 줄어 <span class="text-bold">75%</span> 단축됐고, 오류율도 <span class="text-bold">5% → 1%</span>로 감소했다. 
<span class="text-bold">Document Camera</span> 적용으로 인식률이 <span class="text-bold">75% → 95%</span>로 올라 다양한 상태의 영수증에서도 안정적으로 동작했다. 
<span class="text-bold">자동 입력 후 확인</span> 흐름으로 잘못된 금액 저장을 막아 잔액 정확성을 지키면서, 아이들이 거래 기록을 꾸준히 남길 수 있는 경험을 만들었다.