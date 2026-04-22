//
//  BeatDotView.swift
//  ETS
//
//  Created by Claude on 2026-04-22.
//

import SwiftUI

// MARK: - BeatDotView
// 3레이어 구조: beat-glow (fill+scale) / beat-ripple (stroke+radius) / beat-core (메인원)
// PRD §5.2 — guitar.html CSS 111~127행 재현

struct BeatDotView: View {
    let isAccent: Bool    // true: 강박 (index == 0)
    let isActive: Bool    // true: 현재 박 하이라이트
    let isFade:   Bool    // true: 방금 지나간 박

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var glowScale:     CGFloat = 0.85
    @State private var glowOpacity:   Double  = 0.0
    @State private var rippleRadius:  CGFloat = 16
    @State private var rippleOpacity: Double  = 0.0
    @State private var rippleStroke:  CGFloat = 3

    private var activeColor: Color {
        isAccent ? ETS.greenMid : ETS.greenLight
    }

    var body: some View {
        ZStack {
            // Layer 1: beat-glow (fill, scale 애니메이션)
            Circle()
                .fill(activeColor)
                .frame(width: 36, height: 36)
                .scaleEffect(glowScale)
                .opacity(glowOpacity)

            // Layer 2: beat-ripple (stroke, 반지름 확장 애니메이션)
            Circle()
                .stroke(activeColor, lineWidth: rippleStroke)
                .frame(width: rippleRadius * 2, height: rippleRadius * 2)
                .opacity(rippleOpacity)

            // Layer 3: beat-core (메인 원, 상태에 따라 fill 변경)
            Circle()
                .fill(isActive ? activeColor : Color.white.opacity(0.15))
                .overlay(
                    Circle().stroke(
                        isActive ? activeColor : Color.white.opacity(0.15),
                        lineWidth: 1.5
                    )
                )
                .frame(width: 32, height: 32)
                .animation(.easeInOut(duration: isFade ? 0.25 : 0.06), value: isActive)
        }
        .frame(width: 48, height: 48)
        .onChange(of: isActive) { _, active in
            guard active, !reduceMotion else { return }
            // beatGlow: scale .85→1.05→1, opacity .9→.5→0, duration 0.55s
            glowScale = 0.85; glowOpacity = 0.9
            withAnimation(.easeOut(duration: 0.22)) {
                glowScale = 1.05; glowOpacity = 0.5
            }
            withAnimation(.easeOut(duration: 0.33).delay(0.22)) {
                glowScale = 1.0; glowOpacity = 0
            }
            // beatRipple: r 16→34, strokeWidth 3→0.5, opacity .8→0, duration 0.55s
            rippleRadius = 16; rippleStroke = 3; rippleOpacity = 0.8
            withAnimation(.easeOut(duration: 0.55)) {
                rippleRadius = 34; rippleStroke = 0.5; rippleOpacity = 0
            }
        }
    }
}

// MARK: - Preview

#Preview {
    HStack(spacing: 12) {
        BeatDotView(isAccent: true,  isActive: true,  isFade: false)
        BeatDotView(isAccent: false, isActive: false, isFade: true)
        BeatDotView(isAccent: false, isActive: false, isFade: false)
        BeatDotView(isAccent: false, isActive: false, isFade: false)
    }
    .padding()
    .background(ETS.bgDeep)
}
