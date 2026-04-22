//
//  MetronomeState.swift
//  ETS
//
//  Created by Claude on 2026-04-22.
//

import SwiftUI

// MARK: - Enums

enum SoundMode: String, CaseIterable {
    case click = "클릭"
    case drum  = "드럼"
    case loop  = "루프"
}

enum ClickType: String, CaseIterable {
    case default_ = "기본"
    case wood     = "우드"
}

enum RhythmKey: String, CaseIterable {
    case eighth_A  = "eighth_A"
    case eighth_B  = "eighth_B"
    case eighth_C  = "eighth_C"
    case eighth_D  = "eighth_D"
    case sixteenth_A = "sixteenth_A"
    case sixteenth_B = "sixteenth_B"
    case sixteenth_C = "sixteenth_C"
    case sixteenth_D = "sixteenth_D"

    var displayName: String {
        switch self {
        case .eighth_A:    return "8분 A"
        case .eighth_B:    return "8분 B"
        case .eighth_C:    return "8분 C"
        case .eighth_D:    return "8분 D"
        case .sixteenth_A: return "16분 A"
        case .sixteenth_B: return "16분 B"
        case .sixteenth_C: return "16분 C"
        case .sixteenth_D: return "16분 D"
        }
    }
}

// MARK: - MetronomeState

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
    @Published var currentBar: Int = 0     // 0~3, 리듬 패널 하이라이트용

    // ── 클릭 모드 ──
    @Published var timeSig: Int = 0        // 인덱스: TIME_SIGS 배열 참조
    @Published var clickType: ClickType = .default_

    // ── 드럼 모드 ──
    @Published var drumRhythm: RhythmKey = .eighth_A

    // ── 루프 모드 ──
    @Published var loopBars: Int = 4
    @Published var loopRhythm: RhythmKey = .eighth_A
    @Published var loopChords:  [Int: String] = [:]
    @Published var loopChordsB: [Int: String] = [:]
    @Published var loopMeasureIdx: Int = 0

    // ── 리듬 패널 ──
    @Published var isRhythmPanelOpen: Bool = false
    @Published var currentRhythmPicks: [Int] = []

    // ── 탭 템포 ──
    @Published var tapBPMDisplay: String = "—"

    // ── 뮤트 ──
    @Published var isMuted: Bool = false

    init() {
        currentRhythmPicks = rhythmPickFour()
    }

    func shuffleRhythm() {
        currentRhythmPicks = rhythmPickFour()
    }

    // 현재 박자 수 반환
    var dotCount: Int {
        TIME_SIGS[timeSig]
    }
}

// MARK: - Constants

let TIME_SIGS = [4, 3, 2, 6, 5, 7, 8, 9]
