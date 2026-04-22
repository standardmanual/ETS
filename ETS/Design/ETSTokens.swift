//
//  ETSTokens.swift
//  ETS
//
//  Created by Claude on 2026-04-22.
//

import SwiftUI

// MARK: - Hex colour initialiser (defined once, visible across the whole target)

extension Color {
    init(hex: String) {
        let raw = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: raw).scanHexInt64(&value)
        let a, r, g, b: UInt64
        switch raw.count {
        case 3:
            (a, r, g, b) = (255,
                            (value >> 8) * 17,
                            (value >> 4 & 0xF) * 17,
                            (value & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255,
                            value >> 16,
                            value >> 8 & 0xFF,
                            value & 0xFF)
        case 8:
            (a, r, g, b) = (value >> 24,
                            value >> 16 & 0xFF,
                            value >> 8  & 0xFF,
                            value & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red:     Double(r) / 255,
            green:   Double(g) / 255,
            blue:    Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - ETS dark-green theme (Metronome tab)

struct ETS {
    static let bgDeep     = Color(hex: "#1a2421")
    static let bgCard     = Color(hex: "#1e2e28")
    static let greenDeep  = Color(hex: "#2a6b4a")
    static let greenDark  = Color(hex: "#3a8a5c")
    static let greenMid   = Color(hex: "#52a872")
    static let greenLight = Color(hex: "#72c492")
    static let greenPale  = Color(hex: "#b5e6c8")
    static let white      = Color.white

    static let rPill: CGFloat = 24
    static let tap:   CGFloat = 44
}
