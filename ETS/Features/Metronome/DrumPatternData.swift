//
//  DrumPatternData.swift
//  ETS
//
//  Created by Claude on 2026-04-22.
//

import Foundation

// MARK: - Drum step event

struct DrumStep {
    let kick:       Bool
    let snare:      Bool
    let hihat:      Bool
    let hihatOpen:  Bool
}

// MARK: - Pattern (16 steps per bar)

struct DrumPattern {
    let steps: [DrumStep]  // count == 16
}

// MARK: - Bass note

struct BassNote {
    let note:    String    // "A", "B" … "G"
    let octave:  Int
    let beat:    Int       // 0-based 16th-note step within bar
    let dur:     Double    // duration in beats (quarter = 1.0)
}

// MARK: - Bass frequencies (12음)

let BASS_FREQ: [String: Double] = [
    "C":  65.41, "C#": 69.30, "D":  73.42, "D#": 77.78,
    "E":  82.41, "F":  87.31, "F#": 92.50, "G":  98.00,
    "G#": 103.83,"A":  110.00,"A#": 116.54,"B":  123.47
]

// MARK: - 8 Drum patterns

let DRUM_PATTERNS: [RhythmKey: DrumPattern] = {
    func s(_ k: Bool, _ sn: Bool, _ hh: Bool, _ ho: Bool) -> DrumStep {
        DrumStep(kick: k, snare: sn, hihat: hh, hihatOpen: ho)
    }
    let _ = s  // silence warning

    // helper aliases
    let O = true; let _ = false

    return [
        .eighth_A: DrumPattern(steps: [
            // 16 steps: K=kick, S=snare, H=hihat, O=open-hihat
            s(O,_,O,_), s(_,_,O,_), s(_,_,O,_), s(_,_,O,_),
            s(_,O,O,_), s(_,_,O,_), s(_,_,O,_), s(_,_,O,_),
            s(O,_,O,_), s(_,_,O,_), s(_,_,O,_), s(_,_,O,_),
            s(_,O,O,_), s(_,_,O,_), s(_,_,O,_), s(_,_,O,_),
        ]),
        .eighth_B: DrumPattern(steps: [
            s(O,_,O,_), s(_,_,O,_), s(_,_,O,_), s(_,_,O,_),
            s(_,O,O,_), s(_,_,O,_), s(O,_,O,_), s(_,_,O,_),
            s(O,_,O,_), s(_,_,O,_), s(_,_,O,_), s(_,_,O,_),
            s(_,O,O,_), s(_,_,O,_), s(_,_,_,O), s(_,_,O,_),
        ]),
        .eighth_C: DrumPattern(steps: [
            s(O,_,O,_), s(_,_,O,_), s(_,_,_,O), s(_,_,O,_),
            s(_,O,O,_), s(_,_,O,_), s(_,_,_,O), s(_,_,O,_),
            s(O,_,O,_), s(_,_,O,_), s(_,_,_,O), s(_,_,O,_),
            s(_,O,O,_), s(_,_,O,_), s(_,_,_,O), s(_,_,O,_),
        ]),
        .eighth_D: DrumPattern(steps: [
            s(O,_,O,_), s(_,_,_,_), s(_,_,O,_), s(_,_,_,_),
            s(_,O,O,_), s(_,_,_,_), s(O,_,O,_), s(_,_,_,_),
            s(O,_,O,_), s(_,_,_,_), s(_,_,O,_), s(_,_,_,_),
            s(_,O,O,_), s(_,_,_,_), s(O,O,O,_), s(_,_,_,_),
        ]),
        .sixteenth_A: DrumPattern(steps: [
            s(O,_,O,_), s(_,_,O,_), s(_,_,O,_), s(_,_,O,_),
            s(_,O,O,_), s(_,_,O,_), s(_,_,O,_), s(_,_,O,_),
            s(O,_,O,_), s(_,_,O,_), s(O,_,O,_), s(_,_,O,_),
            s(_,O,O,_), s(_,_,O,_), s(_,_,O,_), s(_,_,O,_),
        ]),
        .sixteenth_B: DrumPattern(steps: [
            s(O,_,O,_), s(_,_,O,_), s(_,_,O,_), s(O,_,O,_),
            s(_,O,O,_), s(_,_,O,_), s(_,_,O,_), s(_,_,O,_),
            s(O,_,O,_), s(_,_,O,_), s(_,_,O,_), s(O,_,O,_),
            s(_,O,O,_), s(_,_,O,_), s(_,_,O,_), s(_,_,O,_),
        ]),
        .sixteenth_C: DrumPattern(steps: [
            s(O,_,O,_), s(_,_,O,_), s(_,O,O,_), s(_,_,O,_),
            s(_,O,O,_), s(_,_,O,_), s(_,_,O,_), s(_,_,O,_),
            s(O,_,O,_), s(_,_,O,_), s(_,O,O,_), s(_,_,O,_),
            s(_,O,O,_), s(_,_,O,_), s(_,_,O,_), s(_,_,O,_),
        ]),
        .sixteenth_D: DrumPattern(steps: [
            s(O,_,O,_), s(_,_,O,_), s(_,_,O,_), s(_,_,O,_),
            s(_,O,O,_), s(_,_,O,_), s(O,O,O,_), s(_,_,O,_),
            s(O,_,O,_), s(_,_,O,_), s(_,_,O,_), s(_,_,O,_),
            s(_,O,O,_), s(O,_,O,_), s(_,_,O,_), s(_,_,O,_),
        ]),
    ]
}()

// MARK: - 8 Bass patterns

let BASS_PATTERNS: [RhythmKey: [BassNote]] = [
    .eighth_A:   [BassNote(note: "E", octave: 2, beat: 0,  dur: 2.0),
                  BassNote(note: "E", octave: 2, beat: 8,  dur: 2.0)],
    .eighth_B:   [BassNote(note: "A", octave: 2, beat: 0,  dur: 1.5),
                  BassNote(note: "A", octave: 2, beat: 6,  dur: 0.5),
                  BassNote(note: "A", octave: 2, beat: 8,  dur: 2.0)],
    .eighth_C:   [BassNote(note: "D", octave: 2, beat: 0,  dur: 4.0)],
    .eighth_D:   [BassNote(note: "G", octave: 2, beat: 0,  dur: 2.0),
                  BassNote(note: "G", octave: 2, beat: 8,  dur: 1.5),
                  BassNote(note: "G", octave: 2, beat: 14, dur: 0.5)],
    .sixteenth_A:[BassNote(note: "A", octave: 2, beat: 0,  dur: 2.0),
                  BassNote(note: "A", octave: 2, beat: 4,  dur: 2.0),
                  BassNote(note: "E", octave: 2, beat: 8,  dur: 2.0),
                  BassNote(note: "G", octave: 2, beat: 12, dur: 2.0)],
    .sixteenth_B:[BassNote(note: "E", octave: 2, beat: 0,  dur: 1.0),
                  BassNote(note: "B", octave: 2, beat: 4,  dur: 1.0),
                  BassNote(note: "E", octave: 2, beat: 8,  dur: 1.0),
                  BassNote(note: "B", octave: 2, beat: 12, dur: 1.0)],
    .sixteenth_C:[BassNote(note: "D", octave: 2, beat: 0,  dur: 2.0),
                  BassNote(note: "A", octave: 2, beat: 8,  dur: 2.0)],
    .sixteenth_D:[BassNote(note: "G", octave: 2, beat: 0,  dur: 4.0)],
]
