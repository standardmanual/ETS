//
//  SamplePlayer.swift
//  ETS
//
//  Created by Claude on 2026-04-22.
//

import AVFoundation

// MARK: - SamplePlayer
// sound/ 폴더의 mp3 샘플을 AVAudioPCMBuffer로 로드.
// 로드 실패 시 nil 반환 → MetronomeEngine이 신디사이저로 fallback.

final class SamplePlayer {
    static let shared = SamplePlayer()
    private init() {}

    // 파일명 → 버퍼 캐시
    private var cache: [String: AVAudioPCMBuffer] = [:]

    func load(named name: String, format: AVAudioFormat) -> AVAudioPCMBuffer? {
        if let cached = cache[name] { return cached }

        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3",
                                        subdirectory: "sound") else { return nil }
        guard let file = try? AVAudioFile(forReading: url),
              let buf  = AVAudioPCMBuffer(pcmFormat: format,
                                         frameCapacity: AVAudioFrameCount(file.length))
        else { return nil }

        try? file.read(into: buf)
        cache[name] = buf
        return buf
    }

    func clearCache() {
        cache.removeAll()
    }
}
