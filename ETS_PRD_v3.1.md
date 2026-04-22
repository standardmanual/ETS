# ETS — iOS App PRD v3.1
**Product Requirements Document — 검증 보완 버전**
분석 기준: 무제.html (메트로놈 원본) + guitar.html (기타 연습 원본)
대상: Claude Code (Swift / SwiftUI / iOS 26.4+)
작성: 2026-04-22

---

## 0. 변경 이력

| 버전 | 변경 내용 |
|---|---|
| v1.0 | 최초 작성 (추론 기반, 오류 다수) |
| v2.0 | 원본 JS 소스 분석 기반 전면 재작성 |
| v3.0 | guitar.html 우선순위·코드암기 탭 추가 / 리듬 탭 → 메트로놈 통합 |
| v3.1 | 검증 보고서 12개 항목 보완: 탭 재진입 힌트, 키보드 단축키, 셔플 스타일, Canvas 회전, 비트 인디케이터 애니메이션, hintOn 전역화, toSharp 마이너 플랫, 리듬 패널 설계 확정, shapeKey 로직, stopMetronome 처리, 탭 전환 정책 확정 |
| v3.2 | Xcode 프로젝트 실측값 반영: Bundle ID → com.ets.ETS / 최소 iOS → 26.4 / KeyboardShortcutHost UIKeyCommand 폴백 제거 (onKeyPress 직접 지원) |

---

## 1. 앱 개요

| 항목 | 값 |
|---|---|
| 앱 이름 | ETS |
| Bundle ID | com.ets.ETS |
| 최소 iOS | 26.4 |
| 언어 | Swift 5.9+ |
| UI 프레임워크 | SwiftUI |
| 오디오 | AVAudioEngine + AVAudioPCMBuffer (lookahead 스케줄러) |
| 언어(UI) | 한국어 고정 |
| 다크모드 | 다크 전용 (메트로놈 탭) / 라이트 (기타 연습 탭) — 각 탭 독립 |
| 서드파티 패키지 | 사용 금지 |

### 1.1 앱 구조 (TabView)

```
TabView
├── [0] 메트로놈   (SF Symbol: "metronome",   label: "메트로놈")
├── [1] 우선순위   (SF Symbol: "guitars",      label: "우선순위")
└── [2] 코드암기   (SF Symbol: "music.note",   label: "코드암기")
```

### 1.2 탭 전환 정책 ✅ 확정

**메트로놈 탭에서 다른 탭으로 이동해도 재생을 유지한다.**

이유: ETS 앱에서 메트로놈은 독립적인 오디오 도구 탭이므로, guitar.html의 "리듬 탭 이탈 시 정지" 동작을 따르지 않는다. 사용자는 메트로놈을 틀어 놓은 채 다른 탭에서 연습할 수 있다.

**예외:** 앱이 백그라운드로 전환될 때 자동 정지 (v1.0 사양).

---

## 2. 공유 상태 (AppState)

여러 탭에 걸쳐 공유되어야 하는 상태를 `AppState`에 정의한다.
`ETSApp.swift`에서 `@StateObject`로 생성하고 `.environmentObject`로 주입한다.

```swift
// App/AppState.swift
@MainActor
class AppState: ObservableObject {
  /// 기타 연습 탭 공통 힌트 토글 (우선순위 탭과 코드암기 탭이 공유)
  /// guitar.html 원본에서 hintOn은 전역 변수
  @Published var hintOn: Bool = false
}
```

```swift
// ETSApp.swift
@main
struct ETSApp: App {
  @StateObject private var appState = AppState()
  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(appState)
    }
  }
}
```

각 기타 연습 뷰에서:
```swift
@EnvironmentObject var appState: AppState
// appState.hintOn 사용
```

---

## 3. 디자인 시스템

### 3.1 메트로놈 탭 — ETS 다크 그린 테마

```swift
// Design/ETSTokens.swift
struct ETS {
  static let bgDeep    = Color(hex: "#1a2421")
  static let bgCard    = Color(hex: "#1e2e28")
  static let greenDeep  = Color(hex: "#2a6b4a")
  static let greenDark  = Color(hex: "#3a8a5c")
  static let greenMid   = Color(hex: "#52a872")
  static let greenLight = Color(hex: "#72c492")
  static let greenPale  = Color(hex: "#b5e6c8")
  static let white      = Color.white

  static let rPill: CGFloat = 24
  static let tap: CGFloat   = 44
}
```

### 3.2 기타 연습 탭 — Wise 라이트 테마

```swift
// Design/WiseTokens.swift
struct Wise {
  static let interactivePrimary = Color(hex: "#163300")
  static let interactiveAccent  = Color(hex: "#9FE870")
  static let contentPrimary     = Color(hex: "#0E0F0C")
  static let contentSecondary   = Color(hex: "#454745")
  static let contentTertiary    = Color(hex: "#6A6C6A")
  static let bgScreen           = Color.white
  static let bgNeutral          = Color(hex: "#163300").opacity(0.08)
  static let borderNeutral      = Color(hex: "#0E0F0C").opacity(0.12)
  static let sentimentPositive  = Color(hex: "#2F5711")
  static let sentimentNegative  = Color(hex: "#A8200D")

  static let rSM: CGFloat = 10;  static let rMD: CGFloat  = 16
  static let rLG: CGFloat = 24;  static let rPill: CGFloat = 999
  static let sp4: CGFloat  = 4;  static let sp8: CGFloat   = 8
  static let sp12: CGFloat = 12; static let sp16: CGFloat  = 16
  static let sp24: CGFloat = 24; static let sp32: CGFloat  = 32
  static let tap: CGFloat  = 44
}
```

---

## 4. 공통 유틸

### 4.1 prettyChordLabel

guitar.html 원본과 동일하게 `b` 전체를 `♭`로, `#` 전체를 `♯`로 교체한다.

```swift
func prettyChordLabel(_ s: String) -> String {
  // 원본: (s||'').replace(/b/g,'♭').replace(/#/g,'♯')
  // "Bb" → "B♭", "Bbm" → "B♭m", "F#m" → "F♯m"
  s.replacingOccurrences(of: "b", with: "♭")
   .replacingOccurrences(of: "#", with: "♯")
}
```

### 4.2 toSharp (마이너 플랫 포함 — v3.0 대비 수정)

```swift
// v3.0 오류: 마이너 플랫 코드(Bbm, Ebm 등) 변환 누락
// v3.1 수정: 마이너 플랫까지 포함한 전체 맵
func toSharp(_ n: String) -> String {
  let map: [String: String] = [
    "Bb": "A#", "Eb": "D#", "Ab": "G#", "Db": "C#", "Gb": "F#",
    "Bbm": "A#m", "Ebm": "D#m", "Abm": "G#m", "Dbm": "C#m", "Gbm": "F#m"
  ]
  return map[n] ?? n
}
```

### 4.3 enharmNormalize

```swift
func enharmNormalize(_ s: String) -> String {
  var t = s.trimmingCharacters(in: .whitespaces)
  t = t.replacingOccurrences(of: "♭", with: "b")
       .replacingOccurrences(of: "♯", with: "#")
  let isMinor = t.hasSuffix("m") && t.count > 1
  let base = isMinor ? String(t.dropLast()) : t
  let map = ["BB":"A#","EB":"D#","AB":"G#","DB":"C#","GB":"F#"]
  let up = base.uppercased()
  let norm = map[up] ?? up
  return norm + (isMinor ? "m" : "")
}
```

---

## 5. 탭 1 — 메트로놈 (MetronomeView)

### 5.1 전체 레이아웃

```
ZStack (bgDeep)
└── ScrollView
    ├── Header (앱 타이틀 + 마스터 볼륨)
    ├── [A] 모드 전환 (클릭 / 드럼 / 루프)
    ├── [B] 루프 섹션 (루프 모드만)
    ├── [C] BPM 표시 + 조절 버튼 행
    ├── [D] BPM 슬라이더
    ├── [E] 탭 템포 버튼
    ├── [F] 비트 인디케이터 행 (−10/−/dots/+/+10)
    ├── ─── [R] 리듬 패널 (접힘/펼침 accordion) ───
    ├── [G] 박자 선택 (클릭 모드만)
    ├── [H] 소리 선택 (클릭 모드만)
    ├── [I] 리듬 선택 (드럼/루프 모드만)
    └── [J] 시작/정지 버튼
```

### 5.2 [F] 비트 인디케이터 (3레이어 SVG + 애니메이션 — v3.0 대비 수정)

**원본 CSS (guitar.html 111~127행)를 SwiftUI로 정확히 재현한다.**

각 비트 도트는 단순한 원이 아니라 **3레이어 SVG 구조**다.

```swift
struct BeatDotView: View {
  let isAccent: Bool     // true: 강박 (index==0)
  let isActive: Bool     // true: 현재 박 하이라이트
  let isFade: Bool       // true: 방금 지나간 박

  // 애니메이션 트리거
  @State private var glowScale: CGFloat = 0.85
  @State private var glowOpacity: Double = 0.0
  @State private var rippleRadius: CGFloat = 16
  @State private var rippleOpacity: Double = 0.0
  @State private var rippleStroke: CGFloat = 3

  var activeColor: Color {
    isAccent ? ETS.greenMid : ETS.greenLight
  }

  var body: some View {
    ZStack {
      // Layer 1: beat-glow (fill, scale 애니메이션)
      Circle()
        .fill(activeColor)
        .frame(width: 36, height: 36)
        .scaleEffect(glowScale)
        .opacity(glowOpacity)

      // Layer 2: beat-ripple (stroke, 반지름 확장 애니메이션)
      Circle()
        .stroke(activeColor, lineWidth: rippleStroke)
        .frame(width: rippleRadius * 2, height: rippleRadius * 2)
        .opacity(rippleOpacity)

      // Layer 3: beat-core (메인 원, 상태에 따라 fill 변경)
      Circle()
        .fill(isActive ? activeColor : Color.white.opacity(0.15))
        .overlay(
          Circle().stroke(isActive ? activeColor : Color.white.opacity(0.15), lineWidth: 1.5)
        )
        .frame(width: 32, height: 32)
        .animation(.easeInOut(duration: isFade ? 0.25 : 0.06), value: isActive)
    }
    .frame(width: 48, height: 48)
    .onChange(of: isActive) { active in
      guard active else { return }
      // beatGlow 애니메이션: scale .85→1.05→1, opacity .9→.5→0, duration 0.55s
      glowScale = 0.85; glowOpacity = 0.9
      withAnimation(.easeOut(duration: 0.22)) { glowScale = 1.05; glowOpacity = 0.5 }
      withAnimation(.easeOut(duration: 0.33).delay(0.22)) { glowScale = 1.0; glowOpacity = 0 }
      // beatRipple 애니메이션: r 16→34, strokeWidth 3→0.5, opacity .8→0, duration 0.55s
      rippleRadius = 16; rippleStroke = 3; rippleOpacity = 0.8
      withAnimation(.easeOut(duration: 0.55)) {
        rippleRadius = 34; rippleStroke = 0.5; rippleOpacity = 0
      }
    }
  }
}
```

**Reduce Motion 대응:**
```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion
// reduceMotion이 true면 glowOpacity, rippleOpacity 애니메이션 생략
// beat-core 색상 전환만 유지
```

**BeatDotRow:**
```swift
struct BeatDotRow: View {
  let dotCount: Int
  let activeDotIndex: Int  // -1 = 없음
  
  var body: some View {
    HStack(spacing: 9) {  // gap 0.45rem ≈ 7~9pt
      ForEach(0..<dotCount, id: \.self) { i in
        BeatDotView(
          isAccent: i == 0,
          isActive: activeDotIndex == i,
          isFade:   activeDotIndex != i && activeDotIndex != -1
        )
      }
    }
    .frame(maxWidth: .infinity)
  }
}
```

### 5.3 [R] 리듬 패널 (accordion — v3.0 대비 보완)

**위치:** 비트 인디케이터 행([F]) 바로 아래, 박자 선택([G]) 바로 위.

**설계 확정 사항:**
- 리듬 패널 내부에는 **BPM 입력과 재생 버튼을 포함하지 않는다.** BPM 조절과 재생/정지는 각각 [C], [J] 섹션이 담당한다.
- 리듬 패널은 **악보 표시와 셔플 기능만** 담당한다.
- "리듬" 버튼이 메트로놈 UI에 항상 노출되며, 탭 시 accordion으로 펼쳐진다.

**접힘 상태 (기본):**
```
HStack (전폭, height 44pt, greenMid 8% 배경, greenMid border 1pt)
├── Image(systemName: "music.note.list") — greenPale
├── Text("리듬") — greenPale, 14px/600
├── Spacer
└── Image(systemName: isOpen ? "chevron.up" : "chevron.down") — greenPale 60%
```

**펼침 상태:**
```
VStack (스프링 애니메이션: .spring(response: 0.4, dampingFraction: 0.8))
│
├── 리듬 패널 헤더 HStack
│   ├── Text("리듬 악보") — greenPale, 13px/600
│   ├── Spacer
│   └── Button "셔플" → shuffleRhythm()
│       (greenMid 배경, white, 11px, pill, padding 4pt 12pt)
│
├── Divider (1pt, white 15%)
│
├── RhythmScoreArea: VStack(spacing: 4)
│   ├── RhythmBarView(patternIndex: picks[0], isActive: metro.bar == 0 && isPlaying)
│   ├── RhythmBarView(patternIndex: picks[1], isActive: metro.bar == 1 && isPlaying)
│   ├── RhythmBarView(patternIndex: picks[2], isActive: metro.bar == 2 && isPlaying)
│   └── RhythmBarView(patternIndex: picks[3], isActive: metro.bar == 3 && isPlaying)
│
└── Divider (1pt, white 15%)
```

**패널 열림 시 즉시 하이라이트:**
패널이 열릴 때 현재 `metro.bar`에 해당하는 마디가 즉시 하이라이트 상태로 렌더된다.
`isActive` 바인딩이 `metro.bar`에 연결되어 있으므로 별도 처리 없이 자동 반영된다.

**메트로놈-리듬 패널 연동:**
- 재생 중 4마디 완료 시 → `shuffleRhythm()` 자동 호출 → UI 즉시 갱신
- 셔플 버튼 수동 탭 → `shuffleRhythm()` → 메트로놈 정지 없음
- 패널 닫힘 중에도 `currentRhythmPicks` 상태 유지 (렌더링만 숨김)
- 패널 열릴 때 현재 패턴 그대로 표시, `metro.bar` 즉시 반영

### 5.4 리듬 악보 SVG 렌더러 (RhythmBarView — Canvas 회전 수정)

**PATTERNS 데이터 (guitar.html 원본):**
```swift
struct RhythmSVGPattern {
  let noteOffsets: [Int]    // 박 기준 상대 x 오프셋
  let beams: [[Int]]        // [[startOffset, endOffset, yLevel]]
  let dottedIndices: [Int]  // 점음표 적용할 음표 인덱스
}

let RHYTHM_PATTERNS: [Int: RhythmSVGPattern] = [
  1: .init(noteOffsets: [0],         beams: [],                           dottedIndices: []),
  2: .init(noteOffsets: [0,40],      beams: [[0,40,0]],                   dottedIndices: []),
  3: .init(noteOffsets: [0,20,40,60],beams: [[0,60,0],[0,60,1]],          dottedIndices: []),
  4: .init(noteOffsets: [0,40,60],   beams: [[0,60,0],[40,60,1]],         dottedIndices: []),
  5: .init(noteOffsets: [0,20,40],   beams: [[0,40,0],[0,20,1]],          dottedIndices: []),
  6: .init(noteOffsets: [0,20,60],   beams: [[0,60,0],[0,12,1],[48,60,1]],dottedIndices: []),
  7: .init(noteOffsets: [0,60],      beams: [[0,60,0],[48,60,1]],         dottedIndices: [0]),
  8: .init(noteOffsets: [0,20],      beams: [[0,20,0],[0,12,1]],          dottedIndices: [1]),
]
```

**SVG 파라미터:**
```
viewBox: 400 × 72
beatPositions (x): [40, 120, 200, 280]
noteY: 49.5
오선 5줄 y: 18, 27, 36, 45, 54 (stride 9) — x1=0 x2=400, stroke #111827 width 1.5
```

**RhythmBarView Canvas 구현 (음표 회전 수정 — v3.0 대비):**

```swift
// v3.0 오류: ctx.concatenate() 역방향 복구 방식 — SwiftUI Canvas에서 누적 오류 발생
// v3.1 수정: drawLayer 블록으로 각 음표마다 독립적인 transform 적용

struct RhythmBarView: View {
  let patternIndex: Int
  let isActive: Bool

  var body: some View {
    Canvas { ctx, size in
      let sx = size.width / 400.0
      let sy = size.height / 72.0
      let noteColor = GraphicsContext.Shading.color(Color(hex: "#111827"))

      // 1. 오선 5줄
      for i in 0..<5 {
        let y = (18.0 + Double(i) * 9.0) * sy
        var line = Path()
        line.move(to: .init(x: 0, y: y))
        line.addLine(to: .init(x: size.width, y: y))
        ctx.stroke(line, with: noteColor, lineWidth: 1.5 * sy)
      }

      guard let pat = RHYTHM_PATTERNS[patternIndex] else { return }
      let beatXs = [40.0, 120.0, 200.0, 280.0]

      for bx in beatXs {
        // 2. 음표
        for (idx, ox) in pat.noteOffsets.enumerated() {
          let nx = (bx + Double(ox)) * sx
          let ny = 49.5 * sy
          let stemX = nx + 6.0 * sx

          // 음표머리 회전: drawLayer로 독립 transform 적용
          ctx.drawLayer { layerCtx in
            layerCtx.transform = CGAffineTransform(translationX: nx, y: ny)
              .rotated(by: -15.0 * .pi / 180.0)
              .translatedBy(x: -nx, y: -ny)
            let head = Path(ellipseIn: CGRect(
              x: nx - 7.5 * sx, y: ny - 5.5 * sy,
              width: 15.0 * sx, height: 11.0 * sy
            ))
            layerCtx.fill(head, with: noteColor)
          }

          // 줄기
          var stem = Path()
          stem.move(to: .init(x: stemX, y: ny))
          stem.addLine(to: .init(x: stemX, y: 21.0 * sy))
          ctx.stroke(stem, with: noteColor, lineWidth: 2.0 * sx)

          // 점음표
          if pat.dottedIndices.contains(idx) {
            let dot = Path(ellipseIn: CGRect(
              x: (nx + 15.0 * sx) - 2.5 * sx,
              y: ny - 2.5 * sy,
              width: 5.0 * sx, height: 5.0 * sy
            ))
            ctx.fill(dot, with: noteColor)
          }
        }

        // 3. 빔
        for beam in pat.beams {
          let startX = (bx + Double(beam[0]) + 6.0) * sx
          let endX   = (bx + Double(beam[1]) + 6.0) * sx
          let y      = (21.0 + Double(beam[2]) * 5.4) * sy
          ctx.fill(Path(CGRect(x: startX, y: y,
                               width: endX - startX, height: 4.5 * sy)),
                   with: noteColor)
        }
      }
    }
    .aspectRatio(400.0 / 72.0, contentMode: .fit)
    .background(isActive ? ETS.greenMid.opacity(0.18) : Color.clear)
    .clipShape(RoundedRectangle(cornerRadius: 6))
    .overlay(
      RoundedRectangle(cornerRadius: 6)
        .stroke(isActive ? ETS.greenMid : Color.clear, lineWidth: 1.5)
    )
    .animation(.easeInOut(duration: 0.15), value: isActive)
  }
}
```

### 5.5 리듬 픽포 알고리즘

```swift
// RhythmPatternData.swift
func rhythmPickFour() -> [Int] {
  let allowPair = Double.random(in: 0..<1) < 0.4
  var set: [Int] = []
  func rnd() -> Int { Int.random(in: 1...8) }
  if allowPair {
    let pair = rnd()
    set = [pair, pair]
    while set.count < 4 {
      let n = rnd()
      if n != pair && !set.contains(n) { set.append(n) }
    }
  } else {
    while set.count < 4 {
      let n = rnd()
      if !set.contains(n) { set.append(n) }
    }
  }
  return set.shuffled()
}
```

### 5.6 MetronomeState

```swift
// MetronomeState.swift
@MainActor
class MetronomeState: ObservableObject {
  // ── 모드 ──
  @Published var soundMode: SoundMode = .click

  // ── BPM ──
  @Published var bpm: Int = 90
  @Published var masterVolume: Double = 1.0

  // ── 재생 ──
  @Published var isPlaying: Bool = false
  @Published var activeDotIndex: Int = -1
  @Published var currentBar: Int = 0        // 0~3, 리듬 패널 하이라이트용

  // ── 클릭 모드 ──
  @Published var timeSig: Int = 0
  @Published var clickType: ClickType = .default_

  // ── 드럼 모드 ──
  @Published var drumRhythm: RhythmKey = .eighth_A

  // ── 루프 모드 ──
  @Published var loopBars: Int = 4
  @Published var loopRhythm: RhythmKey = .eighth_A
  @Published var loopChords: [Int: String] = [:]
  @Published var loopChordsB: [Int: String] = [:]
  @Published var loopMeasureIdx: Int = 0

  // ── 리듬 패널 ──
  @Published var isRhythmPanelOpen: Bool = false
  @Published var currentRhythmPicks: [Int] = []

  // ── 탭 템포 ──
  @Published var tapBPMDisplay: String = "—"

  init() {
    currentRhythmPicks = rhythmPickFour()
  }

  func shuffleRhythm() {
    currentRhythmPicks = rhythmPickFour()
  }
}
```

### 5.7 stopMetronome 처리 (v3.0 대비 수정)

```swift
// MetronomeEngine.swift
func stopMetronome() {
  schedulerTimer?.invalidate()
  schedulerTimer = nil

  if let ctx = audioContext {
    let now = ctx.currentTime
    try? chokeOpenHihat(at: now)
    try? chokeBass(at: now)
  }

  // 중요: 다음 start 시 getMasterOut()에서 새로 생성되도록 nil 처리
  masterGainNode = nil
  bassBusNode = nil

  activeDotIndex = -1
  isPlaying = false
}
```

### 5.8 나머지 메트로놈 기능 (v2.0 명세 유지)

아래 항목은 v2.0 PRD 섹션 3~15를 그대로 따른다:
- 모드 전환 3-way + 조건부 UI 표시 규칙
- DRUM_PATTERNS 8개 + BASS_PATTERNS 8개 + BASS_FREQ 12음
- AVAudioEngine lookahead 스케줄러 (lookahead=25ms, scheduleAheadTime=0.1s)
- kick/snare/hihat/bass 신디사이저 (샘플 우선, fallback 신디사이저)
- BPM 범위 40~240, 슬라이더, 조절 버튼 (−10/−/+/+10)
- 탭 템포 (TAP_RESET_MS=2500, 범위 30~300)
- 박자 선택 5종, 소리 모드 2종 (클릭 모드)
- 루프 모드 코드 그리드 + 베이스 라인
- 마스터 볼륨 + 뮤트 (아이콘 3단계)
- MediaSession API (iOS에서는 Now Playing 정보)

---

## 6. 탭 2 — 우선순위 (PriorityView)

### 6.1 전체 레이아웃

```
ZStack (Wise.bgScreen)
└── VStack
    ├── PageHeader
    │   ├── Text("우선순위") 22px/700
    │   └── Text("핵심 코드 24개 · CAGED 폼 기반") 14px contentSecondary
    └── ScrollView
        └── WiseCard
            ├── SectionHeader "코드 플래시카드"
            └── CardBody (padding sp24)
                ├── QuestionDisplay (코드명, 40px/700, center)
                ├── HintText (13px contentSecondary, min-height 20pt)
                ├── FretboardDiagramView (힌트 on + 딜레이 후에만 표시)
                ├── Divider (1pt borderNeutral)
                └── ControlRow (controls)
                    ├── WiseSwitch(label:"힌트", isOn: $appState.hintOn)
                    ├── BtnPrimary("다음 코드") — onNextCardTapped()
                    └── ShuffleButton  ← isShuffling에 따라 스타일 전환
```

### 6.2 탭 진입 / 재진입 처리 (v3.0 대비 수정)

```swift
// PriorityView.onAppear
func onAppear() {
  if cursor == -1 {
    // 최초 진입: 무작위 순서, 첫 카드 출제 (2초 딜레이 적용)
    randomizeOrder()
    nextCard()
  } else {
    // 재진입: 현재 카드 유지, 힌트 즉시 표시
    renderHint(immediate: true)
  }
}
```

### 6.3 셔플 버튼 — 스타일 전환 (v3.0 대비 수정)

```swift
// guitar.html 원본: 셔플 활성 시 btn-filled 클래스 추가 (secondary → primary 스타일)

// ShuffleButton: isShuffling 상태에 따라 SwiftUI 컴포넌트 교체
@ViewBuilder
var shuffleButton: some View {
  if state.isShuffling {
    // 활성: BtnPrimary 스타일 (accent 배경)
    Button("셔플 종료 (\(state.shuffleCount))") {
      state.stopShuffle()
    }
    .buttonStyle(PrimaryButtonStyle())   // accent 배경, primary 텍스트
  } else {
    // 비활성: BtnSecondary 스타일 (아웃라인)
    Button("셔플 시작") {
      state.startShuffle()
    }
    .buttonStyle(SecondaryButtonStyle()) // transparent 배경, primary border
  }
}
```

### 6.4 키보드 단축키 (v3.0 대비 신규 추가)

우선순위 탭이 활성일 때 외장 키보드 단축키를 지원한다.

```swift
// iOS 17+ onKeyPress
// iOS 26.4 타겟: onKeyPress 직접 사용 (UIKeyCommand 폴백 불필요)

// PriorityView.body
.onKeyPress(keys: [.init("h"), .init("H")]) { _ in
  appState.hintOn.toggle()
  state.toggleHint()
  return .handled
}
.onKeyPress(keys: [.init("n"), .init("N"), .return]) { _ in
  // 입력 필드가 포커스되어 있지 않을 때만 동작
  state.onNextCardTapped()
  return .handled
}
```

**iOS 26.4 — onKeyPress 직접 지원 (UIKeyCommand 불필요):**
```swift
// KeyboardShortcutHost.swift (UIViewControllerRepresentable)
override var keyCommands: [UIKeyCommand]? {
  guard isPriorityTabActive else { return nil }
  return [
    UIKeyCommand(input: "h", modifierFlags: [], action: #selector(toggleHintKey)),
    UIKeyCommand(input: "n", modifierFlags: [], action: #selector(nextCardKey)),
    UIKeyCommand(input: "\r", modifierFlags: [], action: #selector(nextCardKey)),
  ]
}
```

### 6.5 PRIORITY_CARDS 데이터 (24개)

```swift
struct GuitarCard {
  let chord: String; let form: String; let string: String
  let fret: String;  let baseFretNum: Int; let type: String
}

let PRIORITY_CARDS: [GuitarCard] = [
  .init(chord:"A",   form:"A폼", string:"5번줄", fret:"오픈",   baseFretNum:0, type:"M"),
  .init(chord:"Bb",  form:"A폼", string:"5번줄", fret:"1프렛",  baseFretNum:1, type:"M"),
  .init(chord:"B",   form:"A폼", string:"5번줄", fret:"2프렛",  baseFretNum:2, type:"M"),
  .init(chord:"Db",  form:"A폼", string:"5번줄", fret:"4프렛",  baseFretNum:4, type:"M"),
  .init(chord:"Eb",  form:"A폼", string:"5번줄", fret:"6프렛",  baseFretNum:6, type:"M"),
  .init(chord:"C",   form:"C폼", string:"5번줄", fret:"오픈",   baseFretNum:0, type:"M"),
  .init(chord:"D",   form:"D폼", string:"4번줄", fret:"오픈",   baseFretNum:0, type:"M"),
  .init(chord:"E",   form:"E폼", string:"6번줄", fret:"오픈",   baseFretNum:0, type:"M"),
  .init(chord:"F",   form:"E폼", string:"6번줄", fret:"1프렛",  baseFretNum:1, type:"M"),
  .init(chord:"Gb",  form:"E폼", string:"6번줄", fret:"2프렛",  baseFretNum:2, type:"M"),
  .init(chord:"Ab",  form:"E폼", string:"6번줄", fret:"4프렛",  baseFretNum:4, type:"M"),
  .init(chord:"G",   form:"G폼", string:"6번줄", fret:"오픈",   baseFretNum:0, type:"M"),
  .init(chord:"Am",  form:"A폼", string:"5번줄", fret:"오픈",   baseFretNum:0, type:"m"),
  .init(chord:"Bbm", form:"A폼", string:"5번줄", fret:"1프렛",  baseFretNum:1, type:"m"),
  .init(chord:"Bm",  form:"A폼", string:"5번줄", fret:"2프렛",  baseFretNum:2, type:"m"),
  .init(chord:"Cm",  form:"A폼", string:"5번줄", fret:"3프렛",  baseFretNum:3, type:"m"),
  .init(chord:"C#m", form:"A폼", string:"5번줄", fret:"4프렛",  baseFretNum:4, type:"m"),
  .init(chord:"Ebm", form:"A폼", string:"5번줄", fret:"6프렛",  baseFretNum:6, type:"m"),
  .init(chord:"Dm",  form:"D폼", string:"4번줄", fret:"오픈",   baseFretNum:0, type:"m"),
  .init(chord:"Em",  form:"E폼", string:"6번줄", fret:"오픈",   baseFretNum:0, type:"m"),
  .init(chord:"Fm",  form:"E폼", string:"6번줄", fret:"1프렛",  baseFretNum:1, type:"m"),
  .init(chord:"F#m", form:"E폼", string:"6번줄", fret:"2프렛",  baseFretNum:2, type:"m"),
  .init(chord:"Gm",  form:"E폼", string:"6번줄", fret:"3프렛",  baseFretNum:3, type:"m"),
  .init(chord:"G#m", form:"E폼", string:"6번줄", fret:"4프렛",  baseFretNum:4, type:"m"),
]
```

### 6.6 PriorityState

```swift
class PriorityState: ObservableObject {
  @Published var currentChord: String = "—"
  @Published var hintText: String = ""
  @Published var showFretboard: Bool = false
  @Published var isShuffling: Bool = false
  @Published var shuffleCount: Int = 10
  @Published var currentCard: GuitarCard? = nil

  private var order: [Int] = []
  private var cursor: Int = -1
  private var lastIndex: Int = -1
  private var shuffleTimer: Timer? = nil
  private var hintDelayTask: Task<Void, Never>? = nil

  // hintOn은 AppState에서 @EnvironmentObject로 주입 (전역 공유)
  // PriorityState는 hintOn을 읽어 renderHint 동작 결정

  func initOrder() { order = Array(0..<PRIORITY_CARDS.count) }

  func randomizeOrder() {
    if order.isEmpty { initOrder() }
    order.shuffle()
    cursor = -1
  }

  func nextCard() {
    if order.isEmpty { initOrder() }
    cursor = (cursor + 1) % order.count
    if order[cursor] == lastIndex { cursor = (cursor + 1) % order.count }
    showCard(index: order[cursor])
  }

  func showCard(index: Int) {
    let card = PRIORITY_CARDS[index]
    currentCard = card
    currentChord = prettyChordLabel(card.chord)
    lastIndex = index
    renderHint(immediate: false)
  }

  func renderHint(immediate: Bool, hintOn: Bool) {
    hintDelayTask?.cancel()
    hintDelayTask = nil
    hintText = ""
    showFretboard = false
    guard hintOn, let card = currentCard else { return }
    let delay: UInt64 = immediate ? 0 : 2_000_000_000
    hintDelayTask = Task {
      if delay > 0 { try? await Task.sleep(nanoseconds: delay) }
      guard !Task.isCancelled, hintOn else { return }
      await MainActor.run {
        hintText = "힌트 : \(card.form) \(card.string) \(card.fret)"
        showFretboard = true
      }
    }
  }

  func toggleHint(hintOn: Bool) {
    // 수동 토글: immediate=true
    if hintOn { renderHint(immediate: true, hintOn: true) }
    else { hintDelayTask?.cancel(); hintText = ""; showFretboard = false }
  }

  func onNextCardTapped() {
    nextCard()
    if isShuffling { shuffleCount = 10 }
  }

  func startShuffle() {
    randomizeOrder(); nextCard()
    isShuffling = true; shuffleCount = 10
    shuffleTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
      guard let self else { return }
      self.shuffleCount -= 1
      if self.shuffleCount <= 0 { self.nextCard(); self.shuffleCount = 10 }
    }
  }

  func stopShuffle() {
    shuffleTimer?.invalidate(); shuffleTimer = nil; isShuffling = false
  }

  func onDisappear() {
    stopShuffle()
  }
}
```

### 6.7 지판 다이어그램 (FretboardDiagramView)

**shapeKey 생성 로직 (v3.0 대비 명시 추가):**
```swift
// guitar.html 원본: card.form.substring(0,1) + "폼_" + card.type
// "A폼" → "A폼_M", "E폼" → "E폼_m" 등

func makeShapeKey(for card: GuitarCard) -> String {
  let prefix = String(card.form.prefix(1))  // "A폼" → "A"
  return "\(prefix)폼_\(card.type)"          // "A폼_M"
}
```

**SHAPE_DOTS 데이터:**
```swift
struct FretDot { let s: Int; let f: Int; let r: Bool }

let SHAPE_DOTS: [String: [FretDot]] = [
  "A폼_M": [.init(s:5,f:0,r:true),.init(s:4,f:2,r:false),.init(s:3,f:2,r:false),.init(s:2,f:2,r:false),.init(s:1,f:0,r:false)],
  "A폼_m": [.init(s:5,f:0,r:true),.init(s:4,f:2,r:false),.init(s:3,f:2,r:false),.init(s:2,f:1,r:false),.init(s:1,f:0,r:false)],
  "E폼_M": [.init(s:6,f:0,r:true),.init(s:5,f:2,r:false),.init(s:4,f:2,r:false),.init(s:3,f:1,r:false),.init(s:2,f:0,r:false),.init(s:1,f:0,r:false)],
  "E폼_m": [.init(s:6,f:0,r:true),.init(s:5,f:2,r:false),.init(s:4,f:2,r:false),.init(s:3,f:0,r:false),.init(s:2,f:0,r:false),.init(s:1,f:0,r:false)],
  "C폼_M": [.init(s:5,f:3,r:true),.init(s:4,f:2,r:false),.init(s:3,f:0,r:false),.init(s:2,f:1,r:false),.init(s:1,f:0,r:false)],
  "D폼_M": [.init(s:4,f:0,r:true),.init(s:3,f:2,r:false),.init(s:2,f:3,r:false),.init(s:1,f:2,r:false)],
  "D폼_m": [.init(s:4,f:0,r:true),.init(s:3,f:2,r:false),.init(s:2,f:3,r:false),.init(s:1,f:1,r:false)],
  "G폼_M": [.init(s:6,f:3,r:true),.init(s:5,f:2,r:false),.init(s:4,f:0,r:false),.init(s:3,f:0,r:false),.init(s:2,f:0,r:false),.init(s:1,f:3,r:false)],
]
// 우선순위 탭은 M/m 타입만 사용 (M7, m7, 7 키 불필요)
```

**렌더링 파라미터:**
```
Canvas viewBox: 440 × 190
padX:40, padY:20, strSpacing:22, fretWidth:84
startWire: card.baseFretNum <= 1 ? 0 : card.baseFretNum - 1

줄 (6개): y = padY+(s-1)×strSpacing, thickness = 1+(s-1)×0.2, color #4b5563
프렛 (5개): x = padX+i×fretWidth
  nut (currentWire==0): width 6, color #111827
  일반: width 2, color #9ca3af
포지션 마커: [3,5,7,9,15,17,19] → r=5 fill #e5e7eb at string 2.5
  12프렛: 두 원 at string 1.5, 3.5
  i==1 & wire>0: 프렛 번호 텍스트 (y = padY+5.5×strSpacing+30)
바레 (baseFret>0): 반투명 파란 막대 fill #1e88e5 opacity 0.4
  E폼→s 1~6, A폼/C폼→s 1~5, D폼→s 1~4
운지 점: root → fill #ef4444 + outer ring r=10 stroke #ef4444 w2
         non-root → fill #1e88e5
오픈 (absFret==0): hollow r=4.5 at padX-16
뮤트 (×): A폼/C폼 → s=6, D폼 → s≥5
  path: (padX-20,y-4)→(padX-12,y+4), (padX-12,y-4)→(padX-20,y+4)
  stroke #ef4444 width 1.5
```

---

## 7. 탭 3 — 코드암기 (TonesView)

### 7.1 전체 레이아웃

```
ZStack (Wise.bgScreen)
└── VStack
    ├── PageHeader
    │   ├── Text("코드암기") 22px/700
    │   └── Text("코드를 보고 구성음 3개를 선택하세요") 14px contentSecondary
    └── ScrollView
        └── WiseCard
            ├── SectionHeader "코드 구성음 퀴즈"
            └── CardBody
                ├── QuestionDisplay (40px/700, center)
                ├── ResultText (14px/600, 정답/오답 색상)
                ├── NoteChipGrid (ALL_NOTES 17개, 다중 선택 토글)
                └── ControlRow
                    ├── BtnPrimary("정답확인")
                    └── BtnSecondary("다음 문제")
```

### 7.2 CHORDS 데이터

```swift
let CHORDS: [String: [String]] = [
  "C":["C","E","G"],   "D":["D","F#","A"],  "E":["E","G#","B"],
  "F":["F","A","C"],   "G":["G","B","D"],   "A":["A","C#","E"],
  "B":["B","D#","F#"],
  "Cm":["C","Eb","G"], "Dm":["D","F","A"],  "Em":["E","G","B"],
  "Fm":["F","Ab","C"], "Gm":["G","Bb","D"], "Am":["A","C","E"],
  "Bm":["B","D","F#"],
  "Db":["Db","F","Ab"],"Eb":["Eb","G","Bb"],"Gb":["Gb","Bb","Db"],
  "Ab":["Ab","C","Eb"],"Bb":["Bb","D","F"],
  "Dbm":["Db","E","Ab"],"Ebm":["Eb","Gb","Bb"],"Gbm":["Gb","A","Db"],
  "Abm":["Ab","B","Eb"],"Bbm":["Bb","Db","F"],
  "C#":["C#","F","G#"],"D#":["D#","G","A#"],"F#":["F#","A#","C#"],
  "G#":["G#","C","D#"],"A#":["A#","D","F"],
  "C#m":["C#","E","G#"],"D#m":["D#","Gb","A#"],"F#m":["F#","A","C#"],
  "G#m":["G#","B","D#"],"A#m":["A#","C#","F"]
]
let ALL_NOTES = ["A","Ab","A#","B","Bb","C","C#","D","Db","D#","E","Eb","F","F#","G","Gb","G#"]
```

### 7.3 TonesState

```swift
class TonesState: ObservableObject {
  @Published var currentChord: String = ""
  @Published var selectedNotes: Set<String> = []
  @Published var resultText: String = ""
  @Published var resultColor: Color = .clear
  private var answerSet: [String] = []

  func nextQuestion() {
    selectedNotes.removeAll(); resultText = ""
    let name = CHORDS.keys.randomElement()!
    currentChord = name
    answerSet = CHORDS[name]!.map { toSharp($0) }.sorted()
  }

  func checkAnswer() {
    let sel = selectedNotes.map { toSharp($0) }.sorted()
    let pretty = CHORDS[currentChord]!.map { prettyChordLabel($0) }.joined(separator: ", ")
    let ok = sel == answerSet
    resultText = "정답! \(pretty)"
    resultColor = ok ? Color(hex: "#2b8a3e") : Color(hex: "#c92a2a")
    if ok {
      Task {
        try? await Task.sleep(nanoseconds: 1_600_000_000)
        await MainActor.run { nextQuestion() }
      }
    }
  }

  func toggleNote(_ note: String) {
    if selectedNotes.contains(note) { selectedNotes.remove(note) }
    else { selectedNotes.insert(note) }
  }
}
```

**탭 진입 시:** 매번 `nextQuestion()` 호출.

### 7.4 NoteChip 스타일

```
기본: border 1pt borderNeutral, bgScreen bg, contentPrimary text
선택: interactivePrimary bg + border, white text
높이: 36pt, rPill, font 14px/500
flex-wrap: 자동 줄바꿈
```

---

## 8. 파일/폴더 구조

```
ETS/
├── ETSApp.swift
├── App/
│   └── AppState.swift               ← hintOn 전역 공유 상태 (신규)
├── Design/
│   ├── ETSTokens.swift
│   └── WiseTokens.swift
├── Features/
│   ├── Metronome/
│   │   ├── MetronomeView.swift
│   │   ├── MetronomeState.swift
│   │   ├── MetronomeEngine.swift
│   │   ├── DrumPatternData.swift
│   │   ├── ClickSoundGenerator.swift
│   │   ├── DrumSynthesizer.swift
│   │   ├── SamplePlayer.swift
│   │   ├── TapTempoDetector.swift
│   │   ├── RhythmPatternData.swift
│   │   └── Components/
│   │       ├── SoundToggle.swift
│   │       ├── BPMDisplay.swift
│   │       ├── BPMSlider.swift
│   │       ├── TapTempoButton.swift
│   │       ├── BeatDotView.swift       ← 3레이어 SVG + 애니메이션 (신규)
│   │       ├── BeatDotRow.swift
│   │       ├── RhythmPanel.swift
│   │       ├── RhythmBarView.swift     ← drawLayer 기반 Canvas (수정)
│   │       ├── TimeSigRow.swift
│   │       ├── ClickTypeRow.swift
│   │       ├── RhythmPickerRow.swift
│   │       ├── PlayStopButton.swift
│   │       ├── MasterVolumeBar.swift
│   │       └── Loop/
│   │           ├── LoopSection.swift
│   │           ├── LoopGrid.swift
│   │           ├── LoopCell.swift
│   │           └── LoopChordPicker.swift
│   ├── Priority/
│   │   ├── PriorityView.swift
│   │   ├── PriorityState.swift
│   │   ├── GuitarData.swift
│   │   └── FretboardDiagramView.swift
│   └── Tones/
│       ├── TonesView.swift
│       ├── TonesState.swift
│       └── NoteChipGrid.swift
└── Shared/
    ├── Components/
    │   ├── WiseCard.swift
    │   ├── WiseSwitch.swift
    │   ├── WiseChip.swift
    │   ├── BtnPrimary.swift  (PrimaryButtonStyle)
    │   ├── BtnSecondary.swift (SecondaryButtonStyle)
    │   └── KbdHint.swift
    └── Keyboard/
        └── KeyboardShortcutHost.swift  ← onKeyPress iOS 26.4 (UIKeyCommand 불필요)
```

---

## 9. 구현 순서

1. **AppState + ETSTokens + WiseTokens + 공통 컴포넌트**
2. **RhythmPatternData** — RHYTHM_PATTERNS 8개 + rhythmPickFour() 단위 테스트
3. **RhythmBarView** — `drawLayer` 기반 Canvas, 8패턴 Preview 전부 확인
4. **BeatDotView** — 3레이어 SVG + beatGlow/beatRipple 애니메이션 확인
5. **BeatDotRow + RhythmPanel** — 접힘/펼침 + 메트로놈 bar 연동
6. **MetronomeEngine** — Lookahead 스케줄러 + stopMetronome nil 처리 포함
7. **MetronomeView 조립** — 전체 레이아웃 + [R] 리듬 패널 삽입
8. **GuitarData** — PRIORITY_CARDS + SHAPE_DOTS + makeShapeKey
9. **FretboardDiagramView** — Canvas 지판 렌더러
10. **PriorityState** — onAppear 재진입 분기 + 힌트 Task + 셔플 Timer
11. **PriorityView** — 셔플 버튼 스타일 전환 + 키보드 단축키
12. **TonesState + TonesView** — nextQuestion / checkAnswer
13. **ETSApp TabView** — AppState environmentObject 주입
14. **KeyboardShortcutHost** — iOS 26.4 onKeyPress (UIKeyCommand 제거)
15. **오디오 세션 인터럽션 + 백그라운드 정지**

---

## 10. 검증 체크리스트

### 10.1 리듬 패널

- [ ] "리듬" 버튼: 비트 인디케이터 아래, 박자 선택 위에 항상 표시
- [ ] 탭 시 .spring 애니메이션으로 accordion 펼침
- [ ] 4개 RhythmBarView 세로 나열, aspectRatio 400:72 유지
- [ ] 각 음표머리가 -15도 기울어져 렌더됨 (drawLayer 회전)
- [ ] 재생 중 현재 bar(0~3)에 해당하는 마디 greenMid 하이라이트
- [ ] 패널이 열릴 때 현재 bar 즉시 하이라이트 표시
- [ ] 4마디 완료 시 자동 셔플 + bar=0 리셋
- [ ] 셔플 버튼: 메트로놈 정지 없이 패턴만 교체
- [ ] 패널 닫혀 있어도 내부 패턴 상태 유지

### 10.2 비트 인디케이터

- [ ] beat-core / beat-glow / beat-ripple 3레이어 구조
- [ ] beatGlow: scale .85→1.05→1, opacity .9→.5→0, duration 0.55s
- [ ] beatRipple: r 16→34, strokeWidth 3→0.5, opacity .8→0, duration 0.55s
- [ ] 강박(index==0): ETS.greenMid 색상
- [ ] 일반 박: ETS.greenLight 색상
- [ ] fade(지나간 박): beat-core fill/stroke 0.25s 전환
- [ ] Reduce Motion: 색상 전환만, scale/opacity 애니메이션 생략

### 10.3 우선순위 탭

- [ ] 최초 진입: 무작위 순서로 첫 카드 출제 (2초 딜레이 적용)
- [ ] 재진입(cursor != -1): 현재 카드 유지 + 힌트 즉시 표시
- [ ] hintOn 스위치 ON: 힌트 즉시 표시 (2초 딜레이 없음)
- [ ] 새 카드 출제 시: hintOn=true면 2초 후 힌트 자동 표시
- [ ] hintOn 스위치 OFF: 힌트 즉시 숨김 + Task 취소
- [ ] 셔플 비활성: BtnSecondary 스타일 "셔플 시작"
- [ ] 셔플 활성: BtnPrimary 스타일 "셔플 종료 (N)" (accent 배경)
- [ ] 셔플 중 "다음 코드": shuffleCount = 10 리셋
- [ ] 탭 이탈(.onDisappear): 셔플 타이머 자동 중지
- [ ] H키: 힌트 토글 (iPad 외장 키보드)
- [ ] N키 / Enter키: 다음 코드 (iPad 외장 키보드)

### 10.4 코드암기 탭

- [ ] 탭 진입 시 매번 새 문제
- [ ] 노트 칩 다중 선택 토글
- [ ] 맞으면 #2b8a3e + 1.6초 자동 진행
- [ ] 틀리면 #c92a2a + 정답 표시 (자동 진행 없음)
- [ ] toSharp: "Bbm" → "A#m" 변환 확인

### 10.5 지판 다이어그램

- [ ] makeShapeKey: "A폼" + "m" → "A폼_m" 정확히 생성
- [ ] nut(baseFret=0): 굵은 선 표시
- [ ] 바레(baseFret>0): 반투명 파란 막대
- [ ] 루트 점: 빨간 + 외부 링
- [ ] 비루트 점: 파란
- [ ] 뮤트: A폼/C폼 6번줄, D폼 5·6번줄 × 표시

### 10.6 메트로놈 엔진

- [ ] stopMetronome: masterGainNode = nil, bassBusNode = nil
- [ ] 재시작 시 masterGainNode 새로 생성 (getMasterOut() 통해)
- [ ] 탭 전환 시 재생 유지 (다른 탭으로 이동해도 소리 지속)
- [ ] 앱 백그라운드 전환 시 자동 정지

### 10.7 hintOn 전역 상태

- [ ] AppState.hintOn이 우선순위/코드암기 탭 모두에 반영
- [ ] 한 탭에서 토글 시 다른 탭에서도 동일한 상태 적용
- [ ] 메트로놈 탭 전환 시 hintOn 상태 보존

---

*ETS PRD v3.1 — 2026년 4월 22일 (검증 보고서 12개 항목 전체 반영)*
