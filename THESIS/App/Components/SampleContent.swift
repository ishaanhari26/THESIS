import SwiftUI

// Hardcoded display content copied from the prototype. These are plain value lists so
// the screens can render — not app models. Replace them when you add real data.

struct LessonItem: Hashable {
    let title: String
    let category: String
    let time: String
    let level: String
    let thumbColor: Color
}

let sampleLessons: [LessonItem] = [
    .init(title: "How to evaluate a stock before buying", category: "Stocks", time: "8:24", level: "Beginner", thumbColor: Color(hex: 0x315F59)),
    .init(title: "ETFs: diversification in one trade", category: "ETFs", time: "6:18", level: "Beginner", thumbColor: Color(hex: 0x526F82)),
    .init(title: "Crypto without the hype", category: "Crypto", time: "10:42", level: "Essential", thumbColor: Color(hex: 0x9F713A)),
    .init(title: "Why bonds move when rates change", category: "Bonds", time: "7:06", level: "Intermediate", thumbColor: Color(hex: 0x725F7D)),
    .init(title: "Market orders vs. limit orders", category: "Trading basics", time: "5:31", level: "Beginner", thumbColor: Color(hex: 0x3D5968)),
    .init(title: "Reading an earnings report", category: "Research", time: "12:15", level: "Intermediate", thumbColor: Color(hex: 0x7C5B4F)),
]

struct PaymentMethodItem: Hashable {
    let name: String
    let handle: String
    let meta: String
    let balance: String
    let letter: String
    let color: Color
    let status: String
    let isDefault: Bool
}

let sampleWalletMethods: [PaymentMethodItem] = [
    .init(name: "Venmo", handle: "@maya-k", meta: "Instant · No fee", balance: "$126.40", letter: "V", color: Color(hex: 0x3185D5), status: "Connected", isDefault: true),
    .init(name: "PayPal", handle: "maya.k@email.com", meta: "Instant · No fee", balance: "$48.20", letter: "P", color: Color(hex: 0x1768A9), status: "Connected", isDefault: false),
    .init(name: "Zelle", handle: "(617) •••-0194", meta: "Bank handoff · No fee", balance: "Chase", letter: "Z", color: Color(hex: 0x6D1ED4), status: "Ready", isDefault: false),
]

struct FundingMethodItem: Hashable {
    let name: String
    let detail: String
    let speed: String
    let fee: String
    let letter: String
    let color: Color
}

let sampleFundingMethods: [FundingMethodItem] = [
    .init(name: "Venmo", detail: "Maya K. · @maya-k", speed: "Instant", fee: "No fee", letter: "V", color: Color(hex: 0x3185D5)),
    .init(name: "PayPal", detail: "maya.k@email.com", speed: "Instant", fee: "No fee", letter: "P", color: Color(hex: 0x1768A9)),
    .init(name: "Chase checking", detail: "•••• 4821", speed: "1–3 days", fee: "No fee", letter: "C", color: Color(hex: 0x397CB5)),
]

struct TransactionItem: Hashable {
    let merchant: String
    let detail: String
    let amount: String
    let letter: String
    let color: Color
    let tag: String
    var positive = false
}

let sampleTransactions: [TransactionItem] = [
    .init(merchant: "Venmo · Alex R.", detail: "Dinner split · Today", amount: "-$18.50", letter: "V", color: Color(hex: 0x3185D5), tag: "Dining"),
    .init(merchant: "Campus Books", detail: "Chase debit · Yesterday", amount: "-$42.18", letter: "C", color: Color(hex: 0x397CB5), tag: "School"),
    .init(merchant: "PayPal · Design Lab", detail: "Payment received · Mar 16", amount: "+$85.00", letter: "P", color: Color(hex: 0x1768A9), tag: "Income", positive: true),
    .init(merchant: "THESIS Investing", detail: "Venmo transfer · Mar 15", amount: "-$25.00", letter: "T", color: Theme.green, tag: "Investing"),
    .init(merchant: "Trader Joe’s", detail: "Campus Credit Union · Mar 14", amount: "-$31.26", letter: "T", color: Color(hex: 0xC06F4E), tag: "Groceries"),
]

// MARK: - Lesson components (shared by Learn and Video library)

struct VideoThumb: View {
    let lesson: LessonItem
    var height: CGFloat = 91
    var playSize: CGFloat = 32
    var radius: CGFloat = 0

    var body: some View {
        ZStack {
            lesson.thumbColor
            DecorRings(diameter: 100, opacity: 0.15, spread: false)
                .offset(x: 30, y: -50)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            Icon(.play, size: playSize * 0.53)
                .foregroundStyle(Theme.green)
                .frame(width: playSize, height: playSize)
                .background(Circle().fill(Color.white.opacity(0.94)))
            Text(lesson.time)
                .font(Theme.body(7))
                .foregroundStyle(.white)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(Color(hex: 0x0B1817, alpha: 0.72), in: RoundedRectangle(cornerRadius: 4))
                .padding(6)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        }
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
    }
}

/// Vertical card in the "Continue learning" carousel.
struct VideoCard: View {
    let lesson: LessonItem

    var body: some View {
        Button {} label: {
            VStack(alignment: .leading, spacing: 0) {
                VideoThumb(lesson: lesson)
                Tag(lesson.category.uppercased(), tone: .blue)
                    .padding(.top, 10)
                    .padding(.horizontal, 10)
                Text(lesson.title)
                    .font(Theme.display(10))
                    .lineSpacing(2)
                    .padding(.horizontal, 10)
                    .padding(.top, 6)
                    .padding(.bottom, 3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("\(lesson.level) · Prerecorded")
                    .font(Theme.body(8))
                    .foregroundStyle(Theme.muted)
                    .padding(.horizontal, 10)
                Spacer(minLength: 11)
            }
            .frame(width: 180)
            .card(radius: 12)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

/// Horizontal list row for search results and the library.
struct VideoResultRow: View {
    let lesson: LessonItem
    var showsDivider = true

    var body: some View {
        Button {} label: {
            HStack(spacing: 11) {
                VideoThumb(lesson: lesson, height: 64, playSize: 27, radius: 9)
                    .frame(width: 103)
                VStack(alignment: .leading, spacing: 0) {
                    Tag(lesson.category.uppercased(), tone: .blue)
                    Text(lesson.title)
                        .font(Theme.display(10))
                        .lineSpacing(2)
                        .padding(.top, 5)
                        .padding(.bottom, 2)
                    Text("\(lesson.level) · Prerecorded tutorial")
                        .font(Theme.body(7))
                        .foregroundStyle(Theme.muted)
                }
                Spacer(minLength: 0)
                Icon(.arrow, size: 15).foregroundStyle(Theme.muted)
            }
            .padding(.vertical, 11)
            .rowDivider(showsDivider, color: Theme.line)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
