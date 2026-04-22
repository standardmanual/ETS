//
//  KbdHint.swift
//  ETS
//
//  Created by Claude on 2026-04-22.
//

import SwiftUI

// MARK: - KbdHint
// Displays a small keyboard shortcut badge (e.g. "H", "ENTER", "SPACE").
// Hidden on screens with width ≤ 768pt (i.e. iPhone / compact split-view).
// Uses horizontalSizeClass .regular as the proxy for "large screen" —
// this covers all iPad configurations with full-width layout.

struct KbdHint: View {
    let label: String

    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        if sizeClass == .regular {
            Text(label)
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundStyle(Wise.contentSecondary)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Wise.bgNeutral)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Wise.borderNeutral, lineWidth: 1)
                )
        }
    }
}

// MARK: - Preview

#Preview("iPad — visible") {
    HStack(spacing: 8) {
        Text("힌트 토글")
            .font(.system(size: 14))
            .foregroundStyle(Wise.contentPrimary)
        KbdHint(label: "H")
    }
    .padding()
    .environment(\.horizontalSizeClass, .regular)
}

#Preview("iPhone — hidden") {
    HStack(spacing: 8) {
        Text("힌트 토글")
            .font(.system(size: 14))
            .foregroundStyle(Wise.contentPrimary)
        KbdHint(label: "H")
    }
    .padding()
    .environment(\.horizontalSizeClass, .compact)
}
