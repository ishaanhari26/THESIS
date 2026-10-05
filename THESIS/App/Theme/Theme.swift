import SwiftUI

// MARK: - Design tokens (ported from index.css :root)

enum Theme {
    // Core palette
    static let ink = Color(hex: 0x142A29)
    static let muted = Color(hex: 0x647472)
    static let green = Color(hex: 0x176D61)
    static let green2 = Color(hex: 0x238775)
    static let mint = Color(hex: 0xDCEEE9)
    static let pale = Color(hex: 0xF1F6F3)
    static let line = Color(hex: 0xDCE5E1)
    static let gold = Color(hex: 0xC89846)
    static let red = Color(hex: 0xB75A55)
    static let paper = Color(hex: 0xFBFCFA)

    // Frequently reused secondary colors
    static let hairline = Color(hex: 0xEDF1EF)
    static let segmentTrack = Color(hex: 0xE9EFEC)
    static let tealCard = Color(hex: 0x285B55)
    static let goldText = Color(hex: 0x8E6A2B)

    /// The web prototype uses 7–12px text, which is below Apple's legibility guidance on iPhone.
    /// Every size under 18 gets this many points added. Set to 0 for a 1:1 port of the web sizes.
    static let textBoost: CGFloat = 2

    static func scaled(_ px: CGFloat) -> CGFloat { px < 18 ? px + textBoost : px }

    /// Body text — DM Sans (falls back to the system font if the font files aren't bundled).
    static func body(_ px: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        .custom("DM Sans", size: scaled(px), relativeTo: .body).weight(weight)
    }

    /// Headings, prices, and the logo — Manrope.
    static func display(_ px: CGFloat, _ weight: Font.Weight = .bold) -> Font {
        .custom("Manrope", size: scaled(px), relativeTo: .title).weight(weight)
    }

    /// CSS letter-spacing in em → SwiftUI tracking in points.
    static func tracking(_ em: CGFloat, _ px: CGFloat) -> CGFloat { em * scaled(px) }
}

// MARK: - Color helpers

extension Color {
    /// `Color(hex: 0x176D61)` or `Color(hex: 0xFFFFFF, alpha: 0.12)`
    init(hex: UInt32, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}

// MARK: - View helpers

extension View {
    /// Rounded card with optional 1pt border — the most common surface in the design.
    func card(radius: CGFloat = 14, fill: Color = .white, stroke: Color? = Theme.line, lineWidth: CGFloat = 1) -> some View {
        background(RoundedRectangle(cornerRadius: radius, style: .continuous).fill(fill))
            .overlay {
                if let stroke {
                    RoundedRectangle(cornerRadius: radius, style: .continuous)
                        .strokeBorder(stroke, lineWidth: lineWidth)
                }
            }
    }

    /// Dashed-border card (the "Add a payment method" row).
    func dashedCard(radius: CGFloat = 12, stroke: Color = Color(hex: 0xB7C5C1)) -> some View {
        overlay(
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .strokeBorder(stroke, style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
        )
    }

    /// Extends a view past the screen's 20pt side padding (CSS `margin: 0 -20px`).
    func fullBleed(_ inset: CGFloat = 20) -> some View {
        padding(.horizontal, -inset)
    }

    /// Bottom hairline used by list rows.
    func rowDivider(_ show: Bool = true, color: Color = Theme.hairline) -> some View {
        overlay(alignment: .bottom) {
            if show { Rectangle().fill(color).frame(height: 1) }
        }
    }

    /// Top hairline used by footers and table rows.
    func topDivider(_ color: Color = Theme.line) -> some View {
        overlay(alignment: .top) { Rectangle().fill(color).frame(height: 1) }
    }
}
