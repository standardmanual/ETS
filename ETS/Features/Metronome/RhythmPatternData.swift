//
//  RhythmPatternData.swift
//  ETS
//
//  Created by Claude on 2026-04-22.
//

import Foundation

// MARK: - Rhythm pattern definition

struct RhythmSVGPattern {
    let noteOffsets: [Int]     // 박 기준 상대 x 오프셋
    let beams: [[Int]]         // [[startOffset, endOffset, yLevel]]
    let dottedIndices: [Int]   // 점음표 적용할 음표 인덱스
}

// MARK: - 8 patterns from guitar.html original

let RHYTHM_PATTERNS: [Int: RhythmSVGPattern] = [
    1: .init(noteOffsets: [0],             beams: [],                                   dottedIndices: []),
    2: .init(noteOffsets: [0, 40],         beams: [[0, 40, 0]],                         dottedIndices: []),
    3: .init(noteOffsets: [0, 20, 40, 60], beams: [[0, 60, 0], [0, 60, 1]],             dottedIndices: []),
    4: .init(noteOffsets: [0, 40, 60],     beams: [[0, 60, 0], [40, 60, 1]],            dottedIndices: []),
    5: .init(noteOffsets: [0, 20, 40],     beams: [[0, 40, 0], [0, 20, 1]],             dottedIndices: []),
    6: .init(noteOffsets: [0, 20, 60],     beams: [[0, 60, 0], [0, 12, 1], [48, 60, 1]],dottedIndices: []),
    7: .init(noteOffsets: [0, 60],         beams: [[0, 60, 0], [48, 60, 1]],            dottedIndices: [0]),
    8: .init(noteOffsets: [0, 20],         beams: [[0, 20, 0], [0, 12, 1]],             dottedIndices: [1]),
]

// MARK: - Pick algorithm (guitar.html 원본 로직)

func rhythmPickFour() -> [Int] {
    let allowPair = Double.random(in: 0..<1) < 0.4
    var set: [Int] = []
    func rnd() -> Int { Int.random(in: 1...8) }
    if allowPair {
        let pair = rnd()
        set = [pair, pair]
        while set.count < 4 {
            let n = rnd()
            if n != pair && !set.contains(n) { set.append(n) }
        }
    } else {
        while set.count < 4 {
            let n = rnd()
            if !set.contains(n) { set.append(n) }
        }
    }
    return set.shuffled()
}
