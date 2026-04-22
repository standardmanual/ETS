//
//  NoteChipGrid.swift
//  ETS
//
//  Created by Claude on 2026-04-22.
//

import SwiftUI

// MARK: - NoteChipGrid
// ALL_NOTES 17개, flex-wrap 자동 줄바꿈 (LazyVGrid adaptive)

struct NoteChipGrid: View {
    @ObservedObject var state: TonesState

    private let columns = [GridItem(.adaptive(minimum: 58), spacing: Wise.sp8)]

    var body: some View {
        LazyVGrid(columns: columns, spacing: Wise.sp8) {
            ForEach(ALL_NOTES, id: \.self) { note in
                WiseChip(
                    title: prettyChordLabel(note),
                    isSelected: state.selectedNotes.contains(note)
                ) {
                    state.toggleNote(note)
                }
            }
        }
    }
}

#Preview {
    NoteChipGrid(state: TonesState())
        .padding()
}
