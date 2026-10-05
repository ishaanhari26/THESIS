import SwiftUI

// MARK: - Icons
// The web app drew its own stroke icons; these are the closest SF Symbols.

enum ThesisIcon: String {
    case home = "house"
    case search = "magnifyingglass"
    case spark = "sparkles"
    case users = "person.2"
    case pie = "chart.pie"
    case bell = "bell"
    case arrow = "arrow.right"
    case back = "chevron.left"
    case up = "chevron.up"
    case down = "chevron.down"
    case news = "newspaper"
    case check = "checkmark"
    case bank = "building.columns"
    case wallet = "wallet.bifold"
    case card = "creditcard"
    case clock = "clock"
    case shield = "checkmark.shield"
    case edit = "pencil"
    case more = "ellipsis"
    case send = "paperplane"
    case play = "play.circle"
}

struct Icon: View {
    let name: ThesisIcon
    var size: CGFloat = 20
    var weight: Font.Weight = .medium

    init(_ name: ThesisIcon, size: CGFloat = 20, weight: Font.Weight = .medium) {
        self.name = name
        self.size = size
        self.weight = weight
    }

    var body: some View {
        Image(systemName: name.rawValue)
            .font(.system(size: size * 0.8, weight: weight))
            .frame(width: size, height: size)
    }
}

// MARK: - SVG path shape
// Lets the chart paths from the web prototype be pasted in verbatim.
// Supports M L H V C S Z (absolute and relative). Scales non-uniformly to fill
// its frame, matching the SVGs' preserveAspectRatio="none".

struct SVGPath: Shape {
    let d: String
    let viewBox: CGSize

    init(_ d: String, viewBox: CGSize) {
        self.d = d
        self.viewBox = viewBox
    }

    func path(in rect: CGRect) -> Path {
        let transform = CGAffineTransform(translationX: rect.minX, y: rect.minY)
            .scaledBy(x: rect.width / viewBox.width, y: rect.height / viewBox.height)
        return SVGPathParser.parse(d).applying(transform)
    }
}

enum SVGPathParser {
    private enum Token {
        case command(Character)
        case number(CGFloat)
    }

    static func parse(_ d: String) -> Path {
        let tokens = tokenize(d)
        var path = Path()
        var i = 0
        var command: Character = "M"
        var current = CGPoint.zero
        var subpathStart = CGPoint.zero
        var lastControl: CGPoint?

        func next() -> CGFloat {
            defer { i += 1 }
            guard i < tokens.count, case let .number(value) = tokens[i] else { return 0 }
            return value
        }

        while i < tokens.count {
            if case let .command(c) = tokens[i] {
                command = c
                i += 1
            }
            let relative = command.isLowercase
            let base = relative ? current : .zero

            switch command {
            case "M", "m":
                let p = CGPoint(x: base.x + next(), y: base.y + next())
                path.move(to: p)
                current = p
                subpathStart = p
                lastControl = nil
                command = relative ? "l" : "L" // extra coordinate pairs are implicit line-tos
            case "L", "l":
                let p = CGPoint(x: base.x + next(), y: base.y + next())
                path.addLine(to: p)
                current = p
                lastControl = nil
            case "H", "h":
                current.x = (relative ? current.x : 0) + next()
                path.addLine(to: current)
                lastControl = nil
            case "V", "v":
                current.y = (relative ? current.y : 0) + next()
                path.addLine(to: current)
                lastControl = nil
            case "C", "c":
                let c1 = CGPoint(x: base.x + next(), y: base.y + next())
                let c2 = CGPoint(x: base.x + next(), y: base.y + next())
                let p = CGPoint(x: base.x + next(), y: base.y + next())
                path.addCurve(to: p, control1: c1, control2: c2)
                lastControl = c2
                current = p
            case "S", "s":
                let c1 = lastControl.map { CGPoint(x: 2 * current.x - $0.x, y: 2 * current.y - $0.y) } ?? current
                let c2 = CGPoint(x: base.x + next(), y: base.y + next())
                let p = CGPoint(x: base.x + next(), y: base.y + next())
                path.addCurve(to: p, control1: c1, control2: c2)
                lastControl = c2
                current = p
            case "Z", "z":
                path.closeSubpath()
                current = subpathStart
                lastControl = nil
                // Guard against stray numbers after Z so the loop always advances.
                if i < tokens.count, case .number = tokens[i] { i += 1 }
            default:
                i += 1
            }
        }
        return path
    }

    private static func tokenize(_ d: String) -> [Token] {
        var tokens: [Token] = []
        var buffer = ""

        func flush() {
            if let value = Double(buffer) { tokens.append(.number(CGFloat(value))) }
            buffer = ""
        }

        for ch in d {
            if ch.isLetter, ch != "e", ch != "E" {
                flush()
                tokens.append(.command(ch))
            } else if ch == "-" {
                if !buffer.isEmpty, buffer.last != "e", buffer.last != "E" { flush() }
                buffer.append(ch)
            } else if ch == "." {
                if buffer.contains(".") { flush() }
                buffer.append(ch)
            } else if ch.isNumber || ch == "e" || ch == "E" {
                buffer.append(ch)
            } else {
                flush() // whitespace or comma
            }
        }
        flush()
        return tokens
    }
}

// MARK: - Charts

/// The NVIDIA price chart used on Discover, Stock, and Portfolio.
struct PriceChart: View {
    var height: CGFloat = 125

    private static let viewBox = CGSize(width: 360, height: 125)
    private static let line = "M0 103 C18 98 24 104 40 95 S70 85 86 90 S112 74 126 78 S154 57 170 65 S196 47 212 53 S232 45 247 48 S272 28 286 35 S310 18 326 24 S345 10 360 13"

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                SVGPath("M0 25h360M0 65h360M0 105h360", viewBox: Self.viewBox)
                    .stroke(Theme.hairline, lineWidth: 1)
                SVGPath(Self.line + " V125 H0Z", viewBox: Self.viewBox)
                    .fill(LinearGradient(
                        colors: [Theme.green2.opacity(0.2), Theme.green2.opacity(0)],
                        startPoint: .top, endPoint: .bottom
                    ))
                SVGPath(Self.line, viewBox: Self.viewBox)
                    .stroke(Theme.green2, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                Circle()
                    .fill(.white)
                    .overlay(Circle().stroke(Theme.green2, lineWidth: 2))
                    .frame(width: 9, height: 9)
                    .position(x: geo.size.width - 1, y: geo.size.height * 13 / 125)
            }
        }
        .frame(height: height)
        .accessibilityLabel("NVIDIA one week price chart")
    }
}

/// Small trend line used in stock rows and positions.
struct Sparkline: View {
    let down: Bool
    var width: CGFloat = 62
    var compact = false // the slightly different paths used by StockSim positions

    private var pathData: String {
        if compact {
            return down ? "M1 6 C13 4 19 16 29 12 S45 17 57 20" : "M1 20 C12 16 18 19 28 11 S43 13 57 4"
        }
        return down ? "M1 7 C18 3 22 18 36 13 S55 17 69 21" : "M1 20 C15 17 20 19 32 12 S51 14 69 4"
    }

    private var box: CGSize {
        compact ? CGSize(width: 58, height: 24) : CGSize(width: 70, height: 25)
    }

    var body: some View {
        SVGPath(pathData, viewBox: box)
            .stroke(down ? Theme.red : Theme.green2, style: StrokeStyle(lineWidth: 1.7, lineCap: .round))
            .frame(width: width, height: width * box.height / box.width)
    }
}

/// Ring progress (risk donut and StockSim mission ring).
struct RingProgress: View {
    let progress: CGFloat
    var lineWidth: CGFloat
    var track: Color
    var fill: Color = Theme.green

    var body: some View {
        ZStack {
            Circle().stroke(track, lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(fill, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .padding(lineWidth / 2)
    }
}

/// The faint concentric circles decorating the dark hero cards.
struct DecorRings: View {
    var diameter: CGFloat = 180
    var opacity: Double = 0.13
    var spread = true

    var body: some View {
        ZStack {
            if spread {
                Circle().stroke(Color.white.opacity(0.024), lineWidth: 22).frame(width: diameter + 66, height: diameter + 66)
                Circle().stroke(Color.white.opacity(0.03), lineWidth: 22).frame(width: diameter + 22, height: diameter + 22)
            }
            Circle().stroke(Color.white.opacity(opacity), lineWidth: 1).frame(width: diameter, height: diameter)
        }
        .frame(width: diameter, height: diameter)
        .allowsHitTesting(false)
    }
}
