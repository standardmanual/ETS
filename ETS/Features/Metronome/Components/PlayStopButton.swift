//
//  PlayStopButton.swift
//  ETS
//
//  Created by Claude on 2026-04-22.
//

import SwiftUI

// MARK: - PlayStopButton
// [J] 시작/정지 버튼. 재생 중: 빨간 정지 / 정지 중: 초록 재생.

struct PlayStopButton: View {
    let isPlaying: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                    .font(.system(size: 18))
                Text(isPlaying ? "정지" : "재생")
                    .font(.system(size: 18, weight: .bold))
            }
            .foregroundStyle(isPlaying ? ETS.bgDeep : ETS.bgDeep)
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(isPlaying ? Color(hex: "#e05555") : ETS.greenMid)
            .clipShape(RoundedRectangle(cornerRadius: ETS.rPill))
            .animation(.easeInOut(duration: 0.15), value: isPlaying)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        PlayStopButton(isPlaying: false) {}
        PlayStopButton(isPlaying: true)  {}
    }
    .padding()
    .background(ETS.bgDeep)
}
