//
//  DrumSynthesizer.swift
//  ETS
//
//  Created by Claude on 2026-04-22.
//

import AVFoundation

// MARK: - DrumSynthesizer
// 샘플이 없을 때 순수 신디사이저로 드럼 사운드 생성 (fallback).

final class DrumSynthesizer {
    private let sampleRate: Double
    private let format: AVAudioFormat

    init(sampleRate: Double = 44100) {
        self.sampleRate = sampleRate
        self.format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
    }

    // MARK: - Kick

    func makeKick() -> AVAudioPCMBuffer? {
        let duration = 0.25
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        guard let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return nil }
        buf.frameLength = frameCount
        let data = buf.floatChannelData![0]
        for i in 0..<Int(frameCount) {
            let t = Double(i) / sampleRate
            // 피치 스윕: 150Hz → 40Hz
            let freq = 150.0 * exp(-20.0 * t) + 40.0
            let env  = exp(-8.0 * t)
            data[i]  = Float(sin(2 * .pi * freq * t) * env * 0.9)
        }
        return buf
    }

    // MARK: - Snare

    func makeSnare() -> AVAudioPCMBuffer? {
        let duration = 0.15
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        guard let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return nil }
        buf.frameLength = frameCount
        let data = buf.floatChannelData![0]
        for i in 0..<Int(frameCount) {
            let t = Double(i) / sampleRate
            let tone  = sin(2 * .pi * 200 * t) * exp(-25 * t)
            let noise = Double.random(in: -1...1) * exp(-15 * t) * 0.5
            data[i] = Float((tone + noise) * 0.7)
        }
        return buf
    }

    // MARK: - Closed hihat

    func makeHihat() -> AVAudioPCMBuffer? {
        let duration = 0.06
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        guard let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return nil }
        buf.frameLength = frameCount
        let data = buf.floatChannelData![0]
        for i in 0..<Int(frameCount) {
            let t = Double(i) / sampleRate
            let noise = Double.random(in: -1...1) * exp(-60 * t)
            // 밴드패스 느낌: 여러 고주파 합산
            let tone = sin(2 * .pi * 8000 * t) + sin(2 * .pi * 10000 * t)
            data[i] = Float((noise * 0.6 + tone * 0.1) * 0.5)
        }
        return buf
    }

    // MARK: - Open hihat

    func makeOpenHihat() -> AVAudioPCMBuffer? {
        let duration = 0.35
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        guard let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return nil }
        buf.frameLength = frameCount
        let data = buf.floatChannelData![0]
        for i in 0..<Int(frameCount) {
            let t = Double(i) / sampleRate
            let noise = Double.random(in: -1...1) * exp(-8 * t)
            let tone = sin(2 * .pi * 8000 * t) + sin(2 * .pi * 10000 * t)
            data[i] = Float((noise * 0.6 + tone * 0.1) * 0.45)
        }
        return buf
    }

    // MARK: - Bass (synth tone)

    func makeBass(freq: Double, duration: Double) -> AVAudioPCMBuffer? {
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        guard let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return nil }
        buf.frameLength = frameCount
        let data = buf.floatChannelData![0]
        for i in 0..<Int(frameCount) {
            let t = Double(i) / sampleRate
            let attack: Double = 0.005
            let release = max(0, duration - 0.05)
            let env: Double
            if t < attack {
                env = t / attack
            } else if t > release {
                env = max(0, 1 - (t - release) / 0.05)
            } else {
                env = 1.0
            }
            // 사각파 느낌: fundamental + 3rd harmonic
            data[i] = Float((sin(2 * .pi * freq * t) * 0.7 +
                             sin(2 * .pi * freq * 3 * t) * 0.15) * env * 0.6)
        }
        return buf
    }
}
