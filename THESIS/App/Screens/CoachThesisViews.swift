import SwiftUI

// MARK: - THESIS Coach

struct CoachView: View {
    @State private var reason = "I want NVIDIA because AI is growing and companies will keep needing more chips."

    var body: some View {
        ThesisScreen {
            TopBar(title: "THESIS Coach", showsBack: true) { Tag("CHALLENGE", tone: .green, size: 8) }
        } content: {
            VStack(spacing: 0) {
                CoachOrb()
                Text("Let’s pressure-test your thinking.")
                    .font(Theme.display(23))
                    .tracking(Theme.tracking(-0.04, 23))
                    .multilineTextAlignment(.center)
                    .padding(.top, 7)
                    .padding(.bottom, 8)
                Text("I won’t tell you what to buy. I’ll help you examine why you want to buy it.")
                    .font(Theme.body(12))
                    .lineSpacing(4)
                    .foregroundStyle(Theme.muted)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 15)
            .padding(.vertical, 22)

            ReasonInput(label: "Why are you considering NVIDIA?", text: $reason) {
                Text("\(reason.count)/240")
            }

            coachResponse

            Text("THESIS provides educational analysis, not investment advice. Investing involves risk.")
                .font(Theme.body(9))
                .lineSpacing(3)
                .foregroundStyle(Theme.muted)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.top, 15)
        } footer: {
            StickyFooter {
                HStack(spacing: 8) {
                    ChipButton(title: "Show more evidence")
                    ChipButton(title: "Show risks")
                }
                .padding(.bottom, 9)
                PrimaryButton(title: "Build my investment thesis") // → thesis
                Button {} label: { // → trade
                    Text("Skip and continue to trade")
                        .font(Theme.body(11, .bold))
                        .foregroundStyle(Theme.green)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 10)
                }
            }
        }
    }

    private var coachResponse: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 9) {
                Icon(.spark, size: 15)
                    .foregroundStyle(Color(hex: 0xD6EFE8))
                    .frame(width: 30, height: 30)
                    .background(Circle().fill(Theme.green))
                VStack(alignment: .leading, spacing: 2) {
                    Text("THESIS")
                        .font(Theme.display(10, .heavy))
                        .tracking(Theme.tracking(0.08, 10))
                    Text("Reasoning coach").font(Theme.body(9)).foregroundStyle(Theme.muted)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .rowDivider(color: Theme.line)

            ResponseBlock(number: "01", title: "Your reasoning") {
                Text("You believe continued AI adoption will increase demand for the specialized chips NVIDIA designs.")
            }
            ResponseBlock(number: "02", title: "Evidence supporting it") {
                BulletList([
                    "Data center revenue grew significantly year over year.",
                    "Major cloud companies have guided to higher AI infrastructure spending.",
                    "Blackwell demand currently exceeds available supply.",
                ])
            }
            ResponseBlock(number: "03", title: "Assumptions you’re making", tone: .warning) {
                BulletList([
                    "NVIDIA keeps its lead as competitors develop alternatives.",
                    "AI spending translates into durable, profitable demand.",
                    "Today’s price does not already reflect that growth.",
                ])
            }
            ResponseBlock(number: "04", title: "What could prove you wrong?", tone: .danger, showsDivider: false) {
                Text("A pullback in cloud spending, customer-built chips, or margin pressure could weaken your thesis—even if AI keeps growing.")
            }
        }
        .card(radius: 15)
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        .padding(.top, 16)
    }
}

/// White card with a label, multi-line text field, and a send button (reason-input).
struct ReasonInput<Meta: View>: View {
    let label: String
    @Binding var text: String
    var background: Color = .white
    @ViewBuilder var meta: Meta

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(Theme.body(10, .bold))
                .foregroundStyle(Theme.muted)
            TextField("", text: $text, axis: .vertical)
                .font(Theme.body(13))
                .lineSpacing(4)
                .lineLimit(3...6)
                .frame(minHeight: 64, alignment: .topLeading)
            HStack {
                meta
                    .font(Theme.body(9))
                    .foregroundStyle(Color(hex: 0x9AA5A2))
                Spacer()
                Button {} label: {
                    Icon(.send, size: 18)
                        .foregroundStyle(.white)
                        .frame(width: 30, height: 30)
                        .background(Theme.green, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .accessibilityLabel("Submit")
            }
        }
        .padding(14)
        .card(radius: 14, fill: background)
    }
}

private enum ResponseTone { case normal, warning, danger }

private struct ResponseBlock<Content: View>: View {
    let number: String
    let title: String
    var tone: ResponseTone = .normal
    var showsDivider = true
    @ViewBuilder var content: Content

    private var numberColor: Color {
        switch tone {
        case .normal: Theme.green
        case .warning: Theme.gold
        case .danger: Theme.red
        }
    }

    private var background: Color {
        switch tone {
        case .normal: .white
        case .warning: Color(hex: 0xFFFCF5)
        case .danger: Color(hex: 0xFCF6F4)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 9) {
                Text(number)
                    .font(Theme.display(9))
                    .foregroundStyle(numberColor)
                Text(title).font(Theme.display(13))
            }
            content
                .font(Theme.body(11))
                .lineSpacing(4)
                .foregroundStyle(Color(hex: 0x4F605D))
                .padding(.leading, 24)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(background)
        .rowDivider(showsDivider, color: Theme.line)
    }
}

struct BulletList: View {
    let items: [String]

    init(_ items: [String]) { self.items = items }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(items, id: \.self) { item in
                HStack(alignment: .firstTextBaseline, spacing: 7) {
                    Text("•")
                    Text(item)
                }
            }
        }
    }
}

private struct ChipButton: View {
    let title: String

    var body: some View {
        Button {} label: {
            Text(title)
                .font(Theme.body(10))
                .frame(maxWidth: .infinity)
                .frame(height: 34)
                .card(radius: 9)
        }
    }
}

// MARK: - Investment thesis form

struct ThesisView: View {
    @State private var why = "AI infrastructure spending will continue growing, and NVIDIA is positioned to capture a meaningful share."
    @State private var expectation = "Data center revenue remains strong as Blackwell shipments scale over the next year."
    @State private var evidence = "Cloud capex guidance, current chip demand, and NVIDIA’s software ecosystem."
    @State private var invalidation = "Two quarters of slowing data center growth, or major customers shifting spend to their own chips."

    var body: some View {
        ThesisScreen {
            TopBar(title: "Your investment thesis", showsBack: true) { TextAction(title: "Save draft") }
        } content: {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle().fill(Color(hex: 0xE3E9E6))
                    Rectangle().fill(Theme.green).frame(width: geo.size.width * 0.68)
                }
            }
            .frame(height: 3)
            .fullBleed()
            .padding(.bottom, 20)

            CompanyMini(subtitle: "NVIDIA") { Tag("DRAFT", tone: .blue) }

            VStack(alignment: .leading, spacing: 7) {
                Eyebrow("MAKE YOUR THINKING VISIBLE", trackingEm: 0.1)
                Text("What would make this a good decision?")
                    .font(Theme.display(23))
                    .tracking(Theme.tracking(-0.04, 23))
                Text("Your thesis becomes a record you can learn from later—whether the stock goes up or down.")
                    .font(Theme.body(11))
                    .lineSpacing(4)
                    .foregroundStyle(Theme.muted)
            }
            .padding(.top, 25)
            .padding(.bottom, 12)

            ThesisField(label: "Why I’m investing", text: $why)
            ThesisField(label: "What I expect to happen", text: $expectation)
            ThesisField(label: "Evidence supporting my idea", text: $evidence)

            HStack(spacing: 10) {
                SelectField(label: "Time horizon", value: "1–3 years")
                SelectField(label: "Conviction", value: "Moderate")
            }
            .padding(.top, 14)

            ThesisField(label: "What would prove me wrong?", text: $invalidation, highlighted: true)

            HStack(alignment: .top, spacing: 10) {
                Icon(.clock).foregroundStyle(Theme.green)
                VStack(alignment: .leading, spacing: 4) {
                    Text("We’ll revisit this with you").font(Theme.body(11, .bold))
                    Text("THESIS will compare your expectations with what actually happens—without judging the outcome alone.")
                        .font(Theme.body(10))
                        .lineSpacing(3)
                        .foregroundStyle(Theme.muted)
                }
            }
            .padding(13)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.pale, in: RoundedRectangle(cornerRadius: 11, style: .continuous))
            .padding(.top, 16)
        } footer: {
            StickyFooter {
                PrimaryButton(title: "Save thesis & continue") // → trade
            }
        }
    }
}

/// Small company row with a trailing accessory (company-mini).
struct CompanyMini<Trailing: View>: View {
    var title = "NVDA"
    let subtitle: String
    @ViewBuilder var trailing: Trailing

    var body: some View {
        HStack(spacing: 10) {
            StockLogo(size: .small)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(Theme.display(12))
                subtitleView
            }
            Spacer()
            trailing
        }
    }

    private var subtitleView: some View {
        Text(subtitle).font(Theme.body(10)).foregroundStyle(Theme.muted)
    }
}

private struct ThesisField: View {
    let label: String
    @Binding var text: String
    var highlighted = false

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(label).font(Theme.body(10, .bold))
            TextField("", text: $text, axis: .vertical)
                .font(Theme.body(11))
                .lineSpacing(4)
                .lineLimit(3...8)
                .frame(minHeight: 54, alignment: .topLeading)
                .padding(12)
                .card(
                    radius: 11,
                    fill: highlighted ? Color(hex: 0xFFFCF6) : .white,
                    stroke: highlighted ? Color(hex: 0xD9BA82) : Theme.line
                )
        }
        .padding(.top, 14)
    }
}

private struct SelectField: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(label).font(Theme.body(10, .bold))
            Button {} label: {
                HStack {
                    Text(value)
                    Spacer()
                    Icon(.down, size: 16)
                }
                .font(Theme.body(11))
                .padding(.horizontal, 10)
                .frame(height: 42)
                .card(radius: 10)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview("Coach") { CoachView() }
#Preview("Thesis") { ThesisView() }
