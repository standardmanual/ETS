//
//  LoopSection.swift
//  ETS
//
//  Created by Claude on 2026-04-22.
//

import SwiftUI

// MARK: - LoopSection
// [B] 루프 모드 섹션: 마디 수 선택 + 코드 그리드

struct LoopSection: View {
    @ObservedObject var state: MetronomeState

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 마디 수 선택
            HStack(spacing: 8) {
                Text("마디")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(ETS.greenPale.opacity(0.7))
                Spacer()
                ForEach([2, 4], id: \.self) { bars in
                    Button(action: { state.loopBars = bars }) {
                        Text("\(bars)마디")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(state.loopBars == bars ? ETS.bgDeep : ETS.greenPale)
                            .padding(.horizontal, 16)
                            .frame(height: 32)
                            .background(
                                state.loopBars == bars ? ETS.greenMid : ETS.greenDeep.opacity(0.4)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: ETS.rPill))
                    }
                }
            }

            LoopGrid(state: state)
        }
        .padding(14)
        .background(ETS.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    LoopSection(state: MetronomeState())
        .padding()
        .background(ETS.bgDeep)
}
