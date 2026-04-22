//
//  RhythmPanel.swift
//  ETS
//
//  Created by Claude on 2026-04-22.
//

import SwiftUI

// MARK: - RhythmPanel
// [R] 리듬 패널 accordion (비트 인디케이터 아래, 박자 선택 위).
// PRD §5.3 — 접힘/펼침, 4개 RhythmBarView, 셔플 버튼.

struct RhythmPanel: View {
    @ObservedObject var state: MetronomeState

    var body: some View {
        VStack(spacing: 0) {
            // ── 헤더 (항상 표시) ──
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    state.isRhythmPanelOpen.toggle()
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "music.note.list")
                        .font(.system(size: 14))
                    Text("리듬")
                        .font(.system(size: 14, weight: .semibold))
                    Spacer()
                    Image(systemName: state.isRhythmPanelOpen ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12))
                        .opacity(0.6)
                }
                .foregroundStyle(ETS.greenPale)
                .frame(maxWidth: .infinity, minHeight: ETS.tap)
                .padding(.horizontal, 14)
                .background(ETS.greenMid.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(ETS.greenMid, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            // ── 펼침 본문 ──
            if state.isRhythmPanelOpen {
                VStack(spacing: 0) {
                    // 패널 내부 헤더
                    HStack {
                        Text("리듬 악보")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(ETS.greenPale)
                        Spacer()
                        Button(action: { state.shuffleRhythm() }) {
                            Text("셔플")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(ETS.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(ETS.greenMid)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 12)
                    .padding(.bottom, 8)

                    Divider()
                        .overlay(Color.white.opacity(0.15))

                    // 4개 마디 악보
                    VStack(spacing: 4) {
                        ForEach(0..<4, id: \.self) { bar in
                            RhythmBarView(
                                patternIndex: state.currentRhythmPicks.indices.contains(bar)
                                    ? state.currentRhythmPicks[bar] : 1,
                                isActive: state.isPlaying && state.currentBar == bar
                            )
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)

                    Divider()
                        .overlay(Color.white.opacity(0.15))
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

#Preview {
    @Previewable @State var st = MetronomeState()
    RhythmPanel(state: st)
        .padding()
        .background(ETS.bgDeep)
}
