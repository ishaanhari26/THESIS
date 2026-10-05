import SwiftUI

// MARK: - Trade

struct TradeView: View {
    @State private var mode = "Dollars"
    @State private var amount: String

    private let cash = 17.18
    private let price = 121.67
    private var amountValue: Double { Double(amount) ?? 0 }
    private var needsFunding: Bool { amountValue > cash }

    /// Pass e.g. "40" to preview the "You need more cash" state.
    init(amount: String = "25") {
        _amount = State(initialValue: amount)
    }

    var body: some View {
        ThesisScreen {
            TopBar(title: "Buy NVDA", showsBack: true) { TextAction(title: "Market order") }
        } content: {
            HStack(spacing: 10) {
                StockLogo(size: .small)
                VStack(alignment: .leading, spacing: 2) {
                    Text("NVIDIA").font(Theme.display(12))
                    Text("$121.67 · \(Text("+3.80%").foregroundStyle(Theme.green2))")
                        .font(Theme.body(10))
                        .foregroundStyle(Theme.muted)
                }
            }
            .padding(.top, 8)

            SegmentedPills(["Dollars", "Shares"], selection: $mode)
                .padding(.top, 24)

            amountEntry
            quickAmounts

            HStack {
                Text("Cash available to invest").foregroundStyle(Theme.muted)
                Spacer()
                Text(cash, format: .currency(code: "USD")).bold()
            }
            .font(Theme.body(11))
            .padding(.vertical, 17)
            .topDivider()
            .overlay(alignment: .bottom) { Rectangle().fill(Theme.line).frame(height: 1) }
            .padding(.top, 20)

            AllocationPreview()

            if needsFunding {
                HStack(alignment: .top, spacing: 10) {
                    Icon(.wallet)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("You need \((amountValue - cash).formatted(.currency(code: "USD"))) more cash")
                            .font(Theme.body(11, .bold))
                        Text("Add money from Venmo, PayPal, or your bank to complete this trade.")
                            .font(Theme.body(10))
                            .foregroundStyle(Color(hex: 0x7F725D))
                    }
                    Spacer(minLength: 0)
                }
                .foregroundStyle(Theme.goldText)
                .padding(13)
                .card(radius: 11, fill: Color(hex: 0xFFF7E8), stroke: Color(hex: 0xECD9B4))
                .padding(.top, 12)
            }

            VStack(spacing: 0) {
                KVRow(label: "Order type", value: "Market", verticalPadding: 9)
                KVRow(label: "Trading session", value: "Market hours", verticalPadding: 9)
                KVRow(label: "Estimated price", value: "$121.67", verticalPadding: 9)
            }
            .padding(.top, 18)
        } footer: {
            StickyFooter {
                // → funding when short on cash, otherwise → risk
                PrimaryButton(title: needsFunding ? "Add money to continue" : "Preview risk")
            }
        }
    }

    private var amountEntry: some View {
        VStack(spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                if mode == "Dollars" {
                    Text("$").font(.custom("Manrope", size: 30).weight(.semibold))
                }
                TextField("0", text: $amount)
                    .font(.custom("Manrope", size: 54).weight(.bold))
                    .tracking(-3)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .fixedSize()
                    .accessibilityLabel("Trade amount")
                    .onChange(of: amount) { _, new in
                        let cleaned = new.filter { $0.isNumber || $0 == "." }
                        if cleaned != new { amount = cleaned }
                    }
            }
            Text("≈ \(amountValue / price, format: .number.precision(.fractionLength(4))) shares")
                .font(Theme.body(11))
                .foregroundStyle(Theme.muted)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 32)
        .padding(.bottom, 18)
    }

    private var quickAmounts: some View {
        HStack(spacing: 7) {
            ForEach(["10", "25", "50"], id: \.self) { value in
                QuickAmountChip(title: "$\(value)", active: amount == value) { amount = value }
            }
            QuickAmountChip(title: "Max", active: false) { amount = String(cash) }
        }
        .frame(maxWidth: .infinity)
    }
}

private struct QuickAmountChip: View {
    let title: String
    let active: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Theme.body(10, active ? .bold : .regular))
                .foregroundStyle(active ? Theme.green : Theme.ink)
                .frame(minWidth: 62)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(Capsule().fill(active ? Theme.mint : .white))
                .overlay(Capsule().strokeBorder(active ? Color(hex: 0xB9D8CF) : Theme.line))
        }
    }
}

private struct AllocationPreview: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Portfolio impact").font(Theme.body(9)).foregroundStyle(Theme.muted)
                    Text("NVDA would become 1.9% of your portfolio").font(Theme.display(12))
                }
                Spacer()
                Icon(.pie).foregroundStyle(Theme.green)
            }
            .padding(.bottom, 15)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color(hex: 0xE8EEEB))
                    Capsule().fill(Theme.green).frame(width: max(7, geo.size.width * 0.019))
                }
            }
            .frame(height: 7)

            HStack {
                Text("Now 0%")
                Spacer()
                Text("After 1.9%")
            }
            .font(Theme.body(9))
            .foregroundStyle(Theme.muted)
            .padding(.top, 6)
        }
        .padding(15)
        .card(radius: 14)
        .padding(.top, 16)
    }
}

// MARK: - Add money (funding)

struct FundingView: View {
    @State private var selected = 0
    @State private var confirmed: Bool

    /// Pass `confirmed: true` to preview the success state.
    init(confirmed: Bool = false) {
        _confirmed = State(initialValue: confirmed)
    }

    var body: some View {
        if confirmed { confirmedState } else { methodState }
    }

    private var methodState: some View {
        ThesisScreen {
            TopBar(title: "Add money", showsBack: true) { IconButton(.clock) }
        } content: {
            StepIndicator(steps: ["Method", "Review", "Done"], active: 0)
                .padding(.top, 6)
                .padding(.bottom, 22)

            VStack(spacing: 3) {
                Text("Add").font(Theme.body(10)).foregroundStyle(Theme.muted)
                Text("$25.00").font(Theme.display(31))
                Text("Needed for your NVDA order").font(Theme.body(9)).foregroundStyle(Theme.muted)
            }
            .frame(maxWidth: .infinity)
            .padding(19)
            .background(Theme.pale, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

            SectionHeading("Choose a funding method", action: "Manage")
            VStack(spacing: 9) {
                ForEach(Array(sampleFundingMethods.enumerated()), id: \.offset) { index, method in
                    MethodRow(
                        letter: method.letter,
                        color: method.color,
                        title: method.name,
                        detail: method.detail,
                        meta: "\(method.speed) · \(method.fee)",
                        selected: selected == index
                    ) { selected = index }
                }
            }

            Button {} label: {
                HStack(spacing: 11) {
                    IconTile(icon: .card, side: 38, radius: 9, iconSize: 20, background: Color(hex: 0xEAF1EE))
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Add a payment method").font(Theme.body(11, .bold))
                        Text("Debit card, bank account, or another provider").font(Theme.body(9)).foregroundStyle(Theme.muted)
                    }
                    Spacer()
                    Icon(.arrow)
                }
                .padding(12)
                .dashedCard()
            }
            .padding(.top, 10)

            HStack(alignment: .top, spacing: 9) {
                Icon(.shield).foregroundStyle(Theme.green)
                Text("Your financial information is encrypted and never shared with other THESIS users.")
                    .font(Theme.body(9))
                    .lineSpacing(3)
            }
            .foregroundStyle(Theme.muted)
            .padding(.horizontal, 8)
            .padding(.vertical, 18)
        } footer: {
            StickyFooter {
                HStack {
                    Text("Transfer total").foregroundStyle(Theme.muted)
                    Spacer()
                    Text("$25.00")
                }
                .font(Theme.body(11))
                .padding(.bottom, 8)
                PrimaryButton(title: "Review & confirm") {
                    withAnimation { confirmed = true }
                }
            }
        }
    }

    private var confirmedState: some View {
        ThesisScreen {
            TopBar(title: "Add money", showsBack: true)
        } content: {
            VStack(spacing: 0) {
                SuccessSeal()
                Text("$25.00 is on its way")
                    .font(Theme.display(24))
                    .padding(.bottom, 8)
                Text("Your Venmo transfer is available to invest now. Settlement typically completes within one business day.")
                    .font(Theme.body(11))
                    .lineSpacing(3)
                    .foregroundStyle(Theme.muted)
                    .padding(.horizontal, 20)
            }
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.top, 42)

            StatusCard {
                KVRow(label: "Status", value: "Available to invest", valueSize: 9, valueColor: Theme.green2, showsDivider: true)
                KVRow(label: "From", value: "\(sampleFundingMethods[selected].name) · \(sampleFundingMethods[selected].detail)", valueSize: 9, showsDivider: true)
                KVRow(label: "Amount", value: "$25.00", valueSize: 9, showsDivider: true)
                KVRow(label: "Fee", value: "$0.00", valueSize: 9, showsDivider: true)
                KVRow(label: "Reference", value: "THS-834921", valueSize: 9)
            }

            StatusCard {
                Text("Your money")
                    .font(Theme.display(13))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 10)
                    .padding(.bottom, 3)
                MoneyDotRow(color: Theme.green2, label: "Available to invest", value: "$42.18")
                MoneyDotRow(color: Theme.gold, label: "Pending settlement", value: "$25.00")
                MoneyDotRow(color: Color(hex: 0x617E98), label: "Invested", value: "$1,242.44")
                MoneyDotRow(color: Color(hex: 0x9DA9A6), label: "Withdrawable cash", value: "$17.18", showsDivider: false)
            }
        } footer: {
            StickyFooter {
                PrimaryButton(title: "Continue to risk preview") // → risk
            }
        }
    }
}

/// Selectable payment method row with a radio (method-list / send-methods).
struct MethodRow: View {
    let letter: String
    let color: Color
    let title: String
    let detail: String
    let meta: String
    let selected: Bool
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            HStack(spacing: 11) {
                PaymentLogo(letter: letter, color: color)
                VStack(alignment: .leading, spacing: 0) {
                    Text(title).font(Theme.body(11, .bold))
                    Text(detail).font(Theme.body(9)).foregroundStyle(Theme.muted).padding(.top, 2)
                    Text(meta).font(Theme.body(8)).foregroundStyle(Theme.green).padding(.top, 4)
                }
                Spacer()
                RadioDot(selected: selected)
            }
            .padding(12)
            .card(radius: 12, stroke: selected ? Theme.green : Theme.line, lineWidth: selected ? 2 : 1)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct StepIndicator: View {
    let steps: [String]
    let active: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                let isActive = index == active
                HStack(spacing: 5) {
                    Text("\(index + 1)")
                        .frame(width: 18, height: 18)
                        .background(Circle().fill(isActive ? Theme.green : Color(hex: 0xE7EDEB)))
                        .foregroundStyle(isActive ? .white : Color(hex: 0x8B9794))
                    Text(step)
                        .foregroundStyle(isActive ? Theme.green : Color(hex: 0x8B9794))
                }
                .font(Theme.body(9, isActive ? .bold : .regular))
                if index < steps.count - 1 {
                    Rectangle().fill(Theme.line).frame(width: 35, height: 1)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct SuccessSeal: View {
    var body: some View {
        Icon(.check, size: 34, weight: .semibold)
            .foregroundStyle(.white)
            .frame(width: 64, height: 64)
            .background(Circle().fill(Theme.green))
            .background(Circle().fill(Color(hex: 0xE5F1ED)).padding(-10))
            .padding(.bottom, 20)
    }
}

/// White rounded table used on status screens.
struct StatusCard<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: 0) { content }
            .padding(.horizontal, 15)
            .padding(.vertical, 7)
            .card(radius: 14)
            .padding(.top, 24)
    }
}

private struct MoneyDotRow: View {
    let color: Color
    let label: String
    let value: String
    var showsDivider = true

    var body: some View {
        HStack {
            Circle().fill(color).frame(width: 7, height: 7)
            Text(label).foregroundStyle(Theme.muted)
            Spacer()
            Text(value).bold()
        }
        .font(Theme.body(10))
        .padding(.vertical, 11)
        .rowDivider(showsDivider)
    }
}

// MARK: - Risk preview

struct RiskView: View {
    private struct Scenario {
        let label: String
        let impact: String
        let total: String
        let isLoss: Bool
    }

    private let scenarios = [
        Scenario(label: "Falls 10%", impact: "-$2.50", total: "$1,282.12", isLoss: true),
        Scenario(label: "Falls 30%", impact: "-$7.50", total: "$1,277.12", isLoss: true),
        Scenario(label: "Rises 20%", impact: "+$5.00", total: "$1,289.62", isLoss: false),
    ]

    @State private var scenario = 0

    var body: some View {
        ThesisScreen {
            TopBar(title: "Risk preview", showsBack: true) { Icon(.shield) }
        } content: {
            VStack(alignment: .leading, spacing: 7) {
                Eyebrow("BEFORE YOU INVEST", trackingEm: 0.1)
                Text("See the trade in context.")
                    .font(Theme.display(23))
                    .tracking(Theme.tracking(-0.04, 23))
                Text("A $25 investment is a small part of your portfolio. The bigger risk is what you do repeatedly.")
                    .font(Theme.body(11))
                    .lineSpacing(4)
                    .foregroundStyle(Theme.muted)
            }
            .padding(.top, 22)
            .padding(.bottom, 15)

            concentrationCard
            allocation
            scenarioSection
            riskChecks
        } footer: {
            StickyFooter {
                PrimaryButton(title: "I understand—review order") // → review
            }
        }
    }

    private var concentrationCard: some View {
        HStack(spacing: 18) {
            ZStack {
                RingProgress(progress: 0.02, lineWidth: 9, track: Color(hex: 0xE5EBE8))
                VStack(spacing: 0) {
                    Text("1.9%").font(Theme.display(17))
                    Text("NVDA").font(Theme.body(8)).foregroundStyle(Theme.muted)
                }
            }
            .frame(width: 95, height: 95)

            VStack(alignment: .leading, spacing: 5) {
                Eyebrow("CONCENTRATION", size: 8, trackingEm: 0)
                Text("Low portfolio impact").font(Theme.display(15))
                Text("After this trade, NVIDIA would represent \(Text("1.9%").bold().foregroundStyle(Theme.ink)) of your total portfolio.")
                    .font(Theme.body(10))
                    .lineSpacing(3)
                    .foregroundStyle(Theme.muted)
            }
        }
        .padding(17)
        .card(radius: 15)
    }

    private var allocation: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("After this trade").font(Theme.display(15)).padding(.bottom, 12)
            GeometryReader { geo in
                let w = geo.size.width - 6 // three 2pt gaps
                HStack(spacing: 2) {
                    Rectangle().fill(Color(hex: 0x3B756E)).frame(width: w * 0.51)
                    Rectangle().fill(Color(hex: 0x7DAAA0)).frame(width: w * 0.36)
                    Rectangle().fill(Color(hex: 0xB99455)).frame(width: max(2, w * 0.019))
                    Rectangle().fill(Color(hex: 0xD9E2DF))
                }
            }
            .frame(height: 10)
            .clipShape(Capsule())

            LazyVGrid(columns: [GridItem(.flexible(), alignment: .leading), GridItem(.flexible(), alignment: .leading)], spacing: 8) {
                LegendItem(color: Color(hex: 0x3B756E), label: "ETFs 51%")
                LegendItem(color: Color(hex: 0x7DAAA0), label: "Stocks 36%")
                LegendItem(color: Color(hex: 0xB99455), label: "NVDA 1.9%")
                LegendItem(color: Color(hex: 0xD9E2DF), label: "Cash 11.1%")
            }
            .padding(.top, 11)
        }
        .padding(.top, 24)
    }

    private var scenarioSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("What if NVDA...").font(Theme.display(15)).padding(.bottom, 12)
            HStack(spacing: 7) {
                ForEach(scenarios.indices, id: \.self) { i in
                    let item = scenarios[i]
                    let active = i == scenario
                    let tint = item.isLoss ? Theme.red : Theme.green
                    Button { scenario = i } label: {
                        Text(item.label)
                            .font(Theme.body(9))
                            .foregroundStyle(active ? tint : Theme.ink)
                            .frame(maxWidth: .infinity)
                            .frame(height: 34)
                            .card(
                                radius: 9,
                                fill: active ? (item.isLoss ? Color(hex: 0xFAEFED) : Color(hex: 0xE7F2EE)) : .white,
                                stroke: active ? tint : Theme.line
                            )
                    }
                }
            }

            let current = scenarios[scenario]
            HStack {
                ScenarioFigure(label: "Impact on this position", value: current.impact, color: current.isLoss ? Theme.red : Theme.green)
                Spacer()
                Icon(.arrow).foregroundStyle(Color(hex: 0xA8B3B0))
                Spacer()
                ScenarioFigure(label: "Estimated portfolio value", value: current.total, color: Theme.ink)
            }
            .padding(15)
            .card(radius: 12)
            .padding(.top, 9)
        }
        .padding(.top, 24)
    }

    private var riskChecks: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Risk snapshot").font(Theme.display(15)).padding(.bottom, 12)
            RiskCheckRow(title: "Diversification stays healthy", detail: "No single position exceeds 15% of your portfolio.")
            RiskCheckRow(title: "Your emergency cash is separate", detail: "You marked $800 as outside your investing account.")
            RiskCheckRow(title: "NVDA is more volatile than the market", detail: "Its price has moved about 2× more than the S&P 500 recently.", caution: true)
        }
        .padding(.top, 24)
    }
}

private struct LegendItem: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 5) {
            RoundedRectangle(cornerRadius: 2).fill(color).frame(width: 7, height: 7)
            Text(label)
        }
        .font(Theme.body(9))
        .foregroundStyle(Theme.muted)
    }
}

private struct ScenarioFigure: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(label).font(Theme.body(8)).foregroundStyle(Theme.muted)
            Text(value).font(Theme.display(15)).foregroundStyle(color)
        }
    }
}

private struct RiskCheckRow: View {
    let title: String
    let detail: String
    var caution = false

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            if caution {
                Text("!")
                    .font(Theme.body(10, .heavy))
                    .foregroundStyle(Color(hex: 0x936F33))
                    .frame(width: 20, height: 20)
                    .background(Circle().fill(Color(hex: 0xF6EAD6)))
            } else {
                Icon(.check, size: 14, weight: .semibold)
                    .foregroundStyle(Theme.green)
                    .frame(width: 20, height: 20)
                    .background(Circle().fill(Color(hex: 0xE1EFE9)))
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(Theme.body(10, .bold))
                Text(detail).font(Theme.body(9)).foregroundStyle(Theme.muted)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 12)
        .topDivider()
    }
}

// MARK: - Review order

struct ReviewView: View {
    var body: some View {
        ThesisScreen {
            TopBar(title: "Review order", showsBack: true)
        } content: {
            VStack(spacing: 0) {
                StockLogo().padding(.bottom, 13)
                Eyebrow("YOU’RE BUYING", size: 8, trackingEm: 0.1)
                Text("$25.00 of NVIDIA")
                    .font(Theme.display(23))
                    .padding(.vertical, 5)
                Text("≈ 0.2055 shares at the current market price")
                    .font(Theme.body(10))
                    .foregroundStyle(Theme.muted)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)

            ReviewCard(title: "Order details") {
                KVRow(label: "Symbol", value: "NVDA", verticalPadding: 7)
                KVRow(label: "Order type", value: "Market order", verticalPadding: 7)
                KVRow(label: "Estimated price", value: "$121.67", verticalPadding: 7)
                KVRow(label: "Estimated shares", value: "0.2055", verticalPadding: 7)
                KVRow(label: "Trading fee", value: "$0.00", verticalPadding: 7)
                Rectangle().fill(Theme.line).frame(height: 1).padding(.vertical, 7)
                KVRow(label: "Order total", value: "$25.00", size: 12, valueSize: 14, verticalPadding: 7)
            }

            ReviewCard(title: "After this order") {
                KVRow(label: "Cash available", value: "$17.18", verticalPadding: 7)
                KVRow(label: "NVDA allocation", value: "1.9% of portfolio", verticalPadding: 7)
                KVRow(label: "Buying power", value: "$17.18", verticalPadding: 7)
            }

            Button {} label: {
                HStack(spacing: 10) {
                    IconTile(icon: .edit, side: 34, radius: 9, iconSize: 18, background: .white)
                    VStack(alignment: .leading, spacing: 3) {
                        Eyebrow("SAVED WITH THIS TRADE", size: 8, trackingEm: 0)
                        Text("Your NVIDIA thesis").font(Theme.display(11))
                        Text("“AI infrastructure spending will continue growing…”")
                            .font(Theme.body(9))
                            .foregroundStyle(Theme.muted)
                            .lineLimit(1)
                    }
                    Spacer(minLength: 0)
                    Icon(.arrow)
                }
                .padding(13)
                .card(radius: 13, fill: Color(hex: 0xEDF6F2), stroke: Color(hex: 0xBAD6CE))
            }

            HStack(alignment: .top, spacing: 10) {
                Icon(.clock).foregroundStyle(Color(hex: 0x9C7536))
                VStack(alignment: .leading, spacing: 3) {
                    Text("Market orders prioritize execution, not price.").font(Theme.body(9, .bold))
                    Text("Your final price may differ from this estimate if the market moves.")
                        .font(Theme.body(9))
                        .lineSpacing(2)
                        .foregroundStyle(Theme.muted)
                }
                Spacer(minLength: 0)
            }
            .padding(13)
            .background(Color(hex: 0xFFF8EB), in: RoundedRectangle(cornerRadius: 11, style: .continuous))
            .padding(.top, 14)

            Text("By placing this order, you agree to THESIS’s \(Text("customer agreement").underline()). This is not investment advice.")
                .font(Theme.body(8))
                .lineSpacing(3)
                .foregroundStyle(Theme.muted)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.top, 16)
        } footer: {
            StickyFooter {
                PrimaryButton(title: "Swipe to place order", capsule: true) // → success
            }
        }
    }
}

private struct ReviewCard<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title).font(Theme.display(13)).padding(.bottom, 10)
            content
        }
        .padding(15)
        .card(radius: 14)
        .padding(.bottom, 12)
    }
}

// MARK: - Order filled

struct SuccessView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                LogoView()

                ZStack {
                    Circle().stroke(Color(hex: 0xDAE7E2)).frame(width: 175, height: 175)
                    Circle().stroke(Color(hex: 0xBFD5CE)).frame(width: 130, height: 130)
                    StockLogo(size: .large)
                        .overlay(alignment: .bottomTrailing) {
                            Icon(.check, size: 14, weight: .bold)
                                .foregroundStyle(.white)
                                .frame(width: 27, height: 27)
                                .background(Circle().fill(Theme.green))
                                .overlay(Circle().strokeBorder(.white, lineWidth: 3))
                                .offset(x: 10, y: 8)
                        }
                }
                .frame(height: 190)
                .padding(.top, 15)

                Tag("ORDER FILLED", tone: .green)

                Text("You invested with a reason.")
                    .font(Theme.display(27))
                    .tracking(Theme.tracking(-0.05, 27))
                    .padding(.top, 13)
                    .padding(.bottom, 8)

                Text("Your order for \(Text("$25.00 of NVIDIA").bold().foregroundStyle(Theme.ink)) was filled at an average price of $121.62.")
                    .font(Theme.body(11))
                    .lineSpacing(4)
                    .foregroundStyle(Theme.muted)

                VStack(spacing: 0) {
                    KVRow(label: "Shares purchased", value: "0.2056 NVDA", verticalPadding: 10, showsDivider: true)
                    KVRow(label: "NVDA position", value: "$25.00", verticalPadding: 10, showsDivider: true)
                    KVRow(label: "Portfolio allocation", value: "1.9%", verticalPadding: 10)
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 7)
                .card(radius: 14)
                .padding(.top, 22)

                HStack(alignment: .top, spacing: 11) {
                    Icon(.edit).foregroundStyle(Theme.green)
                    VStack(alignment: .leading, spacing: 3) {
                        Eyebrow("THESIS SAVED", size: 8, trackingEm: 0)
                        Text("Your reasoning stays with the investment.").font(Theme.display(11))
                        Text("We’ll help you revisit it when the story changes—not just when the price does.")
                            .font(Theme.body(9))
                            .lineSpacing(2)
                            .foregroundStyle(Theme.muted)
                    }
                    Spacer(minLength: 0)
                }
                .multilineTextAlignment(.leading)
                .padding(15)
                .background(Color(hex: 0xE9F3EF), in: RoundedRectangle(cornerRadius: 13, style: .continuous))
                .padding(.top, 13)
                .padding(.bottom, 20)

                PrimaryButton(title: "View in portfolio") // → portfolio
                Button {} label: { // → home
                    Text("Return home")
                        .font(Theme.body(11, .bold))
                        .foregroundStyle(Theme.green)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 10)
                }
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 30)
            .padding(.top, 22)
            .padding(.bottom, 50)
        }
        .scrollIndicators(.hidden)
        .background(
            LinearGradient(stops: [.init(color: Color(hex: 0xF4F8F5), location: 0), .init(color: Theme.paper, location: 0.6)],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
        .foregroundStyle(Theme.ink)
        .buttonStyle(.plain)
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview("Trade") { TradeView() }
#Preview("Trade – needs funding") { TradeView(amount: "40") }
#Preview("Funding") { FundingView() }
#Preview("Funding – confirmed") { FundingView(confirmed: true) }
#Preview("Risk") { RiskView() }
#Preview("Review") { ReviewView() }
#Preview("Success") { SuccessView() }
