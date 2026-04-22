//
//  TapTempoDetector.swift
//  ETS
//
//  Created by Claude on 2026-04-22.
//

import Foundation

// MARK: - TapTempoDetector
// TAP_RESET_MS = 2500ms 이상 간격이면 이전 기록 리셋
// 범위: 30~300 BPM

@MainActor
final class TapTempoDetector {
    private static let tapResetInterval: TimeInterval = 2.5
    private static let minBPM = 30
    private static let maxBPM = 300

    private var tapTimes: [Date] = []

    /// 탭 발생 시 호출. 계산된 BPM 반환 (nil = 탭 수 부족).
    func tap() -> Int? {
        let now = Date()
        if let last = tapTimes.last, now.timeIntervalSince(last) > Self.tapResetInterval {
            tapTimes.removeAll()
        }
        tapTimes.append(now)

        guard tapTimes.count >= 2 else { return nil }

        // 최근 8 탭만 사용
        if tapTimes.count > 8 { tapTimes.removeFirst() }

        let intervals = zip(tapTimes, tapTimes.dropFirst()).map { $1.timeIntervalSince($0) }
        let avg = intervals.reduce(0, +) / Double(intervals.count)
        let bpm = Int((60.0 / avg).rounded())
        return min(Self.maxBPM, max(Self.minBPM, bpm))
    }

    func reset() {
        tapTimes.removeAll()
    }
}
