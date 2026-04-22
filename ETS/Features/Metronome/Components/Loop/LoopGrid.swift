//
//  LoopGrid.swift
//  ETS
//
//  Created by Claude on 2026-04-22.
//

import SwiftUI

// MARK: - LoopGrid
// loopBars(2 or 4) 마디 그리드. 2마디 = 1열×2, 4마디 = 2열×2.

struct LoopGrid: View {
    @ObservedObject var state: MetronomeState

    private let columns2 = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        LazyVGrid(columns: columns2, spacing: 8) {
            ForEach(0..<state.loopBars, id: \.self) { bar in
                LoopCell(
                    barIndex: bar,
                    isActive: state.isPlaying && state.loopMeasureIdx == bar,
                    chords:  $state.loopChords,
                    chordsB: $state.loopChordsB
                )
            }
        }
    }
}

#Preview {
    LoopGrid(state: MetronomeState())
        .padding()
        .background(ETS.bgDeep)
}
