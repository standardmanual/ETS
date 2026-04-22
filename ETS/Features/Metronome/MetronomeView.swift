//
//  MetronomeView.swift
//  ETS
//
//  Created by Claude on 2026-04-22.
//

import SwiftUI

// MARK: - MetronomeView
// PRD §5.1 전체 레이아웃: ZStack(bgDeep) → ScrollView

struct MetronomeView: View {
    @StateObject private var state  = MetronomeState()
    @StateObject private var engine = MetronomeEngine()

    var body: some View {
        ZStack {
            ETS.bgDeep.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // ── Header: 앱 타이틀 + 마스터 볼륨 ──
                    VStack(spacing: 8) {
                        Text("ETS")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(ETS.greenLight)
                        MasterVolumeBar(state: state)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                    // ── [A] 모드 전환 ──
                    SoundToggle(state: state)
                        .padding(.horizontal, 20)

                    // ── [B] 루프 섹션 (루프 모드만) ──
                    if state.soundMode == .loop {
                        LoopSection(state: state)
                            .padding(.horizontal, 20)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    // ── [C] BPM 표시 + 조절 버튼 ──
                    BPMDisplay(state: state)
                        .padding(.horizontal, 20)

                    // ── [D] BPM 슬라이더 ──
                    BPMSlider(state: state)
                        .padding(.horizontal, 20)

                    // ── [E] 탭 템포 버튼 ──
                    TapTempoButton(state: state)
                        .padding(.horizontal, 20)

                    // ── [F] 비트 인디케이터 행 ──
                    beatIndicatorRow
                        .padding(.horizontal, 20)

                    // ── [R] 리듬 패널 accordion ──
                    RhythmPanel(state: state)
                        .padding(.horizontal, 20)

                    // ── [G] 박자 선택 (클릭 모드만) ──
                    if state.soundMode == .click {
                        TimeSigRow(state: state)
                            .padding(.horizontal, 20)
                            .transition(.opacity)
                    }

                    // ── [H] 소리 선택 (클릭 모드만) ──
                    if state.soundMode == .click {
                        ClickTypeRow(state: state)
                            .padding(.horizontal, 20)
                            .transition(.opacity)
                    }

                    // ── [I] 리듬 선택 (드럼/루프 모드만) ──
                    if state.soundMode != .click {
                        RhythmPickerRow(state: state)
                            .padding(.horizontal, 20)
                            .transition(.opacity)
                    }

                    // ── [J] 시작/정지 버튼 ──
                    PlayStopButton(isPlaying: state.isPlaying) {
                        togglePlayback()
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear { engine.state = state }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            if state.isPlaying { engine.stopMetronome() }
        }
        .animation(.easeInOut(duration: 0.2), value: state.soundMode)
    }

    // MARK: - Beat indicator row

    private var beatIndicatorRow: some View {
        HStack(spacing: 12) {
            nudgeButton("-10") { nudgeBeat(-10) }
            nudgeButton("-")   { nudgeBeat(-1) }

            BeatDotRow(
                dotCount:      state.dotCount,
                activeDotIndex: state.activeDotIndex
            )

            nudgeButton("+")   { nudgeBeat(+1) }
            nudgeButton("+10") { nudgeBeat(+10) }
        }
    }

    @ViewBuilder
    private func nudgeButton(_ label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(ETS.greenPale)
                .frame(width: 40, height: 40)
                .background(ETS.greenDeep.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: ETS.rPill))
        }
    }

    private func nudgeBeat(_ delta: Int) {
        let idx = (state.timeSig + delta + TIME_SIGS.count) % TIME_SIGS.count
        state.timeSig = max(0, min(TIME_SIGS.count - 1, idx))
    }

    // MARK: - Playback toggle

    private func togglePlayback() {
        if state.isPlaying {
            engine.stopMetronome()
        } else {
            state.isPlaying = true
            engine.startMetronome()
        }
    }
}

// MARK: - Preview

#Preview {
    MetronomeView()
}
