//
//  GuitarData.swift
//  ETS
//
//  Created by Claude on 2026-04-22.
//

import Foundation

// MARK: - GuitarCard (PRD §6.5)

struct GuitarCard {
    let chord:       String
    let form:        String
    let string:      String
    let fret:        String
    let baseFretNum: Int
    let type:        String   // "M" | "m"
}

// MARK: - 24개 우선순위 카드

let PRIORITY_CARDS: [GuitarCard] = [
    .init(chord: "A",   form: "A폼", string: "5번줄", fret: "오픈",  baseFretNum: 0, type: "M"),
    .init(chord: "Bb",  form: "A폼", string: "5번줄", fret: "1프렛", baseFretNum: 1, type: "M"),
    .init(chord: "B",   form: "A폼", string: "5번줄", fret: "2프렛", baseFretNum: 2, type: "M"),
    .init(chord: "Db",  form: "A폼", string: "5번줄", fret: "4프렛", baseFretNum: 4, type: "M"),
    .init(chord: "Eb",  form: "A폼", string: "5번줄", fret: "6프렛", baseFretNum: 6, type: "M"),
    .init(chord: "C",   form: "C폼", string: "5번줄", fret: "오픈",  baseFretNum: 0, type: "M"),
    .init(chord: "D",   form: "D폼", string: "4번줄", fret: "오픈",  baseFretNum: 0, type: "M"),
    .init(chord: "E",   form: "E폼", string: "6번줄", fret: "오픈",  baseFretNum: 0, type: "M"),
    .init(chord: "F",   form: "E폼", string: "6번줄", fret: "1프렛", baseFretNum: 1, type: "M"),
    .init(chord: "Gb",  form: "E폼", string: "6번줄", fret: "2프렛", baseFretNum: 2, type: "M"),
    .init(chord: "Ab",  form: "E폼", string: "6번줄", fret: "4프렛", baseFretNum: 4, type: "M"),
    .init(chord: "G",   form: "G폼", string: "6번줄", fret: "오픈",  baseFretNum: 0, type: "M"),
    .init(chord: "Am",  form: "A폼", string: "5번줄", fret: "오픈",  baseFretNum: 0, type: "m"),
    .init(chord: "Bbm", form: "A폼", string: "5번줄", fret: "1프렛", baseFretNum: 1, type: "m"),
    .init(chord: "Bm",  form: "A폼", string: "5번줄", fret: "2프렛", baseFretNum: 2, type: "m"),
    .init(chord: "Cm",  form: "A폼", string: "5번줄", fret: "3프렛", baseFretNum: 3, type: "m"),
    .init(chord: "C#m", form: "A폼", string: "5번줄", fret: "4프렛", baseFretNum: 4, type: "m"),
    .init(chord: "Ebm", form: "A폼", string: "5번줄", fret: "6프렛", baseFretNum: 6, type: "m"),
    .init(chord: "Dm",  form: "D폼", string: "4번줄", fret: "오픈",  baseFretNum: 0, type: "m"),
    .init(chord: "Em",  form: "E폼", string: "6번줄", fret: "오픈",  baseFretNum: 0, type: "m"),
    .init(chord: "Fm",  form: "E폼", string: "6번줄", fret: "1프렛", baseFretNum: 1, type: "m"),
    .init(chord: "F#m", form: "E폼", string: "6번줄", fret: "2프렛", baseFretNum: 2, type: "m"),
    .init(chord: "Gm",  form: "E폼", string: "6번줄", fret: "3프렛", baseFretNum: 3, type: "m"),
    .init(chord: "G#m", form: "E폼", string: "6번줄", fret: "4프렛", baseFretNum: 4, type: "m"),
]

// MARK: - FretDot + SHAPE_DOTS (PRD §6.7)

struct FretDot {
    let s: Int    // 줄 번호 (1~6)
    let f: Int    // 폼 내 상대 프렛 (0=루트줄 오픈)
    let r: Bool   // true = root
}

func makeShapeKey(for card: GuitarCard) -> String {
    let prefix = String(card.form.prefix(1))   // "A폼" → "A"
    return "\(prefix)폼_\(card.type)"          // "A폼_M"
}

let SHAPE_DOTS: [String: [FretDot]] = [
    "A폼_M": [
        .init(s: 5, f: 0, r: true),
        .init(s: 4, f: 2, r: false),
        .init(s: 3, f: 2, r: false),
        .init(s: 2, f: 2, r: false),
        .init(s: 1, f: 0, r: false),
    ],
    "A폼_m": [
        .init(s: 5, f: 0, r: true),
        .init(s: 4, f: 2, r: false),
        .init(s: 3, f: 2, r: false),
        .init(s: 2, f: 1, r: false),
        .init(s: 1, f: 0, r: false),
    ],
    "E폼_M": [
        .init(s: 6, f: 0, r: true),
        .init(s: 5, f: 2, r: false),
        .init(s: 4, f: 2, r: false),
        .init(s: 3, f: 1, r: false),
        .init(s: 2, f: 0, r: false),
        .init(s: 1, f: 0, r: false),
    ],
    "E폼_m": [
        .init(s: 6, f: 0, r: true),
        .init(s: 5, f: 2, r: false),
        .init(s: 4, f: 2, r: false),
        .init(s: 3, f: 0, r: false),
        .init(s: 2, f: 0, r: false),
        .init(s: 1, f: 0, r: false),
    ],
    "C폼_M": [
        .init(s: 5, f: 3, r: true),
        .init(s: 4, f: 2, r: false),
        .init(s: 3, f: 0, r: false),
        .init(s: 2, f: 1, r: false),
        .init(s: 1, f: 0, r: false),
    ],
    "D폼_M": [
        .init(s: 4, f: 0, r: true),
        .init(s: 3, f: 2, r: false),
        .init(s: 2, f: 3, r: false),
        .init(s: 1, f: 2, r: false),
    ],
    "D폼_m": [
        .init(s: 4, f: 0, r: true),
        .init(s: 3, f: 2, r: false),
        .init(s: 2, f: 3, r: false),
        .init(s: 1, f: 1, r: false),
    ],
    "G폼_M": [
        .init(s: 6, f: 3, r: true),
        .init(s: 5, f: 2, r: false),
        .init(s: 4, f: 0, r: false),
        .init(s: 3, f: 0, r: false),
        .init(s: 2, f: 0, r: false),
        .init(s: 1, f: 3, r: false),
    ],
]
