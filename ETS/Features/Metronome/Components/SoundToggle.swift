//
//  SoundToggle.swift
//  ETS
//
//  Created by Claude on 2026-04-22.
//

import SwiftUI

// MARK: - SoundToggle
// [A] 모드 전환 3-way: 클릭 / 드럼 / 루프

struct SoundToggle: View {
    @ObservedObject var state: MetronomeState

    var body: some View {
        HStack(spacing: 0) {
            ForEach(SoundMode.allCases, id: \.self) { mode in
                Button(action: { state.soundMode = mode }) {
                    Text(mode.rawValue)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(state.soundMode == mode ? ETS.bgDeep : ETS.greenPale)
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .background(
                            state.soundMode == mode
                                ? ETS.greenMid
                                : Color.clear
                        )
                }
            }
        }
        .background(ETS.greenDeep.opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: ETS.rPill))
        .overlay(
            RoundedRectangle(cornerRadius: ETS.rPill)
                .stroke(ETS.greenDark, lineWidth: 1)
        )
        .animation(.easeInOut(duration: 0.15), value: state.soundMode)
    }
}

#Preview {
    SoundToggle(state: MetronomeState())
        .padding()
        .background(ETS.bgDeep)
}
