//
//  LoopChordPicker.swift
//  ETS
//
//  Created by Claude on 2026-04-22.
//

import SwiftUI

// MARK: - LoopChordPicker
// 마디별 코드 선택 sheet / picker

private let LOOP_CHORDS: [String] = [
    "—",
    "C","C#","D","D#","E","F","F#","G","G#","A","A#","B",
    "Cm","C#m","Dm","D#m","Em","Fm","F#m","Gm","G#m","Am","A#m","Bm"
]

struct LoopChordPicker: View {
    let barIndex: Int
    @Binding var chords:  [Int: String]
    @Binding var chordsB: [Int: String]

    @State private var showPicker = false

    private var label: String {
        let a = chords[barIndex] ?? "—"
        let b = chordsB[barIndex] ?? "—"
        if a == "—" { return "+" }
        if b == "—" { return a }
        return "\(a)/\(b)"
    }

    var body: some View {
        Button(action: { showPicker = true }) {
            Text(prettyChordLabel(label))
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(label == "+" ? ETS.greenDark : ETS.greenPale)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(label == "+" ? ETS.greenDeep.opacity(0.3) : ETS.greenDeep.opacity(0.7))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .sheet(isPresented: $showPicker) {
            chordPickerSheet
        }
    }

    @ViewBuilder
    private var chordPickerSheet: some View {
        NavigationStack {
            List {
                Section("A コード") {
                    ForEach(LOOP_CHORDS, id: \.self) { ch in
                        Button(action: {
                            chords[barIndex] = ch == "—" ? nil : ch
                            showPicker = false
                        }) {
                            HStack {
                                Text(prettyChordLabel(ch))
                                    .foregroundStyle(Wise.contentPrimary)
                                Spacer()
                                if (chords[barIndex] ?? "—") == ch {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(Wise.interactivePrimary)
                                }
                            }
                        }
                    }
                }
                Section("B コード (분수코드)") {
                    ForEach(LOOP_CHORDS, id: \.self) { ch in
                        Button(action: {
                            chordsB[barIndex] = ch == "—" ? nil : ch
                            showPicker = false
                        }) {
                            HStack {
                                Text(prettyChordLabel(ch))
                                    .foregroundStyle(Wise.contentPrimary)
                                Spacer()
                                if (chordsB[barIndex] ?? "—") == ch {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(Wise.interactivePrimary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("마디 \(barIndex + 1) 코드")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("닫기") { showPicker = false }
                }
            }
        }
    }
}

// MARK: - Shared utilities (PRD §4)

func prettyChordLabel(_ s: String) -> String {
    s.replacingOccurrences(of: "b", with: "♭")
     .replacingOccurrences(of: "#", with: "♯")
}

func toSharp(_ n: String) -> String {
    let map: [String: String] = [
        "Bb": "A#", "Eb": "D#", "Ab": "G#", "Db": "C#", "Gb": "F#",
        "Bbm": "A#m", "Ebm": "D#m", "Abm": "G#m", "Dbm": "C#m", "Gbm": "F#m"
    ]
    return map[n] ?? n
}

func enharmNormalize(_ s: String) -> String {
    var t = s.trimmingCharacters(in: .whitespaces)
    t = t.replacingOccurrences(of: "♭", with: "b")
         .replacingOccurrences(of: "♯", with: "#")
    let isMinor = t.hasSuffix("m") && t.count > 1
    let base = isMinor ? String(t.dropLast()) : t
    let map = ["BB": "A#", "EB": "D#", "AB": "G#", "DB": "C#", "GB": "F#"]
    let up   = base.uppercased()
    let norm = map[up] ?? up
    return norm + (isMinor ? "m" : "")
}
