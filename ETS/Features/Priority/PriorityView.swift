//
//  PriorityView.swift
//  ETS
//
//  Created by Claude on 2026-04-22.
//

import SwiftUI

// MARK: - PriorityView (PRD §6.1)

struct PriorityView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var state = PriorityState()

    var body: some View {
        ZStack {
            Wise.bgScreen.ignoresSafeArea()

            VStack(spacing: 0) {
                // ── PageHeader ──
                VStack(alignment: .leading, spacing: 4) {
                    Text("우선순위")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Wise.contentPrimary)
                    Text("핵심 코드 24개 · CAGED 폼 기반")
                        .font(.system(size: 14))
                        .foregroundStyle(Wise.contentSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Wise.sp24)
                .padding(.top, Wise.sp24)
                .padding(.bottom, Wise.sp16)

                ScrollView {
                    VStack(spacing: Wise.sp16) {
                        // ── WiseCard ──
                        VStack(alignment: .leading, spacing: Wise.sp16) {
                            Text("코드 플래시카드")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Wise.contentSecondary)

                            VStack(spacing: Wise.sp16) {
                                // 코드명
                                Text(state.currentChord)
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundStyle(Wise.contentPrimary)
                                    .frame(maxWidth: .infinity)

                                // 힌트 텍스트
                                Text(state.hintText.isEmpty ? " " : state.hintText)
                                    .font(.system(size: 13))
                                    .foregroundStyle(Wise.contentSecondary)
                                    .frame(maxWidth: .infinity, minHeight: 20)

                                // 지판 다이어그램
                                if state.showFretboard, let card = state.currentCard {
                                    FretboardDiagramView(card: card)
                                        .frame(maxWidth: 280)
                                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                                }

                                Divider()
                                    .overlay(Wise.borderNeutral)

                                // 컨트롤 행
                                HStack(spacing: Wise.sp12) {
                                    WiseSwitch(isOn: hintBinding, label: "힌트")

                                    Button("다음 코드") {
                                        state.onNextCardTapped(hintOn: appState.hintOn)
                                    }
                                    .buttonStyle(PrimaryButtonStyle())

                                    shuffleButton
                                }
                            }
                            .padding(Wise.sp24)
                        }
                        .wiseCard()
                        .padding(.horizontal, Wise.sp24)
                    }
                    .padding(.bottom, Wise.sp32)
                }
            }
        }
        .preferredColorScheme(.light)
        .onAppear { state.onAppear(hintOn: appState.hintOn) }
        .onDisappear { state.onDisappear() }
        .animation(.easeInOut(duration: 0.2), value: state.showFretboard)
        // ── 키보드 단축키 (iOS 26.4, onKeyPress 직접 지원) ──
        .onKeyPress(keys: [.init("h"), .init("H")]) { _ in
            appState.hintOn.toggle()
            state.toggleHint(hintOn: appState.hintOn)
            return .handled
        }
        .onKeyPress(keys: [.init("n"), .init("N"), .return]) { _ in
            state.onNextCardTapped(hintOn: appState.hintOn)
            return .handled
        }
    }

    // MARK: - Hint binding (WiseSwitch ↔ AppState)

    private var hintBinding: Binding<Bool> {
        Binding(
            get: { appState.hintOn },
            set: { newVal in
                appState.hintOn = newVal
                state.toggleHint(hintOn: newVal)
            }
        )
    }

    // MARK: - Shuffle button (§6.3 스타일 전환)

    @ViewBuilder
    private var shuffleButton: some View {
        if state.isShuffling {
            Button("셔플 종료 (\(state.shuffleCount))") {
                state.stopShuffle()
            }
            .buttonStyle(PrimaryButtonStyle())
        } else {
            Button("셔플 시작") {
                state.startShuffle(hintOn: appState.hintOn)
            }
            .buttonStyle(SecondaryButtonStyle())
        }
    }
}

// MARK: - Preview

#Preview {
    PriorityView()
        .environmentObject(AppState())
}
