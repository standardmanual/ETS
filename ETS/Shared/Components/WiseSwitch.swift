//
//  WiseSwitch.swift
//  ETS
//
//  Created by Claude on 2026-04-22.
//

import SwiftUI

// MARK: - WiseSwitch
// 48×28pt track, 22pt white knob, 0.2s spring animation.
// On:  Wise.interactivePrimary (#163300) track.
// Off: Wise.borderNeutral track.

struct WiseSwitch: View {
    @Binding var isOn: Bool
    let label: String

    private let trackW:   CGFloat = 48
    private let trackH:   CGFloat = 28
    private let knobSize: CGFloat = 22
    private let knobPad:  CGFloat = 3   // gap from track edge

    private var knobOffset: CGFloat {
        let travel = trackW / 2 - knobSize / 2 - knobPad
        return isOn ? travel : -travel
    }

    var body: some View {
        Button(action: { isOn.toggle() }) {
            HStack(spacing: Wise.sp8) {
                Text(label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Wise.contentPrimary)

                ZStack {
                    Capsule()
                        .fill(isOn ? Wise.interactivePrimary : Wise.borderNeutral)
                        .frame(width: trackW, height: trackH)

                    Circle()
                        .fill(Color.white)
                        .frame(width: knobSize, height: knobSize)
                        .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)
                        .offset(x: knobOffset)
                }
                .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isOn)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var on1 = true
    @Previewable @State var on2 = false

    VStack(spacing: 24) {
        WiseSwitch(isOn: $on1, label: "힌트")
        WiseSwitch(isOn: $on2, label: "힌트")
    }
    .padding()
}
