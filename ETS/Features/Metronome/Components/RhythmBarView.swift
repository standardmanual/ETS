//
//  RhythmBarView.swift
//  ETS
//
//  Created by Claude on 2026-04-22.
//

import SwiftUI

// MARK: - RhythmBarView
// SVG viewBox 400×72 악보를 SwiftUI Canvas로 렌더링.
// drawLayer로 음표마다 독립 transform → -15도 회전 누적 오류 없음 (v3.1 수정).

struct RhythmBarView: View {
    let patternIndex: Int
    let isActive: Bool

    var body: some View {
        Canvas { ctx, size in
            let sx = size.width  / 400.0
            let sy = size.height / 72.0
            let noteShading = GraphicsContext.Shading.color(Color(hex: "#111827"))

            // 1. 오선 5줄 (y: 18, 27, 36, 45, 54)
            for i in 0..<5 {
                let y = (18.0 + Double(i) * 9.0) * sy
                var line = Path()
                line.move(to:    .init(x: 0,          y: y))
                line.addLine(to: .init(x: size.width, y: y))
                ctx.stroke(line, with: noteShading, lineWidth: 1.5 * sy)
            }

            guard let pat = RHYTHM_PATTERNS[patternIndex] else { return }

            let beatXs: [Double] = [40, 120, 200, 280]

            for bx in beatXs {
                // 2. 음표 (음표머리 + 줄기 + 점음표)
                for (idx, ox) in pat.noteOffsets.enumerated() {
                    let nx = (bx + Double(ox)) * sx
                    let ny = 49.5 * sy
                    let stemX = nx + 6.0 * sx

                    // 음표머리: drawLayer로 독립 transform (-15도 회전)
                    ctx.drawLayer { layerCtx in
                        layerCtx.transform = CGAffineTransform(translationX: nx, y: ny)
                            .rotated(by: -15.0 * .pi / 180.0)
                            .translatedBy(x: -nx, y: -ny)
                        let head = Path(ellipseIn: CGRect(
                            x: nx - 7.5 * sx, y: ny - 5.5 * sy,
                            width: 15.0 * sx, height: 11.0 * sy
                        ))
                        layerCtx.fill(head, with: noteShading)
                    }

                    // 줄기
                    var stem = Path()
                    stem.move(to:    .init(x: stemX, y: ny))
                    stem.addLine(to: .init(x: stemX, y: 21.0 * sy))
                    ctx.stroke(stem, with: noteShading, lineWidth: 2.0 * sx)

                    // 점음표
                    if pat.dottedIndices.contains(idx) {
                        let dot = Path(ellipseIn: CGRect(
                            x: (nx + 15.0 * sx) - 2.5 * sx,
                            y: ny - 2.5 * sy,
                            width: 5.0 * sx, height: 5.0 * sy
                        ))
                        ctx.fill(dot, with: noteShading)
                    }
                }

                // 3. 빔 (beam bar)
                for beam in pat.beams {
                    let startX = (bx + Double(beam[0]) + 6.0) * sx
                    let endX   = (bx + Double(beam[1]) + 6.0) * sx
                    let y      = (21.0 + Double(beam[2]) * 5.4) * sy
                    ctx.fill(
                        Path(CGRect(x: startX, y: y, width: endX - startX, height: 4.5 * sy)),
                        with: noteShading
                    )
                }
            }
        }
        .aspectRatio(400.0 / 72.0, contentMode: .fit)
        .background(isActive ? ETS.greenMid.opacity(0.18) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(isActive ? ETS.greenMid : Color.clear, lineWidth: 1.5)
        )
        .animation(.easeInOut(duration: 0.15), value: isActive)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 8) {
        ForEach(1...8, id: \.self) { i in
            HStack {
                Text("\(i)")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(ETS.greenPale)
                    .frame(width: 16)
                RhythmBarView(patternIndex: i, isActive: i == 3)
            }
        }
    }
    .padding()
    .background(ETS.bgDeep)
}
