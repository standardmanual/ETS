//
//  BPMSlider.swift
//  ETS
//
//  Created by Claude on 2026-04-22.
//

import SwiftUI

// MARK: - BPMSlider
// [D] BPM 슬라이더 40~240, ETS 그린 tint

struct BPMSlider: View {
    @ObservedObject var state: MetronomeState

    var body: some View {
        Slider(value: bpmBinding, in: 40...240, step: 1)
            .tint(ETS.greenMid)
            .padding(.horizontal, 8)
    }

    private var bpmBinding: Binding<Double> {
        Binding(
            get: { Double(state.bpm) },
            set: { state.bpm = Int($0.rounded()) }
        )
    }
}

#Preview {
    BPMSlider(state: MetronomeState())
        .padding()
        .background(ETS.bgDeep)
}
