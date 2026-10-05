import SwiftUI

// MARK: - Money Hub (wallet)

struct MoneyHubView: View {
    @State private var historyFilter = "All"

    var body: some View {
        ThesisScreen {
            TopBar(title: "Money Hub") { IconButton(.more) }
        } content: {
            totalHeader

            Button {} label: { // → moneyCoach
                HStack(alignment: .top, spacing: 11) {
                    CoachOrb(side: 34, halo: 0, iconSize: 17)
                    VStack(alignment: .leading, spacing: 0) {
                        Eyebrow("THESIS MONEY COACH", size: 8)
                        Text("Your dining spend is trending 22% lower.")
                            .font(Theme.display(12))
                            .padding(.top, 5)
                            .padding(.bottom, 3)
                        Text("You have $47 more flexibility than this time last month. See where it could go.")
                            .font(Theme.body(9))
                            .lineSpacing(2)
                            .foregroundStyle(Theme.muted)
                    }
                    Spacer(minLength: 0)
                    Icon(.arrow, size: 16).foregroundStyle(Theme.green).padding(.top, 7)
                }
                .padding(14)
                .card(radius: 14, fill: Color(hex: 0xEAF4F0), stroke: Color(hex: 0xBAD8CF))
            }
            .padding(.top, 14)

            SectionHeading("Bank accounts", action: "Link account")
            ListCard(horizontalPadding: 13, radius: 14) {
                AccountRow(
                    leading: AnyView(BankMark(color: Color(hex: 0x397CB5))),
                    title: "Chase checking", subtitle: "•••• 4821 · Connected", meta: "Available balance", trailing: "$2,416.83"
                )
                AccountRow(
                    leading: AnyView(BankMark(color: Color(hex: 0x8B5E99))),
                    title: "Campus Credit Union", subtitle: "•••• 7710 · Connected", meta: "Available balance", trailing: "$1,791.28",
                    showsDivider: false
                )
            }

            SectionHeading("Payment methods", action: "Manage")
            ListCard(horizontalPadding: 13, radius: 14) {
                ForEach(sampleWalletMethods, id: \.self) { method in
                    AccountRow(
                        leading: AnyView(PaymentLogo(letter: method.letter, color: method.color)),
                        title: method.name,
                        badge: method.isDefault ? "DEFAULT" : nil,
                        subtitle: method.handle,
                        meta: "\(method.meta) · \(method.status)",
                        trailing: method.balance,
                        showsDivider: method != sampleWalletMethods.last
                    )
                }
            }

            SectionHeading("Transaction history", action: "Search", bottomPadding: 8)
            FilterPills(options: ["All", "Money in", "Money out", "Transfers"], selection: $historyFilter)
                .padding(.bottom, 12)

            VStack(alignment: .leading, spacing: 0) {
                DateLabel("TODAY")
                ForEach(sampleTransactions.prefix(2), id: \.self) { TransactionRow(transaction: $0) }
                DateLabel("EARLIER")
                ForEach(sampleTransactions.dropFirst(2), id: \.self) { TransactionRow(transaction: $0) }
            }
            .topDivider()
        } footer: {
            BottomNav(active: .moneyHub)
        }
    }

    private var totalHeader: some View {
        VStack(spacing: 0) {
            Text("TOTAL ACROSS ACCOUNTS")
                .font(Theme.body(8, .bold))
                .tracking(Theme.tracking(0.1, 8))
                .foregroundStyle(Color(hex: 0x9DB0AC))
            Text("$4,382.71")
                .font(Theme.display(32))
                .tracking(Theme.tracking(-0.04, 32))
                .foregroundStyle(.white)
                .padding(.top, 4)
                .padding(.bottom, 1)
            Text("Updated just now")
                .font(Theme.body(9))
                .foregroundStyle(Color(hex: 0x9DB0AC))
            HStack {
                WalletAction(icon: .send, title: "Send") // → sendMoney
                WalletAction(icon: .down, title: "Add money") // → funding
                WalletAction(icon: .bank, title: "Move")
                WalletAction(icon: .spark, title: "Ask Coach") // → moneyCoach
            }
            .padding(.top, 20)
        }
        .padding(.horizontal, 20)
        .padding(.top, 26)
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity)
        .background(Theme.ink)
        .fullBleed()
        .padding(.top, 4)
    }
}

private struct WalletAction: View {
    let icon: ThesisIcon
    let title: String

    var body: some View {
        Button {} label: {
            VStack(spacing: 7) {
                Icon(icon, size: 18)
                    .frame(width: 38, height: 38)
                    .card(radius: 12, fill: Color.white.opacity(0.07), stroke: Color.white.opacity(0.086))
                Text(title).font(Theme.body(9))
            }
            .foregroundStyle(Color(hex: 0xDCE8E4))
            .frame(maxWidth: .infinity)
        }
    }
}

private struct AccountRow: View {
    let leading: AnyView
    let title: String
    var badge: String?
    let subtitle: String
    let meta: String
    let trailing: String
    var showsDivider = true

    var body: some View {
        HStack(spacing: 10) {
            leading
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 5) {
                    Text(title).font(Theme.body(10, .bold))
                    if let badge { Tag(badge, tone: .green, size: 6) }
                }
                Text(subtitle).font(Theme.body(8)).foregroundStyle(Theme.muted).padding(.top, 2)
                Text(meta).font(Theme.body(8)).foregroundStyle(Theme.green).padding(.top, 4)
            }
            Spacer()
            Text(trailing).font(Theme.display(11))
        }
        .padding(.vertical, 13)
        .rowDivider(showsDivider)
    }
}

private struct DateLabel: View {
    let text: String

    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text)
            .font(Theme.body(8, .bold))
            .tracking(Theme.tracking(0.08, 8))
            .foregroundStyle(Color(hex: 0x8C9895))
            .padding(.top, 14)
            .padding(.bottom, 5)
    }
}

private struct TransactionRow: View {
    let transaction: TransactionItem

    var body: some View {
        Button {} label: {
            HStack(spacing: 10) {
                Text(transaction.letter)
                    .font(Theme.body(13, .heavy))
                    .foregroundStyle(.white)
                    .frame(width: 34, height: 34)
                    .background(transaction.color, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                VStack(alignment: .leading, spacing: 3) {
                    Text(transaction.merchant).font(Theme.body(10, .bold))
                    Text(transaction.detail).font(Theme.body(8)).foregroundStyle(Theme.muted)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 3) {
                    Text(transaction.amount)
                        .font(Theme.body(10, .bold))
                        .foregroundStyle(transaction.positive ? Theme.green2 : Theme.ink)
                    Text(transaction.tag)
                        .font(Theme.body(8))
                        .foregroundStyle(Theme.muted)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Theme.pale, in: RoundedRectangle(cornerRadius: 5))
                }
            }
            .padding(.vertical, 10)
            .rowDivider()
            .contentShape(Rectangle())
        }
    }
}

// MARK: - Send money

struct SendMoneyView: View {
    @State private var method = "Venmo"
    @State private var amount = "25"
    @State private var sent: Bool

    private var amountText: String {
        (Double(amount) ?? 0).formatted(.currency(code: "USD"))
    }

    /// Pass `sent: true` to preview the transfer-status state.
    init(sent: Bool = false) {
        _sent = State(initialValue: sent)
    }

    var body: some View {
        if sent { sentState } else { formState }
    }

    private var formState: some View {
        ThesisScreen {
            TopBar(title: "Send money", showsBack: true) { IconButton(.clock) }
        } content: {
            HStack(spacing: 11) {
                Avatar("AR")
                VStack(alignment: .leading, spacing: 0) {
                    Text("SENDING TO")
                        .font(Theme.body(7, .bold))
                        .tracking(Theme.tracking(0.08, 7))
                        .foregroundStyle(Theme.muted)
                    Text("Alex Rivera").font(Theme.body(11, .bold))
                    Text("@alexr · Verified contact").font(Theme.body(8)).foregroundStyle(Theme.muted).padding(.top, 2)
                }
                Spacer()
                TextAction(title: "Change")
            }
            .padding(13)
            .card(radius: 13)
            .padding(.top, 8)

            VStack(spacing: 0) {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("$").font(.custom("Manrope", size: 27).weight(.semibold))
                    TextField("0", text: $amount)
                        .font(.custom("Manrope", size: 48).weight(.bold))
                        .tracking(-2.4)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.center)
                        .fixedSize()
                        .onChange(of: amount) { _, new in
                            let cleaned = new.filter { $0.isNumber || $0 == "." }
                            if cleaned != new { amount = cleaned }
                        }
                }
                Text("What’s this for?")
                    .font(Theme.body(8))
                    .foregroundStyle(Theme.muted)
                    .padding(.top, 2)
                    .padding(.bottom, 5)
                Button {} label: {
                    HStack(spacing: 4) {
                        Text("Dinner split")
                        Icon(.edit, size: 14)
                    }
                    .font(Theme.body(10, .bold))
                    .foregroundStyle(Theme.green)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 28)
            .padding(.bottom, 24)

            Text("Choose how to send").font(Theme.display(15)).padding(.bottom, 10)
            VStack(spacing: 8) {
                ForEach(sampleWalletMethods, id: \.self) { item in
                    MethodRow(
                        letter: item.letter, color: item.color, title: item.name, detail: item.handle, meta: item.meta,
                        selected: method == item.name
                    ) { method = item.name }
                }
            }

            VStack(alignment: .leading, spacing: 7) {
                Text("Paying from").font(Theme.body(8, .bold)).foregroundStyle(Theme.muted)
                HStack(spacing: 9) {
                    BankMark(color: Color(hex: 0x397CB5), side: 28, iconSize: 16)
                    Text("Chase checking · •••• 4821").font(Theme.body(9, .bold))
                    Spacer()
                    TextAction(title: "Change")
                }
                .padding(10)
                .card(radius: 11, fill: .clear)
            }
            .padding(.top, 20)

            VStack(spacing: 0) {
                KVRow(label: "Alex receives", value: amountText, size: 9, valueWeight: .regular, verticalPadding: 6)
                KVRow(label: "Transfer fee", value: "$0.00", size: 9, valueWeight: .regular, verticalPadding: 6)
                KVRow(label: "Estimated arrival", value: method == "Zelle" ? "Usually in minutes" : "Instant",
                      size: 9, valueWeight: .regular, verticalPadding: 6)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Theme.pale, in: RoundedRectangle(cornerRadius: 11, style: .continuous))
            .padding(.top, 15)
        } footer: {
            StickyFooter {
                PrimaryButton(title: "Send \(amountText) with \(method)") {
                    withAnimation { sent = true }
                }
            }
        }
    }

    private var sentState: some View {
        ThesisScreen {
            TopBar(title: "Transfer status", showsBack: true)
        } content: {
            VStack(spacing: 0) {
                SuccessSeal()
                Tag("TRANSFER SENT", tone: .green)
                Text("\(amountText) sent with \(method)")
                    .font(Theme.display(24))
                    .padding(.top, 8)
                    .padding(.bottom, 8)
                Text("Alex has been notified. You can follow the transfer status from your unified transaction history.")
                    .font(Theme.body(11))
                    .lineSpacing(3)
                    .foregroundStyle(Theme.muted)
                    .padding(.horizontal, 20)
            }
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.top, 35)

            StatusCard {
                KVRow(label: "Recipient", value: "Alex Rivera · @alexr", valueSize: 9, showsDivider: true)
                KVRow(label: "Method", value: method, valueSize: 9, showsDivider: true)
                KVRow(label: "Speed", value: method == "Zelle" ? "Bank handoff · Usually minutes" : "Instant", valueSize: 9, showsDivider: true)
                KVRow(label: "Fee", value: "$0.00", valueSize: 9, showsDivider: true)
                KVRow(label: "Status", value: "Complete", valueSize: 9, valueColor: Theme.green2)
            }

            HStack(alignment: .top, spacing: 10) {
                Icon(.spark).foregroundStyle(Theme.green)
                VStack(alignment: .leading, spacing: 3) {
                    Eyebrow("COACH NOTE", size: 7)
                    Text("This fits your usual shared-meal spending.").font(Theme.body(10, .bold))
                    Text("Your dining budget remains $32 under target this week.").font(Theme.body(8)).foregroundStyle(Theme.muted)
                }
                Spacer(minLength: 0)
            }
            .padding(13)
            .card(radius: 12, fill: Color(hex: 0xEAF4F0), stroke: Color(hex: 0xC9DED7))
            .padding(.top, 12)
        } footer: {
            StickyFooter {
                PrimaryButton(title: "Return to Money Hub") // → wallet
            }
        }
    }
}

// MARK: - Money Coach

struct MoneyCoachView: View {
    @State private var period = "This month"
    @State private var question = "Can I afford to invest another $25 this month?"

    var body: some View {
        ThesisScreen {
            TopBar(title: "Money Coach", showsBack: true) { Tag("COACH", tone: .green) }
        } content: {
            HStack(alignment: .top, spacing: 15) {
                CoachOrb(side: 42, halo: 6)
                VStack(alignment: .leading, spacing: 6) {
                    Eyebrow("YOUR MARCH CHECK-IN", size: 8)
                    Text("You’re spending with more intention.")
                        .font(Theme.display(22))
                        .tracking(Theme.tracking(-0.04, 22))
                    Text("I analyzed activity across your connected accounts, Venmo, PayPal, and Zelle.")
                        .font(Theme.body(10))
                        .lineSpacing(3)
                        .foregroundStyle(Theme.muted)
                }
            }
            .padding(.vertical, 20)

            SegmentedPills(["This week", "This month", "3 months"], selection: $period, height: 31, fontSize: 9,
                           activeColor: Theme.ink, inactiveColor: Theme.muted)

            spendSummary

            SectionHeading("Coach observations", action: "How this works")
            CoachObservation(
                icon: .down, tone: .good, tag: "POSITIVE SHIFT", title: "Dining spend is down $47",
                detail: "You made fewer small Venmo payments this month. That change—not one big cut—created most of your extra flexibility."
            ) { TextLink(title: "Show the transactions", size: 9, icon: .arrow) }

            CoachObservation(
                icon: .clock, tone: .watch, tag: "UPCOMING", title: "Your textbook payment is larger than usual",
                detail: "A $116 PayPal charge is scheduled for Friday. Your Chase balance can cover it, but your weekly buffer would fall to $64."
            ) { TextLink(title: "Plan around this payment", size: 9, icon: .arrow) }

            CoachObservation(
                icon: .spark, tone: .neutral, tag: "REFLECTION", title: "You could move $25 without missing your buffer",
                detail: "Based on your usual bills—not a guarantee—you’re on track to keep your $150 cash cushion this month."
            ) {
                HStack(spacing: 5) {
                    ForEach(["Save it", "Invest it", "Keep as cash"], id: \.self) { option in
                        Button {} label: {
                            Text(option)
                                .font(Theme.body(8))
                                .foregroundStyle(Theme.green)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 6)
                                .card(radius: 7, fill: Theme.paper)
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 0) {
                Text("Payment habits").font(Theme.display(15)).padding(.bottom, 12)
                Group {
                    KVRow(label: "Most-used method", value: "Venmo · 12 payments", size: 9, verticalPadding: 10)
                    KVRow(label: "Fastest-growing category", value: "School supplies · +18%", size: 9, verticalPadding: 10)
                    KVRow(label: "Recurring next 7 days", value: "3 payments · $141.97", size: 9, verticalPadding: 10)
                }
                .topDivider()
            }
            .padding(.top, 22)

            ReasonInput(label: "Ask about a transaction or spending habit", text: $question, background: Color(hex: 0xF7FAF8)) {
                Text("Uses your connected activity")
            }
            .padding(.top, 17)

            Text("Money Coach provides educational guidance based on connected account data, not financial advice. Balances may be delayed.")
                .font(Theme.body(9))
                .lineSpacing(3)
                .foregroundStyle(Theme.muted)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.top, 15)
        }
    }

    private var spendSummary: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center, spacing: 14) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("SPENT THIS MONTH").font(Theme.body(7, .bold)).foregroundStyle(Theme.muted)
                    Text("$684.26").font(Theme.display(22)).padding(.top, 4).padding(.bottom, 2)
                    HStack(spacing: 2) {
                        Icon(.down, size: 12)
                        Text("8% vs. last month")
                    }
                    .font(Theme.body(8))
                    .foregroundStyle(Theme.green)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                GeometryReader { geo in
                    VStack(alignment: .leading, spacing: 5) {
                        ForEach(SpendCategory.all, id: \.label) { item in
                            Capsule().fill(item.color).frame(width: geo.size.width * item.fraction, height: 5)
                        }
                    }
                    .frame(maxHeight: .infinity)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
            }

            LazyVGrid(columns: [GridItem(.flexible(), alignment: .leading), GridItem(.flexible(), alignment: .leading)], spacing: 7) {
                ForEach(SpendCategory.all, id: \.label) { item in
                    HStack(spacing: 5) {
                        RoundedRectangle(cornerRadius: 2).fill(item.color).frame(width: 7, height: 7)
                        Text(item.label)
                    }
                    .font(Theme.body(8))
                    .foregroundStyle(Theme.muted)
                }
            }
            .padding(.top, 10)
            .topDivider()
        }
        .padding(15)
        .card(radius: 14)
        .padding(.top, 12)
    }
}

private struct SpendCategory {
    let label: String
    let fraction: CGFloat
    let color: Color

    static let all = [
        SpendCategory(label: "Housing $410", fraction: 0.84, color: Color(hex: 0x3B756E)),
        SpendCategory(label: "Food $142", fraction: 0.58, color: Color(hex: 0x8FAFA6)),
        SpendCategory(label: "School $78", fraction: 0.37, color: Color(hex: 0xB99455)),
        SpendCategory(label: "Other $54", fraction: 0.24, color: Color(hex: 0xCBD5D2)),
    ]
}

private enum ObservationTone { case good, watch, neutral }

private struct CoachObservation<Footer: View>: View {
    let icon: ThesisIcon
    let tone: ObservationTone
    let tag: String
    let title: String
    let detail: String
    @ViewBuilder var footer: Footer

    private var tileColors: (fg: Color, bg: Color) {
        switch tone {
        case .good: (Theme.green, Color(hex: 0xE5F1ED))
        case .watch: (Color(hex: 0x946F34), Color(hex: 0xF8ECD8))
        case .neutral: (Color(hex: 0x4C6D82), Color(hex: 0xE8EFF3))
        }
    }

    private var tagTone: TagTone {
        switch tone {
        case .good: .green
        case .watch: .gold
        case .neutral: .blue
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 11) {
            IconTile(icon: icon, side: 30, radius: 9, iconSize: 18, foreground: tileColors.fg, background: tileColors.bg)
            VStack(alignment: .leading, spacing: 0) {
                Tag(tag, tone: tagTone)
                Text(title)
                    .font(Theme.display(12))
                    .padding(.top, 6)
                    .padding(.bottom, 3)
                Text(detail)
                    .font(Theme.body(9))
                    .lineSpacing(2)
                    .foregroundStyle(Theme.muted)
                    .padding(.bottom, 7)
                footer
            }
            Spacer(minLength: 0)
        }
        .padding(13)
        .card(radius: 13)
        .padding(.bottom, 9)
    }
}

#Preview("Money Hub") { MoneyHubView() }
#Preview("Send money") { SendMoneyView() }
#Preview("Send money – sent") { SendMoneyView(sent: true) }
#Preview("Money Coach") { MoneyCoachView() }
