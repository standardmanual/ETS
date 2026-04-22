//
//  WiseCard.swift
//  ETS
//
//  Created by Claude on 2026-04-22.
//

import SwiftUI

// MARK: - WiseCardModifier

struct WiseCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Wise.bgScreen)
            .clipShape(RoundedRectangle(cornerRadius: Wise.rLG))
            .overlay(
                RoundedRectangle(cornerRadius: Wise.rLG)
                    .stroke(Wise.borderNeutral, lineWidth: 1)
            )
    }
}

extension View {
    func wiseCard() -> some View {
        modifier(WiseCardModifier())
    }
}

// MARK: - Preview

#Preview {
    VStack(alignment: .leading, spacing: Wise.sp16) {
        Text("코드 플래시카드")
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(Wise.contentSecondary)
        Text("Am")
            .font(.system(size: 40, weight: .bold))
            .foregroundStyle(Wise.contentPrimary)
            .frame(maxWidth: .infinity)
    }
    .padding(Wise.sp24)
    .wiseCard()
    .padding()
    .background(Wise.bgNeutral)
}
