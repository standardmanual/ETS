//
//  BtnPrimary.swift
//  ETS
//
//  Created by Claude on 2026-04-22.
//

import SwiftUI

// MARK: - PrimaryButtonStyle
// Accent (#9FE870) background, interactivePrimary (#163300) text, pill shape.
// Used for main actions ("다음 코드") and active shuffle button.

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(Wise.interactivePrimary)
            .frame(maxWidth: .infinity, minHeight: Wise.tap)
            .padding(.horizontal, Wise.sp16)
            .background(Wise.interactiveAccent)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        Button("다음 코드") {}
            .buttonStyle(PrimaryButtonStyle())
        Button("셔플 종료 (8)") {}
            .buttonStyle(PrimaryButtonStyle())
    }
    .padding()
}
