//
//  ClickSoundGenerator.swift
//  ETS
//
//  Created by Claude on 2026-04-22.
//

import AVFoundation

// MARK: - ClickSoundGenerator
// 클릭 모드 사운드: 신디사이저로 클릭 버퍼 생성.
// accent(강박) = 높은 피치, normal = 낮은 피치.
// wood 모드 = 목탁 느낌 (빠른 감쇄, 낮은 주파수).

final class ClickSoundGenerator {
    private let sampleRate: Double
    private let format: AVAudioFormat

    init(sampleRate: Double = 44100) {
        self.sampleRate = sampleRate
        self.format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
    }

    func makeBuffer(type: ClickType, isAccent: Bool) -> AVAudioPCMBuffer? {
        switch type {
        case .default_: return makeBeepBuffer(isAccent: isAccent)
        case .wood:     return makeWoodBuffer(isAccent: isAccent)
        }
    }

    // MARK: - Beep (default)

    private func makeBeepBuffer(isAccent: Bool) -> AVAudioPCMBuffer? {
        let freq: Double = isAccent ? 1800 : 1200
        let duration: Double = 0.04
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        guard let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return nil }
        buf.frameLength = frameCount
        let data = buf.floatChannelData![0]
        for i in 0..<Int(frameCount) {
            let t = Double(i) / sampleRate
            let env = max(0, 1.0 - t / duration)
            data[i] = Float(sin(2 * .pi * freq * t) * env * 0.7)
        }
        return buf
    }

    // MARK: - Wood block

    private func makeWoodBuffer(isAccent: Bool) -> AVAudioPCMBuffer? {
        let freq: Double = isAccent ? 700 : 500
        let duration: Double = 0.06
        let decay: Double = 30.0   // 빠른 지수 감쇄
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        guard let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return nil }
        buf.frameLength = frameCount
        let data = buf.floatChannelData![0]
        for i in 0..<Int(frameCount) {
            let t = Double(i) / sampleRate
            let env = exp(-decay * t)
            data[i] = Float(sin(2 * .pi * freq * t) * env * 0.8)
        }
        return buf
    }
}
