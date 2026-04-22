//
//  BeatDotRow.swift
//  ETS
//
//  Created by Claude on 2026-04-22.
//

import SwiftUI

// MARK: - BeatDotRow
// PRD §5.2 — 비트 도트 행 (−10/−/dots/+/+10 행 중 dots 파트)

struct BeatDotRow: View {
    let dotCount:      Int   // 박자 수 (2~9)
    let activeDotIndex: Int  // -1 = 없음

    var body: some View {
        HStack(spacing: 9) {
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

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        BeatDotRow(dotCount: 4, activeDotIndex: 0)
        BeatDotRow(dotCount: 3, activeDotIndex: 1)
        BeatDotRow(dotCount: 6, activeDotIndex: -1)
    }
    .padding()
    .background(ETS.bgDeep)
}
