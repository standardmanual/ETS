//
//  MetronomeEngine.swift
//  ETS
//
//  Created by Claude on 2026-04-22.
//

import AVFoundation
import SwiftUI

// MARK: - MetronomeEngine
// AVAudioEngine + lookahead 스케줄러 (lookahead=25ms, scheduleAheadTime=0.1s).
// stopMetronome: masterGainNode = nil, bassBusNode = nil → 재시작 시 새로 생성.

@MainActor
final class MetronomeEngine: ObservableObject {

    // ── 오디오 엔진 ──
    private let engine = AVAudioEngine()
    private var masterGainNode: AVAudioMixerNode?
    private var bassBusNode:    AVAudioMixerNode?

    // ── 스케줄러 ──
    private var schedulerTimer: Timer?
    private let lookahead:        TimeInterval = 0.025   // 25ms
    private let scheduleAheadTime:TimeInterval = 0.100   // 100ms

    // ── 상태 참조 (weak 순환 방지) ──
    weak var state: MetronomeState?

    // ── 사운드 생성기 ──
    private let clickGen  = ClickSoundGenerator()
    private let drumSynth = DrumSynthesizer()

    // ── 스텝 추적 ──
    private var nextBeatTime:  Double = 0
    private var currentStep:   Int    = 0    // 0..<(timeSig*4) in drum/loop, 0..<timeSig in click
    private var barCount:      Int    = 0

    // ── 오픈 하이햇 초크 추적 ──
    private var openHihatNode: AVAudioPlayerNode?
    private var bassPlayerNode: AVAudioPlayerNode?

    // MARK: - Public API

    func startMetronome() {
        guard let state else { return }

        setupAudioSession()
        let masterOut = getMasterOut()

        do { try engine.start() } catch { return }

        let now = engine.outputNode.lastRenderTime.flatMap {
            engine.outputNode.convert(from: $0, to: engine.outputNode.outputFormat(forBus: 0))
        }?.sampleTime.map { Double($0) / engine.outputNode.outputFormat(forBus: 0).sampleRate }
            ?? AVAudioTime.seconds(forHostTime: mach_absolute_time())

        nextBeatTime = now + lookahead
        currentStep = 0
        barCount = 0

        schedulerTimer = Timer.scheduledTimer(withTimeInterval: lookahead, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in self?.scheduleBeats() }
        }
    }

    func stopMetronome() {
        schedulerTimer?.invalidate()
        schedulerTimer = nil

        let now = engine.outputNode.lastRenderTime.flatMap {
            engine.outputNode.convert(from: $0, to: engine.outputNode.outputFormat(forBus: 0))
        }?.sampleTime.map { Double($0) / engine.outputNode.outputFormat(forBus: 0).sampleRate }
            ?? 0
        chokeOpenHihat(at: now)
        chokeBass(at: now)

        // v3.1: nil 처리 → 재시작 시 getMasterOut()에서 새로 생성
        if let m = masterGainNode { engine.detach(m) }
        if let b = bassBusNode    { engine.detach(b) }
        masterGainNode = nil
        bassBusNode    = nil

        state?.activeDotIndex = -1
        state?.isPlaying = false
    }

    func setMasterVolume(_ v: Double) {
        masterGainNode?.outputVolume = Float(v)
    }

    // MARK: - Audio Session

    private func setupAudioSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .default)
        try? session.setActive(true)
    }

    // MARK: - Graph setup

    private func getMasterOut() -> AVAudioMixerNode {
        if let m = masterGainNode { return m }
        let m = AVAudioMixerNode()
        engine.attach(m)
        engine.connect(m, to: engine.mainMixerNode, format: nil)
        m.outputVolume = Float(state?.masterVolume ?? 1.0)
        masterGainNode = m
        return m
    }

    private func getBassBus() -> AVAudioMixerNode {
        if let b = bassBusNode { return b }
        let b = AVAudioMixerNode()
        engine.attach(b)
        engine.connect(b, to: getMasterOut(), format: nil)
        bassBusNode = b
        return b
    }

    // MARK: - Scheduler

    private func scheduleBeats() {
        guard let state, state.isPlaying else { return }

        let now = currentHostTime()
        let secondsPerBeat = 60.0 / Double(state.bpm)

        while nextBeatTime < now + scheduleAheadTime {
            scheduleBeat(at: nextBeatTime, state: state)
            nextBeatTime += secondsPerBeat / subdivisions(state: state)
        }
    }

    private func subdivisions(state: MetronomeState) -> Double {
        switch state.soundMode {
        case .click: return 1.0
        case .drum, .loop: return 4.0   // 16분음표 단위
        }
    }

    private func scheduleBeat(at time: Double, state: MetronomeState) {
        switch state.soundMode {
        case .click:
            scheduleClick(at: time, state: state)
        case .drum:
            scheduleDrumStep(at: time, state: state)
        case .loop:
            scheduleLoopStep(at: time, state: state)
        }
    }

    // MARK: - Click mode

    private func scheduleClick(at time: Double, state: MetronomeState) {
        let timeSig = TIME_SIGS[state.timeSig]
        let beat    = currentStep % timeSig
        let isAccent = beat == 0

        if let buf = loadClickBuffer(type: state.clickType, isAccent: isAccent) {
            playBuffer(buf, at: time, through: getMasterOut())
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + max(0, time - currentHostTime())) { [weak self] in
            self?.state?.activeDotIndex = beat
        }

        currentStep = (currentStep + 1) % timeSig
    }

    // MARK: - Drum mode

    private func scheduleDrumStep(at time: Double, state: MetronomeState) {
        let pattern = DRUM_PATTERNS[state.drumRhythm]
        let step = currentStep % 16

        if let p = pattern {
            let s = p.steps[step]
            if s.kick      { scheduleKick(at: time) }
            if s.snare     { scheduleSnare(at: time) }
            if s.hihat     { scheduleHihat(at: time) }
            if s.hihatOpen { scheduleOpenHihat(at: time) }
        }

        let beat = step / 4
        if step % 4 == 0 {
            let timeSig = TIME_SIGS[state.timeSig]
            DispatchQueue.main.asyncAfter(deadline: .now() + max(0, time - currentHostTime())) { [weak self] in
                self?.state?.activeDotIndex = beat % timeSig
            }
        }

        if step == 15 {
            barCount += 1
            if barCount % 4 == 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + max(0, time - currentHostTime())) { [weak self] in
                    self?.state?.shuffleRhythm()
                    self?.state?.currentBar = 0
                }
            } else {
                let bar = barCount % 4
                DispatchQueue.main.asyncAfter(deadline: .now() + max(0, time - currentHostTime())) { [weak self] in
                    self?.state?.currentBar = bar
                }
            }
        }

        currentStep = (currentStep + 1) % 16
    }

    // MARK: - Loop mode

    private func scheduleLoopStep(at time: Double, state: MetronomeState) {
        // Loop mode: same drum schedule + bass line
        scheduleDrumStep(at: time, state: state)

        let step = (currentStep - 1 + 16) % 16  // already advanced in drumStep
        if let bassNotes = BASS_PATTERNS[state.loopRhythm] {
            let secondsPerBeat = 60.0 / Double(state.bpm)
            for note in bassNotes where note.beat == step {
                let freq = BASS_FREQ[note.note] ?? 110
                let dur  = note.dur * secondsPerBeat
                if let buf = drumSynth.makeBass(freq: freq, duration: dur) {
                    playBuffer(buf, at: time, through: getBassBus())
                }
            }
        }
    }

    // MARK: - Per-instrument scheduling

    private func scheduleKick(at time: Double) {
        let buf = loadDrumSample(name: "kick") ?? drumSynth.makeKick()
        if let b = buf { playBuffer(b, at: time, through: getMasterOut()) }
    }

    private func scheduleSnare(at time: Double) {
        let buf = loadDrumSample(name: "snare") ?? drumSynth.makeSnare()
        if let b = buf { playBuffer(b, at: time, through: getMasterOut()) }
    }

    private func scheduleHihat(at time: Double) {
        let buf = loadDrumSample(name: "hihat") ?? drumSynth.makeHihat()
        if let b = buf { playBuffer(b, at: time, through: getMasterOut()) }
    }

    private func scheduleOpenHihat(at time: Double) {
        chokeOpenHihat(at: time)
        let buf = loadDrumSample(name: "hihat open") ?? drumSynth.makeOpenHihat()
        if let b = buf { playBuffer(b, at: time, through: getMasterOut()) }
    }

    private func chokeOpenHihat(at _: Double) {
        openHihatNode?.stop()
    }

    private func chokeBass(at _: Double) {
        bassPlayerNode?.stop()
    }

    // MARK: - Buffer helpers

    private func playBuffer(_ buf: AVAudioPCMBuffer, at time: Double, through mixer: AVAudioMixerNode) {
        let node = AVAudioPlayerNode()
        engine.attach(node)
        engine.connect(node, to: mixer, format: buf.format)
        node.play()

        let delay = max(0, time - currentHostTime())
        let when  = AVAudioTime(hostTime: mach_absolute_time() + UInt64(delay * Double(mach_timebase_info_data_t().numer) / Double(mach_timebase_info_data_t().denom)))
        node.scheduleBuffer(buf, at: when, options: []) {
            DispatchQueue.main.async { [weak self] in
                self?.engine.detach(node)
            }
        }
    }

    private func loadClickBuffer(type: ClickType, isAccent: Bool) -> AVAudioPCMBuffer? {
        clickGen.makeBuffer(type: type, isAccent: isAccent)
    }

    private func loadDrumSample(name: String) -> AVAudioPCMBuffer? {
        let fmt = engine.mainMixerNode.inputFormat(forBus: 0)
        return SamplePlayer.shared.load(named: name, format: fmt)
    }

    // MARK: - Time helper

    private func currentHostTime() -> Double {
        var info = mach_timebase_info_data_t()
        mach_timebase_info(&info)
        let nanos = Double(mach_absolute_time()) * Double(info.numer) / Double(info.denom)
        return nanos / 1_000_000_000
    }
}
