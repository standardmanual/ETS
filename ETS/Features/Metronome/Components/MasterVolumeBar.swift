//
//  MasterVolumeBar.swift
//  ETS
//
//  Created by Claude on 2026-04-22.
//

import SwiftUI

// MARK: - MasterVolumeBar
// 마스터 볼륨 슬라이더 + 뮤트 아이콘 (3단계: 뮤트/낮음/높음)

struct MasterVolumeBar: View {
    @ObservedObject var state: MetronomeState

    private var muteIcon: String {
        if state.isMuted { return "speaker.slash.fill" }
        if state.masterVolume < 0.4 { return "speaker.fill" }
        return "speaker.wave.2.fill"
    }

    var body: some View {
        HStack(spacing: 10) {
            Button(action: { state.isMuted.toggle() }) {
                Image(systemName: muteIcon)
                    .font(.system(size: 18))
                    .foregroundStyle(state.isMuted ? ETS.greenDark : ETS.greenPale)
                    .frame(width: ETS.tap, height: ETS.tap)
            }

            Slider(value: $state.masterVolume, in: 0...1)
                .tint(ETS.greenMid)
                .opacity(state.isMuted ? 0.35 : 1.0)
                .disabled(state.isMuted)
        }
    }
}

#Preview {
    MasterVolumeBar(state: MetronomeState())
        .padding()
        .background(ETS.bgDeep)
}
