//
//  TimeSigRow.swift
//  ETS
//
//  Created by Claude on 2026-04-22.
//

import SwiftUI

// MARK: - TimeSigRow
// [G] 박자 선택 (클릭 모드만): 4/4, 3/4, 2/4, 6/8, 5/4, 7/8, 8/8, 9/8

struct TimeSigRow: View {
    @ObservedObject var state: MetronomeState

    private let labels = ["4/4", "3/4", "2/4", "6/8", "5/4", "7/8", "8/8", "9/8"]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(labels.indices, id: \.self) { i in
                    Button(action: { state.timeSig = i }) {
                        Text(labels[i])
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(state.timeSig == i ? ETS.bgDeep : ETS.greenPale)
                            .padding(.horizontal, 14)
                            .frame(height: 36)
                            .background(
                                state.timeSig == i
                                    ? ETS.greenMid
                                    : ETS.greenDeep.opacity(0.4)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: ETS.rPill))
                    }
                }
            }
            .padding(.horizontal, 1)
        }
        .animation(.easeInOut(duration: 0.12), value: state.timeSig)
    }
}

#Preview {
    TimeSigRow(state: MetronomeState())
        .padding()
        .background(ETS.bgDeep)
}
