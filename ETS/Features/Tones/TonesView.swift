//
//  TonesView.swift
//  ETS
//
//  Created by Claude on 2026-04-22.
//

import SwiftUI

// MARK: - TonesView (PRD §7.1)

struct TonesView: View {
    @StateObject private var state = TonesState()

    var body: some View {
        ZStack {
            Wise.bgScreen.ignoresSafeArea()

            VStack(spacing: 0) {
                // ── PageHeader ──
                VStack(alignment: .leading, spacing: 4) {
                    Text("코드암기")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Wise.contentPrimary)
                    Text("코드를 보고 구성음 3개를 선택하세요")
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
                            Text("코드 구성음 퀴즈")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Wise.contentSecondary)

                            VStack(spacing: Wise.sp16) {
                                // 코드명
                                Text(prettyChordLabel(state.currentChord))
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundStyle(Wise.contentPrimary)
                                    .frame(maxWidth: .infinity)
                                    .animation(.easeInOut(duration: 0.15), value: state.currentChord)

                                // 결과 텍스트
                                Text(state.resultText.isEmpty ? " " : state.resultText)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(state.resultColor)
                                    .frame(maxWidth: .infinity, minHeight: 20)
                                    .animation(.easeInOut(duration: 0.15), value: state.resultText)

                                // 노트 칩 그리드
                                NoteChipGrid(state: state)

                                // 컨트롤 행
                                HStack(spacing: Wise.sp12) {
                                    Button("정답확인") {
                                        state.checkAnswer()
                                    }
                                    .buttonStyle(PrimaryButtonStyle())

                                    Button("다음 문제") {
                                        state.nextQuestion()
                                    }
                                    .buttonStyle(SecondaryButtonStyle())
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
        .onAppear { state.nextQuestion() }
    }
}

// MARK: - Preview

#Preview {
    TonesView()
}
