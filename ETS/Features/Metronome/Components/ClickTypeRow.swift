//
//  ClickTypeRow.swift
//  ETS
//
//  Created by Claude on 2026-04-22.
//

import SwiftUI

// MARK: - ClickTypeRow
// [H] 소리 선택 (클릭 모드만): 기본 / 우드

struct ClickTypeRow: View {
    @ObservedObject var state: MetronomeState

    var body: some View {
        HStack(spacing: 8) {
            ForEach(ClickType.allCases, id: \.self) { type in
                Button(action: { state.clickType = type }) {
                    Text(type.rawValue)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(state.clickType == type ? ETS.bgDeep : ETS.greenPale)
                        .frame(maxWidth: .infinity, minHeight: 36)
                        .background(
                            state.clickType == type
                                ? ETS.greenMid
                                : ETS.greenDeep.opacity(0.4)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: ETS.rPill))
                }
            }
        }
        .animation(.easeInOut(duration: 0.12), value: state.clickType)
    }
}

#Preview {
    ClickTypeRow(state: MetronomeState())
        .padding()
        .background(ETS.bgDeep)
}
