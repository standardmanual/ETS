//
//  LoopCell.swift
//  ETS
//
//  Created by Claude on 2026-04-22.
//

import SwiftUI

// MARK: - LoopCell
// 루프 그리드의 개별 마디 셀. 코드 표시 + 활성 하이라이트.

struct LoopCell: View {
    let barIndex: Int
    let isActive: Bool
    @Binding var chords:  [Int: String]
    @Binding var chordsB: [Int: String]

    private var chordLabel: String {
        let a = chords[barIndex] ?? "—"
        let b = chordsB[barIndex] ?? "—"
        if a == "—" { return "+" }
        if b == "—" { return prettyChordLabel(a) }
        return "\(prettyChordLabel(a))/\(prettyChordLabel(b))"
    }

    var body: some View {
        LoopChordPicker(barIndex: barIndex, chords: $chords, chordsB: $chordsB)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isActive ? ETS.greenMid : Color.clear, lineWidth: 2)
            )
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isActive ? ETS.greenMid.opacity(0.15) : Color.clear)
            )
            .animation(.easeInOut(duration: 0.1), value: isActive)
    }
}
