# 🚀 KIDK 배포 가이드

이 문서는 KIDK 앱을 App Store에 배포하기 위한 단계별 가이드입니다.

---

## 📋 배포 전 체크리스트

### 1. ✅ 프로덕션 서버 URL 확인

`KIDK/Config/Secrets.plist` 파일을 열어서 프로덕션 URL이 올바른지 확인:

```xml
<key>API_BASE_URL_PROD</key>
<string>https://api.kidk.com/api/v1</string>
```

⚠️ **주의**: 프로덕션은 반드시 `https://`를 사용해야 합니다 (HTTP는 App Store 심사 탈락)

---

### 2. ✅ 버전 및 빌드 번호 업데이트

Xcode에서:
1. **TARGETS** → **KIDK** 선택
2. **General** 탭
3. **Version**: 사용자에게 보이는 버전 (예: `1.0.0`)
4. **Build**: 내부 빌드 번호 (예: `1`)

> 💡 App Store에 업데이트할 때마다 Build 번호는 반드시 증가해야 합니다.

---

### 3. ✅ Info.plist 확인

`KIDK/Info.plist`에서 다음 항목 확인:

- ✅ Bundle Identifier: `com.yourcompany.KIDK`
- ✅ Display Name: `KIDK` (개발용 -DEV 제거)
- ✅ Privacy 설명 문구 (카메라, 사진 등)

---

### 4. ✅ 개발자 계정 및 인증서

1. **Apple Developer Program 가입** (연 129,000원)
   - https://developer.apple.com/programs/

2. **Distribution Certificate 생성**
   - Xcode → **Preferences** → **Accounts**
   - Apple ID 추가 → **Manage Certificates** → **+** → **Apple Distribution**

3. **App ID 등록**
   - https://developer.apple.com/account
   - **Identifiers** → **+** → Bundle ID 입력

4. **Provisioning Profile 생성**
   - **Profiles** → **+** → **App Store** 선택
   - App ID 및 Certificate 선택

---

## 🏗️ Archive 빌드 단계

### Step 1: Scheme을 Release로 설정

Xcode 상단 메뉴:
```
Product → Scheme → Edit Scheme...
```

**Run** 탭에서:
- ❌ Build Configuration: **Debug** (개발용)
- ✅ Build Configuration: **Release** (배포용)

하지만 Archive는 자동으로 Release를 사용하므로 이 단계는 선택사항입니다.

---

### Step 2: Archive 생성

1. Xcode 메뉴:
   ```
   Product → Archive
   ```
   또는 단축키: `Cmd + Shift + B`

2. 빌드가 완료되면 **Organizer** 창이 자동으로 열림

3. 왼쪽 **Archives** 목록에서 방금 생성한 Archive 선택

---

### Step 3: Archive 검증

**Organizer**에서:

1. **Validate App** 버튼 클릭
2. Distribution Certificate 선택
3. Provisioning Profile 자동 선택 (또는 수동 선택)
4. 검증 완료까지 대기

✅ **검증 통과** → App Store 업로드 가능
❌ **검증 실패** → 에러 메시지 확인 후 수정

---

### Step 4: App Store Connect 업로드

1. **Distribute App** 버튼 클릭
2. **App Store Connect** 선택
3. **Upload** 선택
4. 옵션 확인:
   - ✅ Include bitcode for iOS content (선택사항)
   - ✅ Upload your app's symbols (크래시 분석용 권장)
5. **Upload** 버튼 클릭

업로드 완료 후 5~10분 대기 → App Store Connect에서 확인 가능

---

## 🌐 App Store Connect 설정

### 1. 앱 정보 등록

https://appstoreconnect.apple.com 접속

1. **나의 앱** → **+** → **새로운 앱**
2. 정보 입력:
   - 플랫폼: iOS
   - 이름: KIDK
   - 기본 언어: 한국어
   - 번들 ID: `com.yourcompany.KIDK`
   - SKU: `KIDK-001` (고유 식별자)

---

### 2. 앱 버전 정보

1. **버전 정보**:
   - 스크린샷 (iPhone 6.7", 6.5" 필수)
   - 미리보기 비디오 (선택)
   - 홍보용 텍스트
   - 설명
   - 키워드
   - 지원 URL
   - 마케팅 URL (선택)

2. **일반 정보**:
   - 아이콘 (1024x1024px)
   - 연령 등급
   - 카테고리 (금융, 교육)

---

### 3. 빌드 선택

1. **빌드** 섹션에서 **+** 버튼 클릭
2. 업로드한 빌드 선택
3. Export Compliance 답변:
   - 암호화 사용 여부 (HTTPS만 사용하면 No)

---

### 4. 심사 제출

1. 모든 필수 항목 입력 완료 확인
2. **심사를 위해 제출** 버튼 클릭
3. 심사 대기 (평균 1~3일)

---

## 🔍 배포 후 확인 사항

### 1. Production 환경 확인

앱 실행 시 콘솔에 **아무것도 출력되지 않아야 합니다**:

❌ **개발 환경** (나쁜 예):
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📱 KIDK App Configuration
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🏗️  Environment: 개발
...
```

✅ **프로덕션 환경** (좋은 예):
```
(환경 정보 출력 없음)
```

---

### 2. Settings 화면 확인

설정 화면에서:

✅ **개발용 버튼이 보이지 않아야 함**:
- ❌ 🏠 가족 생성 (부모용) → 숨김
- ❌ 👶 가족 가입 (자녀용) → 숨김
- ✅ 로그아웃 버튼만 표시

---

### 3. API 호출 확인

네트워크 요청이 프로덕션 서버로 가는지 확인:

❌ `http://43.202.165.98:8080` (개발 서버)
✅ `https://api.kidk.com` (프로덕션 서버)

Xcode 디버그 콘솔에서 확인 가능 (단, Release 빌드에서는 로그가 최소화됨)

---

## 🐛 자주 발생하는 문제

### 1. "No Provisioning Profile Found"

**원인**: Provisioning Profile이 없거나 만료됨

**해결**:
1. Xcode → **Preferences** → **Accounts**
2. Apple ID 선택 → **Download Manual Profiles**
3. 또는 https://developer.apple.com에서 새로 생성

---

### 2. "This bundle is invalid - Info.plist"

**원인**: Info.plist에 필수 권한 설명이 누락됨

**해결**:
```xml
<!-- 카메라 사용 시 -->
<key>NSCameraUsageDescription</key>
<string>프로필 사진 촬영을 위해 카메라 접근이 필요합니다.</string>

<!-- 사진 라이브러리 접근 시 -->
<key>NSPhotoLibraryUsageDescription</key>
<string>프로필 사진 선택을 위해 사진 접근이 필요합니다.</string>
```

---

### 3. "App Transport Security"

**원인**: HTTP를 사용하려고 시도 (프로덕션에서는 불가)

**해결**: 프로덕션 서버를 반드시 HTTPS로 설정
```xml
<key>API_BASE_URL_PROD</key>
<string>https://api.kidk.com/api/v1</string>
```

---

### 4. "Missing Compliance"

**원인**: Export Compliance 미응답

**해결**:
1. App Store Connect → 빌드 선택
2. "Provide Export Compliance Information" 클릭
3. 암호화 사용 여부 답변 (일반적으로 No)

---

## 📊 배포 프로세스 요약

```
┌─────────────────────────────────────────┐
│ 1. Secrets.plist 프로덕션 URL 확인      │
└─────────────────┬───────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│ 2. 버전/빌드 번호 업데이트              │
└─────────────────┬───────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│ 3. Product → Archive (Cmd+Shift+B)     │
└─────────────────┬───────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│ 4. Validate App (검증)                  │
└─────────────────┬───────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│ 5. Distribute → App Store Connect      │
└─────────────────┬───────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│ 6. App Store Connect에서 빌드 선택     │
└─────────────────┬───────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│ 7. 앱 정보 입력 (스크린샷, 설명 등)    │
└─────────────────┬───────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│ 8. 심사 제출                            │
└─────────────────┬───────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│ 9. 심사 대기 (1~3일)                    │
└─────────────────┬───────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│ 10. 승인 → App Store 출시! 🎉          │
└─────────────────────────────────────────┘
```

---

## 💡 추가 팁

### TestFlight 베타 테스트 (선택사항)

App Store 정식 출시 전에 베타 테스터들에게 먼저 배포 가능:

1. Archive 업로드 (위와 동일)
2. App Store Connect → **TestFlight** 탭
3. 내부/외부 테스터 초대
4. 피드백 수집 후 정식 출시

---

### Fastlane 자동화 (선택사항)

나중에 배포 과정을 자동화하려면 Fastlane 도입:

```bash
# Fastlane 설치
gem install fastlane

# 초기화
cd /path/to/KIDK
fastlane init

# 자동 배포
fastlane release
```

---

## 📞 문의

배포 중 문제 발생 시:
- Apple Developer Support: https://developer.apple.com/support/
- App Store Connect 헬프: https://help.apple.com/app-store-connect/

---

**마지막 업데이트**: 2024-12-02
