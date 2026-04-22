//
//  TapTempoButton.swift
//  ETS
//
//  Created by Claude on 2026-04-22.
//

import SwiftUI

// MARK: - TapTempoButton
// [E] 탭 템포 버튼. TAP_RESET_MS=2500, 범위 30~300.

struct TapTempoButton: View {
    @ObservedObject var state: MetronomeState
    private let detector = TapTempoDetector()

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Image(systemName: "hand.tap")
                    .font(.system(size: 16))
                Text(state.tapBPMDisplay == "—" ? "탭 템포" : "탭 \(state.tapBPMDisplay) BPM")
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundStyle(ETS.greenPale)
            .frame(maxWidth: .infinity, minHeight: ETS.tap)
            .background(ETS.greenDeep.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: ETS.rPill))
        }
    }

    private func onTap() {
        if let bpm = detector.tap() {
            state.tapBPMDisplay = "\(bpm)"
            state.bpm = bpm
        }
    }
}

#Preview {
    TapTempoButton(state: MetronomeState())
        .padding()
        .background(ETS.bgDeep)
}
