//
//  RhythmPickerRow.swift
//  ETS
//
//  Created by Claude on 2026-04-22.
//

import SwiftUI

// MARK: - RhythmPickerRow
// [I] 리듬 선택 (드럼/루프 모드): 8분 A~D, 16분 A~D (가로 스크롤)

struct RhythmPickerRow: View {
    @ObservedObject var state: MetronomeState

    private var selectedKey: Binding<RhythmKey> {
        state.soundMode == .loop ? $state.loopRhythm : $state.drumRhythm
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(RhythmKey.allCases, id: \.self) { key in
                    Button(action: { selectedKey.wrappedValue = key }) {
                        Text(key.displayName)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(selectedKey.wrappedValue == key ? ETS.bgDeep : ETS.greenPale)
                            .padding(.horizontal, 14)
                            .frame(height: 36)
                            .background(
                                selectedKey.wrappedValue == key
                                    ? ETS.greenMid
                                    : ETS.greenDeep.opacity(0.4)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: ETS.rPill))
                    }
                }
            }
            .padding(.horizontal, 1)
        }
        .animation(.easeInOut(duration: 0.12), value: selectedKey.wrappedValue)
    }
}

#Preview {
    RhythmPickerRow(state: MetronomeState())
        .padding()
        .background(ETS.bgDeep)
}
