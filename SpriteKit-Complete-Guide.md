# SpriteKit 완전 가이드 (iOS/macOS/tvOS)

> 작성일: 2026-02-19 (KST)
> 목적: SpriteKit을 처음부터 실무/출시 단계까지 한 번에 참고할 수 있는 문서

---

## 1) SpriteKit이란?

SpriteKit은 Apple의 **2D 게임 프레임워크**입니다.

- 렌더링(스프라이트, 텍스트, 도형)
- 애니메이션(SKAction)
- 물리 엔진(SKPhysics)
- 파티클(SKEEmitterNode)
- 타일맵(SKTileMapNode)
- 오디오(SKAudioNode)

를 하나의 엔진으로 제공해서, UIKit/SwiftUI 앱 안에서 바로 게임 장면을 만들 수 있습니다.

### 언제 SpriteKit을 쓰면 좋은가

- 2D 게임/미니게임
- 인터랙티브 애니메이션 화면
- 교육용/키즈 앱의 게임형 UI
- SceneKit/Metal까지는 과하고, Canvas만으로는 부족한 경우

### 언제 다른 선택이 나을 수 있나

- 고급 3D: SceneKit/RealityKit/Unity/Unreal
- 완전 커스텀 GPU 파이프라인: Metal
- 멀티플랫폼 게임 엔진 중심 개발: Unity/Godot

---

## 2) 핵심 아키텍처

SpriteKit의 기본 구조:

`SKView` → `SKScene` → `SKNode` 트리

- **SKView**: 화면에 Scene을 렌더링하는 컨테이너
- **SKScene**: 한 화면(레벨/메뉴/게임 플레이)
- **SKNode**: 화면 구성요소의 기본 단위
  - SKSpriteNode: 이미지
  - SKLabelNode: 텍스트
  - SKShapeNode: 벡터 도형
  - SKCameraNode: 카메라
  - SKEmitterNode: 파티클

### 좌표계

- 기본적으로 Scene 내부 좌표로 작업
- 앵커/포지션/스케일/회전은 노드 계층 기준으로 누적
- `zPosition`으로 그리기 순서 제어

---

## 3) 게임 루프와 생명주기

대표 훅:

- `didMove(to:)` : Scene 진입 초기화
- `update(_ currentTime:)` : 매 프레임 로직
- `didEvaluateActions()`
- `didSimulatePhysics()`
- `didApplyConstraints()`
- `didFinishUpdate()`

권장 패턴:

1. 입력 수집
2. 게임 상태 업데이트(고정 timestep 권장)
3. 물리 결과 반영
4. 렌더 상태 반영

**팁:** 프레임 드랍 시 게임 속도가 달라지지 않게 `deltaTime` 기반으로 이동/타이머 계산.

---

## 4) 자주 쓰는 주요 타입 요약

### 장면/노드

- `SKScene`: 장면 루트
- `SKNode`: 트리 구조의 기본
- `SKSpriteNode`: 텍스처 렌더
- `SKLabelNode`: 텍스트
- `SKShapeNode`: 도형
- `SKCameraNode`: 카메라 뷰
- `SKCropNode`: 마스킹
- `SKEffectNode`: Core Image 필터

### 애니메이션/전환

- `SKAction`: move/scale/fade/sequence/group/repeat
- `SKTransition`: 장면 전환

### 물리

- `SKPhysicsBody`
- `SKPhysicsWorld`
- `SKPhysicsContactDelegate`
- `SKPhysicsJoint*` (pin/spring/limit/fixed/sliding)

### 리소스

- `SKTexture`
- `SKTextureAtlas`
- `SKMutableTexture`

### 고급

- `SKShader`, `SKUniform`, `SKAttribute`
- `SKWarpGeometryGrid`
- `SKTileMapNode`, `SKTileSet`, `SKTileGroup`
- `SK3DNode` (SceneKit 임베딩)
- `SKRenderer` (커스텀 렌더 경로)

---

## 5) 시작 템플릿 (UIKit)

```swift
import UIKit
import SpriteKit

final class GameViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let skView = SKView(frame: view.bounds)
        skView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(skView)

        let scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)

        skView.showsFPS = true
        skView.showsNodeCount = true
    }
}

final class GameScene: SKScene {
    override func didMove(to view: SKView) {
        backgroundColor = .black

        let player = SKSpriteNode(color: .systemBlue, size: .init(width: 60, height: 60))
        player.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        addChild(player)
    }

    override func update(_ currentTime: TimeInterval) {
        // frame update
    }
}
```

---

## 6) SwiftUI 통합

### 기본 패턴

- iOS 14+: `SpriteView(scene:)` 사용 가능
- 또는 `UIViewRepresentable`로 `SKView` 직접 래핑

```swift
import SwiftUI
import SpriteKit

struct GameScreen: View {
    private let scene: SKScene = {
        let s = GameScene(size: CGSize(width: 390, height: 844))
        s.scaleMode = .resizeFill
        return s
    }()

    var body: some View {
        SpriteView(scene: scene)
            .ignoresSafeArea()
    }
}
```

실무 팁:

- Scene 상태와 SwiftUI 상태를 억지로 양방향 바인딩하지 말고,
  **게임 상태 스토어(ObservableObject)** 를 중간에 두는 구조가 안정적.

---

## 7) 입력 처리

### iOS 터치

- `touchesBegan / Moved / Ended / Cancelled`
- `nodes(at:)`, `atPoint(_:)`로 히트 테스트

### 제스처와 병행

- UIKit GestureRecognizer와 혼용 가능
- 단, 충돌 방지를 위해 우선순위/이벤트 전달 설계 필요

### macOS

- 마우스 이벤트 (`mouseDown`, `mouseDragged` 등)

---

## 8) 물리 엔진 실무

### 핵심 속성

- `isDynamic`, `affectedByGravity`, `allowsRotation`
- `mass`, `friction`, `restitution`, `linearDamping`

### 충돌 마스크 설계

- `categoryBitMask`
- `collisionBitMask`
- `contactTestBitMask`

권장: enum/OptionSet으로 타입 안전하게 관리.

```swift
enum PhysicsCategory {
    static let player: UInt32 = 1 << 0
    static let enemy: UInt32  = 1 << 1
    static let wall: UInt32   = 1 << 2
}
```

### Contact delegate

- `didBegin(_ contact:)`
- `didEnd(_ contact:)`

주의:

- Contact callback 안에서 노드 즉시 제거/씬 전환 시 크래시 유발 가능
- 큐에 담아 `update` 말미에서 처리하면 안정적

---

## 9) 애니메이션 전략

### SKAction 장점

- 선언형, 간단, 재사용 쉬움

### 한계

- 복잡한 상태 머신/블렌딩에는 비효율

실무 조합 권장:

- 위치/스케일/페이드 = SKAction
- 전투/스킬/AI 상태 = 직접 업데이트 + 상태 머신(GameplayKit)

---

## 10) 카메라/월드 구성

- 월드 노드(`worldNode`)와 UI 노드(`hudNode`) 분리
- 카메라(`SKCameraNode`)는 월드를 따라가고 HUD는 고정
- 흔들림, 줌, 경계 클램프를 카메라 유틸로 분리하면 재사용 좋음

---

## 11) 타일맵

`SKTileMapNode` + `SKTileSet`으로 타일 기반 레벨 제작 가능.

- 장점: 레벨 디자인 속도 빠름
- 주의: 초대형 맵은 분할 로딩/청크 관리 필요

---

## 12) 파티클/이펙트/셰이더

### 파티클

- `SKEmitterNode`로 불꽃/연기/반짝임 구현
- 풀링(Pooling) 적용하면 성능 안정

### EffectNode

- 블러/색보정 등 후처리 가능
- 과도한 필터는 GPU 비용 큼

### Shader

- `SKShader`, `SKUniform`로 커스텀 효과
- 디바이스별 GPU 편차 고려 필수

---

## 13) 오디오

- 간단 배경음/효과음: `SKAudioNode`
- 복잡한 믹싱/인터럽트 대응: `AVAudioEngine` 병행 권장

실무 팁:

- 효과음 중복 재생 제한(voice limit)
- 앱 백그라운드/인터럽트(전화, Siri) 대응 로직 분리

---

## 14) 성능 최적화 체크리스트

### 렌더링

- 불필요한 노드 수 줄이기
- 텍스처 아틀라스 사용
- 오버드로우 과다 피하기
- alpha blending 많은 레이어 주의

### CPU

- `update`에서 할당 최소화
- 문자열/배열 생성 반복 피하기
- 충돌 판정 범위 줄이기

### 물리

- 필요 없는 body는 비활성/제거
- contactTest 대상을 최소화

### 디버그

- `showsFPS`, `showsNodeCount`, `showsPhysics`
- Instruments(Time Profiler, Allocations, Metal System Trace)

---

## 15) 씬 설계 패턴 (실무 권장)

### 권장 레이어

1. `GameScene` (렌더 루트)
2. `GameWorldNode` (맵/오브젝트)
3. `HUDNode` (점수/버튼)
4. `GameCoordinator` (씬 전환/DI)
5. `GameStateStore` (상태 단일 소스)

### 안티패턴

- Scene에 모든 로직 몰아넣기
- 노드 이름 문자열로만 참조
- 비동기 로딩과 씬 생명주기 경합 방치

---

## 16) 테스트 전략

- 순수 로직(점수/판정/쿨타임)은 XCTest 단위 테스트
- Scene 로직은 상태 주입 가능 구조로 분리
- 스냅샷 테스트(핵심 UI 프레임) 고려

---

## 17) GameplayKit과의 조합

SpriteKit 단독으로도 가능하지만, 규모 커지면 조합이 강력함.

- `GKStateMachine`: 게임 상태 전이
- `GKComponentSystem`: 엔티티 구성
- `GKAgent`: 이동/군집
- `GKRandom`: 랜덤 일관성
- `GKNoise`: 지형/패턴 생성

---

## 18) 멀티플랫폼 포인트

- iOS/macOS/tvOS 지원
- 입력 체계(터치/마우스/리모컨) 추상화 필요
- 해상도/비율/세이프 영역 고려 필수

---

## 19) 흔한 함정 & 해결

1. **프레임 의존 로직**
   - 증상: 기기마다 속도 차이
   - 해결: deltaTime 기반

2. **물리 contact 폭주**
   - 증상: CPU 급증
   - 해결: bitmask 최소화, body 단순화

3. **리소스 즉시 로딩 스파이크**
   - 증상: 첫 진입 끊김
   - 해결: 프리로드(텍스처/아틀라스/오디오)

4. **Action 남발**
   - 증상: 디버깅 어려움
   - 해결: 상태 머신 + 명시적 업데이트 혼합

5. **Scene 교체 시 메모리 잔류**
   - 해결: 강한 참조 사이클(delegate/closure) 점검

---

## 20) 실전 빌드 순서 (추천)

1. 핵심 게임 루프/승패 조건부터 코드로
2. 월드/HUD 레이어 분리
3. 입력/물리 최소 구현
4. 플레이 가능한 MVP 완성
5. 이펙트/사운드/연출 추가
6. Instruments 기반 병목 제거
7. 난이도/밸런스 데이터화
8. 테스트/크래시 로그 정리 후 배포

---

## 21) KIDK-iOS에 바로 적용할 때 제안

현재 `Feat/game` 브랜치 기준으로 바로 시작하려면:

- `GameScene.swift` + `GameView.swift(SpriteView)` 기본 골격 생성
- 미션 탭에서 게임 진입 라우팅
- 상태 저장(점수/진행도)용 Store 분리
- 1차 목표: **30초 플레이 가능한 미니게임 1개**

권장 1차 스코프:

- 탭/드래그 입력 1개
- 충돌 타입 3개(플레이어/목표/장애물)
- 성공/실패 루프
- 결과 HUD(점수, 재시작)

---

## 22) 참고 링크

- Apple SpriteKit 문서: https://developer.apple.com/documentation/spritekit
- SKScene: https://developer.apple.com/documentation/spritekit/skscene
- SKNode: https://developer.apple.com/documentation/spritekit/sknode
- SKView: https://developer.apple.com/documentation/spritekit/skview
- SpriteKit 네임스페이스(타입 인덱스 참고):
  https://learn.microsoft.com/en-us/dotnet/api/spritekit

---

## 23) 한 줄 결론

SpriteKit은 **iOS 네이티브 2D 게임 제작에 가장 빠르게 결과를 내는 선택지**다.
핵심은 "노드 트리 + 물리 + 액션"을 단순하게 시작하고, 규모가 커질수록 상태/아키텍처를 분리하는 것이다.
