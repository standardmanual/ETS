//
//  BPMDisplay.swift
//  ETS
//
//  Created by Claude on 2026-04-22.
//

import SwiftUI

// MARK: - BPMDisplay
// [C] BPM 숫자 표시 + −10 / − / + / +10 조절 버튼 행

struct BPMDisplay: View {
    @ObservedObject var state: MetronomeState

    private let min = 40
    private let max = 240

    var body: some View {
        HStack(spacing: 12) {
            bpmButton("-10") { nudge(-10) }
            bpmButton("-")   { nudge(-1) }

            Text("\(state.bpm)")
                .font(.system(size: 52, weight: .bold, design: .monospaced))
                .foregroundStyle(ETS.white)
                .frame(minWidth: 90)
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.12), value: state.bpm)

            bpmButton("+")   { nudge(+1) }
            bpmButton("+10") { nudge(+10) }
        }
        .frame(maxWidth: .infinity)
    }

    private func nudge(_ delta: Int) {
        state.bpm = Swift.min(max, Swift.max(min, state.bpm + delta))
    }

    @ViewBuilder
    private func bpmButton(_ label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(ETS.greenPale)
                .frame(width: 44, height: 44)
                .background(ETS.greenDeep.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: ETS.rPill))
        }
        .buttonRepeatBehavior(.enabled)
    }
}

#Preview {
    BPMDisplay(state: MetronomeState())
        .padding()
        .background(ETS.bgDeep)
}
