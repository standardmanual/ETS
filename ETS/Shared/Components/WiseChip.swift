//
//  WiseChip.swift
//  ETS
//
//  Created by Claude on 2026-04-22.
//

import SwiftUI

// MARK: - WiseChip
// 36pt height, pill shape, 14/500 font.
// Default:  bgScreen bg, borderNeutral 1pt border, contentPrimary text.
// Selected: interactivePrimary bg + border, white text.
// Used as NoteChip in the Tones tab (§7.4).

struct WiseChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(isSelected ? Color.white : Wise.contentPrimary)
                .frame(height: 36)
                .padding(.horizontal, Wise.sp12)
                .background(isSelected ? Wise.interactivePrimary : Wise.bgScreen)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(
                            isSelected ? Wise.interactivePrimary : Wise.borderNeutral,
                            lineWidth: 1
                        )
                )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.12), value: isSelected)
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var selected: Set<String> = ["C", "E"]

    let notes = ["A", "Ab", "A#", "B", "Bb", "C", "C#", "D"]

    ScrollView {
        // flex-wrap simulation
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 60), spacing: Wise.sp8)],
            spacing: Wise.sp8
        ) {
            ForEach(notes, id: \.self) { note in
                WiseChip(title: note, isSelected: selected.contains(note)) {
                    if selected.contains(note) { selected.remove(note) }
                    else { selected.insert(note) }
                }
            }
        }
        .padding()
    }
}
