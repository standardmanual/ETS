//
//  TonesState.swift
//  ETS
//
//  Created by Claude on 2026-04-22.
//

import SwiftUI

// MARK: - CHORDS 데이터 (PRD §7.2)

let CHORDS: [String: [String]] = [
    "C": ["C","E","G"],     "D": ["D","F#","A"],    "E": ["E","G#","B"],
    "F": ["F","A","C"],     "G": ["G","B","D"],     "A": ["A","C#","E"],
    "B": ["B","D#","F#"],
    "Cm": ["C","Eb","G"],   "Dm": ["D","F","A"],    "Em": ["E","G","B"],
    "Fm": ["F","Ab","C"],   "Gm": ["G","Bb","D"],   "Am": ["A","C","E"],
    "Bm": ["B","D","F#"],
    "Db": ["Db","F","Ab"],  "Eb": ["Eb","G","Bb"],  "Gb": ["Gb","Bb","Db"],
    "Ab": ["Ab","C","Eb"],  "Bb": ["Bb","D","F"],
    "Dbm": ["Db","E","Ab"], "Ebm": ["Eb","Gb","Bb"],"Gbm": ["Gb","A","Db"],
    "Abm": ["Ab","B","Eb"], "Bbm": ["Bb","Db","F"],
    "C#": ["C#","F","G#"],  "D#": ["D#","G","A#"],  "F#": ["F#","A#","C#"],
    "G#": ["G#","C","D#"],  "A#": ["A#","D","F"],
    "C#m": ["C#","E","G#"], "D#m": ["D#","Gb","A#"],"F#m": ["F#","A","C#"],
    "G#m": ["G#","B","D#"], "A#m": ["A#","C#","F"],
]

let ALL_NOTES = ["A","Ab","A#","B","Bb","C","C#","D","Db","D#","E","Eb","F","F#","G","Gb","G#"]

// MARK: - TonesState (PRD §7.3)

@MainActor
class TonesState: ObservableObject {
    @Published var currentChord:  String    = ""
    @Published var selectedNotes: Set<String> = []
    @Published var resultText:    String    = ""
    @Published var resultColor:   Color     = .clear

    private var answerSet: [String] = []
    private var autoAdvanceTask: Task<Void, Never>? = nil

    func nextQuestion() {
        autoAdvanceTask?.cancel()
        selectedNotes.removeAll()
        resultText = ""
        resultColor = .clear
        let name = CHORDS.keys.randomElement()!
        currentChord = name
        answerSet = (CHORDS[name] ?? []).map { toSharp($0) }.sorted()
    }

    func checkAnswer() {
        guard !currentChord.isEmpty else { return }
        let sel    = selectedNotes.map { toSharp($0) }.sorted()
        let pretty = (CHORDS[currentChord] ?? []).map { prettyChordLabel($0) }.joined(separator: ", ")
        let ok     = sel == answerSet
        resultText  = ok ? "정답! \(pretty)" : "오답. 정답: \(pretty)"
        resultColor = ok ? Color(hex: "#2b8a3e") : Color(hex: "#c92a2a")

        if ok {
            autoAdvanceTask = Task {
                try? await Task.sleep(nanoseconds: 1_600_000_000)
                guard !Task.isCancelled else { return }
                await MainActor.run { self.nextQuestion() }
            }
        }
    }

    func toggleNote(_ note: String) {
        if selectedNotes.contains(note) { selectedNotes.remove(note) }
        else { selectedNotes.insert(note) }
    }
}
