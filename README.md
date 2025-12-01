# 키득키득 (KIDK)

어린이를 위한 금융 교육 iOS 앱

## 프로젝트 소개

키득키득은 어린이들이 용돈 관리, 저축, 미션 수행을 통해 재미있게 금융 개념을 배울 수 있는 iOS 애플리케이션임

## 주요 기능

- Firebase 인증 기반 로그인 (어린이/부모 계정)
- 지갑 및 저금통 계좌 관리
- 거래 내역 조회 및 분석
- 미션 수행 및 보상 시스템
- 월간 소비 리포트

## 기술 스택

- Swift 5.x
- UIKit + SnapKit
- RxSwift/RxCocoa (MVVM)
- Firebase Authentication
- Realm Database
- Moya (네트워킹)

## 프로젝트 설정

### 1. 사전 요구사항

- Xcode 15.0 이상
- iOS 15.0 이상
- CocoaPods 또는 Swift Package Manager

### 2. 저장소 클론

```bash
git clone https://github.com/your-username/KIDK.git
cd KIDK
```

### 3. 의존성 설치

```bash
pod install
```

### 4. Secrets 설정

민감한 정보(API URL 등)는 `Secrets.plist` 파일로 관리됨. 다음 단계를 따라 설정:

#### 4-1. Secrets.plist 파일 생성

```bash
cd KIDK/Config
cp Secrets.plist.example Secrets.plist
```

#### 4-2. Secrets.plist 내용 수정

`KIDK/Config/Secrets.plist` 파일을 열고 실제 값으로 교체:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>API_BASE_URL_DEV</key>
    <string>http://your-dev-api-url:8080/api/v1</string>
    <key>API_BASE_URL_PROD</key>
    <string>https://your-prod-api-url.com/api/v1</string>
    <key>SWAGGER_URL_DEV</key>
    <string>http://your-dev-api-url:8080/swagger-ui/index.html</string>
</dict>
</plist>
```

**주의:** `Secrets.plist` 파일은 `.gitignore`에 포함되어 있어 Git에 커밋되지 않음

### 5. Firebase 설정

#### 5-1. Firebase 프로젝트 생성

1. [Firebase Console](https://console.firebase.google.com)에서 새 프로젝트 생성
2. iOS 앱 추가 (Bundle ID: `com.yourcompany.KIDK`)
3. `GoogleService-Info.plist` 파일 다운로드

#### 5-2. GoogleService-Info.plist 설치

다운로드한 `GoogleService-Info.plist` 파일을 `KIDK/` 디렉토리에 복사:

```bash
cp ~/Downloads/GoogleService-Info.plist KIDK/
```

**주의:** 이 파일도 `.gitignore`에 포함되어 Git에 커밋되지 않음

#### 5-3. Firebase Authentication 활성화

Firebase Console에서 Authentication → Sign-in method → 이메일/비밀번호 활성화

### 6. 빌드 및 실행

1. Xcode에서 `KIDK.xcworkspace` 열기 (`.xcodeproj`가 아님)
2. 시뮬레이터 또는 실제 기기 선택
3. `Cmd + R`로 빌드 및 실행

## 프로젝트 구조

```
KIDK/
├── Data/
│   ├── Network/         # API 통신 레이어
│   ├── Repository/      # 데이터 저장소 패턴
│   └── Model/           # 도메인 모델
├── Presentation/
│   ├── View/            # UIViewController
│   ├── ViewModel/       # RxSwift ViewModel
│   └── Coordinator/     # 화면 전환 관리
├── Core/
│   └── Util/            # 유틸리티 (SecretsManager 등)
└── Config/
    ├── Secrets.plist.example  # 설정 템플릿 (Git 포함)
    └── Secrets.plist          # 실제 설정 (Git 제외)
```

## 아키텍처 특징

- **MVVM + Coordinator Pattern**: 화면 전환과 비즈니스 로직 분리
- **Repository Pattern**: 데이터 소스 추상화 (Mock/Real API 전환 용이)
- **Actor Pattern**: UserProfileManager에서 thread-safe 상태 관리
- **Generic + Protocol**: StorageProtocol로 확장 가능한 저장소 레이어
- **Property Wrapper**: @UserDefault로 선언적 UserDefaults 접근

## 보안

- API URL과 Firebase 설정 파일은 `.gitignore`로 Git 저장소에서 제외
- `Secrets.plist.example` 파일로 필요한 설정 항목 안내
- Keychain을 통한 안전한 토큰 저장

## 라이선스

이 프로젝트는 포트폴리오 목적으로 작성됨
