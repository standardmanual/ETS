//
//  BtnSecondary.swift
//  ETS
//
//  Created by Claude on 2026-04-22.
//

import SwiftUI

// MARK: - SecondaryButtonStyle
// Transparent background, interactivePrimary (#163300) border + text, pill shape.
// Used for inactive shuffle ("셔플 시작") and secondary actions.

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(Wise.interactivePrimary)
            .frame(maxWidth: .infinity, minHeight: Wise.tap)
            .padding(.horizontal, Wise.sp16)
            .background(Color.clear)
            .overlay(
                Capsule()
                    .stroke(Wise.interactivePrimary, lineWidth: 1.5)
            )
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        Button("셔플 시작") {}
            .buttonStyle(SecondaryButtonStyle())
        Button("정답확인") {}
            .buttonStyle(SecondaryButtonStyle())
    }
    .padding()
}
