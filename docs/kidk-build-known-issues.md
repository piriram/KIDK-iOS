# KIDK Build Known Issues (Quick Fix)

## 1) Swift MainActor/Concurrency 에러 대량 발생

증상 예시:
- `Main actor-isolated ... cannot be used in nonisolated context`
- `Decodable conformance ... actor-isolated`

빠른 복구:
- Build Settings에서 `Strict Concurrency Checking`을 `Targeted`로 설정
- pbxproj 키: `SWIFT_STRICT_CONCURRENCY = targeted;`

적용 위치:
- `KIDK.xcodeproj/project.pbxproj` (Debug/Release)

주의:
- 근본 해결은 아님. 장기적으로 actor 경계 정리 필요.

## 2) FigmaSnapshotScenario 컴파일 에러

증상 예시:
- `KIDKCityViewController has no member 'setDebugSnapshotAction'`

확인 포인트:
- `KIDKCityViewController`에 아래 debug API 존재 여부
  - `enum DebugSnapshotAction`
  - `func setDebugSnapshotAction(_:)`
  - `runDebugSnapshotActionIfNeeded()`

## 3) xcodeproj 커밋이 안 되는 경우

증상:
- `The following paths are ignored ... KIDK.xcodeproj`

대응:
- 프로젝트 정책 확인 후 필요 시 강제 add
  - `git add -f KIDK.xcodeproj/project.pbxproj`
