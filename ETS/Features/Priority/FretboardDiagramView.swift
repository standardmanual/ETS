//
//  FretboardDiagramView.swift
//  ETS
//
//  Created by Claude on 2026-04-22.
//

import SwiftUI

// MARK: - FretboardDiagramView
// Canvas 지판 다이어그램. PRD §6.7 렌더링 파라미터 준수.

struct FretboardDiagramView: View {
    let card: GuitarCard

    // viewBox 440 × 190
    private let vbW: Double = 440
    private let vbH: Double = 190
    private let padX: Double = 40
    private let padY: Double = 20
    private let strSpacing: Double = 22
    private let fretWidth:  Double = 84

    private var shapeKey: String { makeShapeKey(for: card) }
    private var dots: [FretDot] { SHAPE_DOTS[shapeKey] ?? [] }

    // 시작 프렛 wire (baseFretNum ≤ 1 → 0, 아니면 baseFretNum - 1)
    private var startWire: Int { card.baseFretNum <= 1 ? 0 : card.baseFretNum - 1 }

    // 포지션 마커 프렛
    private let markerFrets: Set<Int> = [3, 5, 7, 9, 15, 17, 19]
    private let doubleMarkerFrets: Set<Int> = [12]

    var body: some View {
        Canvas { ctx, size in
            let sx = size.width  / vbW
            let sy = size.height / vbH

            // ── 줄 (6개) ──
            for s in 1...6 {
                let y = (padY + Double(s - 1) * strSpacing) * sy
                let thickness = (1.0 + Double(s - 1) * 0.2) * sy
                var line = Path()
                line.move(to:    .init(x: padX * sx, y: y))
                line.addLine(to: .init(x: (padX + fretWidth * 4) * sx, y: y))
                ctx.stroke(line, with: .color(Color(hex: "#4b5563")), lineWidth: thickness)
            }

            // ── 프렛 (5개) ──
            for i in 0..<5 {
                let x = (padX + Double(i) * fretWidth) * sx
                let wire = startWire + i
                let isNut = (wire == 0)

                var fret = Path()
                fret.move(to:    .init(x: x, y: padY * sy))
                fret.addLine(to: .init(x: x, y: (padY + 5 * strSpacing) * sy))
                let color: Color = isNut ? Color(hex: "#111827") : Color(hex: "#9ca3af")
                let lw:   CGFloat = isNut ? 6 * sx : 2 * sx
                ctx.stroke(fret, with: .color(color), lineWidth: lw)

                // 프렛 번호 (i==1, wire>0)
                if i == 1 && wire > 0 {
                    let txtY = (padY + 5.5 * strSpacing + 30) * sy
                    ctx.draw(
                        Text("\(wire)프렛")
                            .font(.system(size: 11 * sx, weight: .medium))
                            .foregroundStyle(Color(hex: "#6b7280")),
                        at: .init(x: x, y: txtY)
                    )
                }
            }

            // ── 포지션 마커 ──
            for i in 0..<4 {
                let wire = startWire + i
                let markerX = (padX + (Double(i) + 0.5) * fretWidth) * sx
                if markerFrets.contains(wire) {
                    let y = (padY + 2.5 * strSpacing) * sy
                    ctx.fill(
                        Path(ellipseIn: CGRect(x: markerX - 5 * sx, y: y - 5 * sy,
                                               width: 10 * sx, height: 10 * sy)),
                        with: .color(Color(hex: "#e5e7eb"))
                    )
                }
                if doubleMarkerFrets.contains(wire) {
                    for yFrac in [1.5, 3.5] {
                        let y = (padY + yFrac * strSpacing) * sy
                        ctx.fill(
                            Path(ellipseIn: CGRect(x: markerX - 5 * sx, y: y - 5 * sy,
                                                   width: 10 * sx, height: 10 * sy)),
                            with: .color(Color(hex: "#e5e7eb"))
                        )
                    }
                }
            }

            // ── 바레 (baseFret > 0) ──
            if card.baseFretNum > 0 {
                let barre = barre(for: card.form, sx: sx, sy: sy)
                ctx.fill(barre, with: .color(Color(hex: "#1e88e5").opacity(0.4)))
            }

            // ── 운지 점 ──
            for dot in dots {
                let absFret = dot.f   // 폼 내 상대 프렛
                let colIdx  = absFret  // fret column in view (0-based from startWire)
                let stringIdx = dot.s - 1   // 0-based (0 = 6번줄 thick)

                if absFret == 0 {
                    // 오픈현: hollow circle at padX - 16
                    let x = (padX - 16) * sx
                    let y = (padY + Double(stringIdx) * strSpacing) * sy
                    var circle = Path()
                    circle.addEllipse(in: CGRect(x: x - 4.5 * sx, y: y - 4.5 * sy,
                                                 width: 9 * sx, height: 9 * sy))
                    ctx.stroke(circle, with: .color(dot.r ? Color(hex: "#ef4444") : Color(hex: "#1e88e5")),
                               lineWidth: 1.5 * sx)
                } else {
                    let fretCol = Double(colIdx) - 0.5
                    let x = (padX + fretCol * fretWidth) * sx
                    let y = (padY + Double(stringIdx) * strSpacing) * sy
                    if dot.r {
                        // 루트: 빨간 + outer ring
                        ctx.fill(
                            Path(ellipseIn: CGRect(x: x - 8 * sx, y: y - 8 * sy,
                                                   width: 16 * sx, height: 16 * sy)),
                            with: .color(Color(hex: "#ef4444"))
                        )
                        var ring = Path()
                        ring.addEllipse(in: CGRect(x: x - 10 * sx, y: y - 10 * sy,
                                                   width: 20 * sx, height: 20 * sy))
                        ctx.stroke(ring, with: .color(Color(hex: "#ef4444")), lineWidth: 2 * sx)
                    } else {
                        // 비루트: 파란
                        ctx.fill(
                            Path(ellipseIn: CGRect(x: x - 8 * sx, y: y - 8 * sy,
                                                   width: 16 * sx, height: 16 * sy)),
                            with: .color(Color(hex: "#1e88e5"))
                        )
                    }
                }
            }

            // ── 뮤트 ×표 ──
            for s in mutedStrings(for: card.form) {
                let stringIdx = s - 1
                let x = (padX - 20) * sx
                let y = (padY + Double(stringIdx) * strSpacing) * sy
                var cross = Path()
                cross.move(to:    .init(x: x - 4 * sx, y: y - 4 * sy))
                cross.addLine(to: .init(x: x + 4 * sx, y: y + 4 * sy))
                cross.move(to:    .init(x: x + 4 * sx, y: y - 4 * sy))
                cross.addLine(to: .init(x: x - 4 * sx, y: y + 4 * sy))
                ctx.stroke(cross, with: .color(Color(hex: "#ef4444")), lineWidth: 1.5 * sx)
            }
        }
        .aspectRatio(vbW / vbH, contentMode: .fit)
    }

    // MARK: - Helpers

    private func barre(for form: String, sx: CGFloat, sy: CGFloat) -> Path {
        let prefix = String(form.prefix(1))
        let (sMin, sMax): (Int, Int)
        switch prefix {
        case "E": (sMin, sMax) = (1, 6)
        case "A", "C": (sMin, sMax) = (1, 5)
        case "D": (sMin, sMax) = (1, 4)
        default:  (sMin, sMax) = (1, 6)
        }
        let x  = padX * sx
        let y1 = (padY + Double(6 - sMax) * strSpacing - 6) * sy
        let y2 = (padY + Double(6 - sMin) * strSpacing + 6) * sy
        return Path(CGRect(x: x - 6 * sx, y: y1, width: 12 * sx, height: y2 - y1))
    }

    private func mutedStrings(for form: String) -> [Int] {
        let prefix = String(form.prefix(1))
        switch prefix {
        case "A", "C": return [6]      // 6번줄 뮤트
        case "D":      return [5, 6]   // 5·6번줄 뮤트
        default:       return []
        }
    }
}

// MARK: - Preview

#Preview {
    let card = PRIORITY_CARDS.first { $0.chord == "Am" }!
    FretboardDiagramView(card: card)
        .frame(width: 220)
        .padding()
}
