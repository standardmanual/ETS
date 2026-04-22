//
//  WiseTokens.swift
//  ETS
//
//  Created by Claude on 2026-04-22.
//

import SwiftUI

// Color(hex:) is defined in ETSTokens.swift and shared across the target.

// MARK: - Wise light theme (Priority + Tones tabs)

struct Wise {
    // Colours
    static let interactivePrimary = Color(hex: "#163300")
    static let interactiveAccent  = Color(hex: "#9FE870")
    static let contentPrimary     = Color(hex: "#0E0F0C")
    static let contentSecondary   = Color(hex: "#454745")
    static let contentTertiary    = Color(hex: "#6A6C6A")
    static let bgScreen           = Color.white
    static let bgNeutral          = Color(hex: "#163300").opacity(0.08)
    static let borderNeutral      = Color(hex: "#0E0F0C").opacity(0.12)
    static let sentimentPositive  = Color(hex: "#2F5711")
    static let sentimentNegative  = Color(hex: "#A8200D")

    // Corner radii
    static let rSM:   CGFloat = 10
    static let rMD:   CGFloat = 16
    static let rLG:   CGFloat = 24
    static let rPill: CGFloat = 999

    // Spacing
    static let sp4:  CGFloat = 4
    static let sp8:  CGFloat = 8
    static let sp12: CGFloat = 12
    static let sp16: CGFloat = 16
    static let sp24: CGFloat = 24
    static let sp32: CGFloat = 32

    // Tap target
    static let tap: CGFloat = 44
}
