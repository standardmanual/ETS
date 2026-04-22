//
//  PriorityState.swift
//  ETS
//
//  Created by Claude on 2026-04-22.
//

import SwiftUI

// MARK: - PriorityState (PRD §6.6)

@MainActor
class PriorityState: ObservableObject {
    @Published var currentChord:  String      = "—"
    @Published var hintText:      String      = ""
    @Published var showFretboard: Bool        = false
    @Published var isShuffling:   Bool        = false
    @Published var shuffleCount:  Int         = 10
    @Published var currentCard:   GuitarCard? = nil

    private var order:         [Int]               = []
    private var cursor:        Int                 = -1
    private var lastIndex:     Int                 = -1
    private var shuffleTimer:  Timer?              = nil
    private var hintDelayTask: Task<Void, Never>?  = nil

    // MARK: - Order management

    private func initOrder() { order = Array(0..<PRIORITY_CARDS.count) }

    func randomizeOrder() {
        if order.isEmpty { initOrder() }
        order.shuffle()
        cursor = -1
    }

    func nextCard() {
        if order.isEmpty { initOrder() }
        cursor = (cursor + 1) % order.count
        if order[cursor] == lastIndex { cursor = (cursor + 1) % order.count }
        showCard(index: order[cursor])
    }

    private func showCard(index: Int) {
        let card = PRIORITY_CARDS[index]
        currentCard  = card
        currentChord = prettyChordLabel(card.chord)
        lastIndex    = index
    }

    // MARK: - Hint

    func renderHint(immediate: Bool, hintOn: Bool) {
        hintDelayTask?.cancel()
        hintDelayTask = nil
        hintText      = ""
        showFretboard = false
        guard hintOn, let card = currentCard else { return }
        let delay: UInt64 = immediate ? 0 : 2_000_000_000
        hintDelayTask = Task {
            if delay > 0 { try? await Task.sleep(nanoseconds: delay) }
            guard !Task.isCancelled, hintOn else { return }
            await MainActor.run {
                hintText      = "힌트 : \(card.form) \(card.string) \(card.fret)"
                showFretboard = true
            }
        }
    }

    func toggleHint(hintOn: Bool) {
        if hintOn { renderHint(immediate: true, hintOn: true) }
        else { hintDelayTask?.cancel(); hintText = ""; showFretboard = false }
    }

    // MARK: - Appearance

    func onAppear(hintOn: Bool) {
        if cursor == -1 {
            randomizeOrder()
            nextCard()
            renderHint(immediate: false, hintOn: hintOn)
        } else {
            renderHint(immediate: true, hintOn: hintOn)
        }
    }

    // MARK: - Controls

    func onNextCardTapped(hintOn: Bool) {
        nextCard()
        renderHint(immediate: false, hintOn: hintOn)
        if isShuffling { shuffleCount = 10 }
    }

    func startShuffle(hintOn: Bool) {
        randomizeOrder(); nextCard()
        renderHint(immediate: false, hintOn: hintOn)
        isShuffling = true; shuffleCount = 10
        shuffleTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.shuffleCount -= 1
                if self.shuffleCount <= 0 {
                    self.nextCard()
                    self.renderHint(immediate: false, hintOn: hintOn)
                    self.shuffleCount = 10
                }
            }
        }
    }

    func stopShuffle() {
        shuffleTimer?.invalidate()
        shuffleTimer = nil
        isShuffling  = false
    }

    func onDisappear() { stopShuffle() }
}
