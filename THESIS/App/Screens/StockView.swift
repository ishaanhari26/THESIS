import SwiftUI

// MARK: - Discover

struct DiscoverView: View {
    var body: some View {
        ThesisScreen {
            TopBar(title: "Discover") { IconButton(.bell) }
        } content: {
            SearchBoxLabel(placeholder: "Search stocks, topics, or news")
            ScrollView(.horizontal) {
                HStack(spacing: 7) {
                    TopicChip("Trending", selected: true)
                    TopicChip("Technology")
                    TopicChip("Clean energy")
                    TopicChip("ETFs")
                }
            }
            .scrollIndicators(.hidden)
            .padding(.top, 16)
            .padding(.bottom, 0)

            PageSectionTitle("What’s moving")
            featureCard
            PageSectionTitle("Market movers")
            ListCard {
                StockRow(ticker: "PLTR", name: "Palantir", price: "$91.36", change: "+6.12%")
                StockRow(ticker: "AMD", name: "AMD", price: "$112.48", change: "+4.06%")
                StockRow(ticker: "TSLA", name: "Tesla", price: "$238.01", change: "-0.62%", down: true, showsDivider: false)
            }
            PageSectionTitle("Learn as you explore")
            LessonCard(
                number: "01",
                tag: "5 MIN LESSON",
                title: "Revenue is growing. Is that enough?",
                detail: "Learn three questions to ask before buying a growth stock."
            )
        } footer: {
            BottomNav(active: .home)
        }
    }

    private var featureCard: some View {
        Button {} label: { // → stock
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top) {
                    CompanyLockup()
                    Spacer()
                    VStack(alignment: .trailing, spacing: 3) {
                        Text("$121.67").font(Theme.display(13))
                        Text("+3.80% today").font(Theme.body(10)).foregroundStyle(Theme.green2)
                    }
                }
                .padding(.horizontal, 16)

                PriceChart()
                    .padding(.top, 12)

                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Icon(.news, size: 13)
                        Text("WHY IT MOVED")
                    }
                    .font(Theme.body(9, .heavy))
                    .tracking(Theme.tracking(0.08, 9))
                    .foregroundStyle(Theme.green)
                    Text("New Blackwell chip demand estimates and cloud spending updates are driving attention.")
                        .font(Theme.body(12))
                        .lineSpacing(4)
                    HStack(spacing: 5) {
                        Text("Read the full story")
                        Icon(.arrow, size: 15)
                    }
                    .font(Theme.body(11, .bold))
                    .foregroundStyle(Theme.green)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Theme.pale)
            }
            .padding(.top, 16)
            .card(radius: 17)
            .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

/// NVIDIA logo + name + exchange.
struct CompanyLockup: View {
    var largeTitle = false

    var body: some View {
        HStack(spacing: 11) {
            StockLogo()
            VStack(alignment: .leading, spacing: 2) {
                Text("NVIDIA")
                    .font(Theme.display(largeTitle ? 21 : 14))
                Text("NVDA · NASDAQ")
                    .font(Theme.body(10))
                    .foregroundStyle(Theme.muted)
            }
        }
    }
}

/// Numbered lesson teaser (lesson-card / library-path).
struct LessonCard<Footer: View>: View {
    let number: String
    let tag: String
    var tagTone: TagTone = .blue
    let title: String
    let detail: String
    var background = Color(hex: 0xE7EEEC)
    var showsArrow = true
    @ViewBuilder var footer: Footer

    var body: some View {
        HStack(spacing: 15) {
            Text(number)
                .font(.custom("Manrope", size: 25).weight(.heavy))
                .foregroundStyle(Color(hex: 0xB5C6C1))
            VStack(alignment: .leading, spacing: 0) {
                Tag(tag, tone: tagTone)
                Text(title)
                    .font(Theme.display(14))
                    .padding(.top, 7)
                    .padding(.bottom, 4)
                Text(detail)
                    .font(Theme.body(11))
                    .lineSpacing(3)
                    .foregroundStyle(Theme.muted)
                footer
            }
            Spacer(minLength: 0)
            if showsArrow { Icon(.arrow) }
        }
        .padding(18)
        .background(background, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
    }
}

extension LessonCard where Footer == EmptyView {
    init(number: String, tag: String, tagTone: TagTone = .blue, title: String, detail: String,
         background: Color = Color(hex: 0xE7EEEC), showsArrow: Bool = true) {
        self.init(number: number, tag: tag, tagTone: tagTone, title: title, detail: detail,
                  background: background, showsArrow: showsArrow, footer: { EmptyView() })
    }
}

// MARK: - Stock detail

struct StockView: View {
    @State private var range = "1W"

    var body: some View {
        ThesisScreen {
            TopBar(showsBack: true) {
                IconButton(.bell)
                IconButton(.more)
            }
        } content: {
            HStack {
                CompanyLockup(largeTitle: true)
                Spacer()
                Button {} label: {
                    HStack(spacing: 5) {
                        Icon(.check, size: 15)
                        Text("Watching")
                    }
                    .font(Theme.body(10))
                    .foregroundStyle(Theme.green)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(Capsule().fill(.white))
                    .overlay(Capsule().strokeBorder(Theme.line))
                }
            }
            .padding(.top, 5)

            VStack(alignment: .leading, spacing: 2) {
                Text("$121.67").font(Theme.display(30))
                HStack(spacing: 2) {
                    Icon(.up, size: 13)
                    Text("$4.45 (3.80%) today")
                }
                .font(Theme.body(11))
                .foregroundStyle(Theme.green2)
            }
            .padding(.top, 21)

            PriceChart().padding(.top, 18)

            UnderlineTabs(options: ["1D", "1W", "1M", "3M", "1Y", "5Y"], selection: $range)

            HStack(spacing: 4) {
                Circle().fill(Color(hex: 0x62A596)).frame(width: 6, height: 6)
                Text("Market open · Price delayed by up to 15 min")
            }
            .font(Theme.body(9))
            .foregroundStyle(Theme.muted)
            .frame(maxWidth: .infinity)
            .padding(.top, 10)
            .padding(.bottom, 24)

            watchSection
            hypeCheck
            recentContext
            communityPreview
        } footer: {
            StickyFooter {
                HStack(spacing: 10) {
                    SecondaryButton(title: "Sell")
                        .frame(width: 120)
                    PrimaryButton(title: "Buy NVDA", showsArrow: false) // → coach
                }
            }
        }
    }

    private var watchSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Eyebrow("THESIS BRIEF")
            Text("Why investors are watching this")
                .font(Theme.display(23))
                .tracking(Theme.tracking(-0.04, 23))
                .padding(.top, 5)
                .padding(.bottom, 8)
            Text("NVIDIA sits at the center of the AI infrastructure buildout. Demand remains strong, but expectations are already high.")
                .font(Theme.body(12))
                .lineSpacing(4)
                .foregroundStyle(Theme.muted)
                .padding(.bottom, 6)

            CaseCard(
                bull: true,
                title: "Bull case",
                detail: "Cloud providers continue increasing AI spending, while NVIDIA’s Blackwell chips remain supply-constrained.",
                link: "View supporting evidence"
            )
            CaseCard(
                bull: false,
                title: "Bear case",
                detail: "Its valuation assumes rapid growth. Slower data-center spending or stronger competition could challenge that story.",
                link: "View key risks"
            )

            VStack(alignment: .leading, spacing: 0) {
                Tag("WHAT COULD CHANGE THE STORY?", tone: .gold)
                    .padding(.bottom, 12)
                ForEach([
                    ("Mar 26", "Developer conference product updates"),
                    ("May 28", "Next estimated earnings report"),
                    ("Ongoing", "Blackwell delivery and margin data"),
                ], id: \.0) { date, event in
                    HStack(alignment: .firstTextBaseline, spacing: 0) {
                        Text(date)
                            .font(Theme.body(11, .bold))
                            .foregroundStyle(Theme.goldText)
                            .frame(width: 70, alignment: .leading)
                        Text(event).font(Theme.body(11))
                    }
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .topDivider(Color(hex: 0xEDE3D0))
                }
            }
            .padding(15)
            .card(radius: 13, fill: Color(hex: 0xFFFAF0), stroke: Color(hex: 0xEADCC1))
            .padding(.top, 10)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: 0xF0F5F2))
        .topDivider()
        .overlay(alignment: .bottom) { Rectangle().fill(Theme.line).frame(height: 1) }
        .fullBleed()
    }

    private var hypeCheck: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeading("Hype check", action: "How this works")
            VStack(alignment: .leading, spacing: 14) {
                HypeMetric(label: "Social attention", level: "Very high", fraction: 0.94, color: Theme.gold)
                HypeMetric(label: "Price movement", level: "High", fraction: 0.77, color: Theme.green2)
                HypeMetric(label: "Fundamental change", level: "Moderate", fraction: 0.52, color: Color(hex: 0x688BA0))
                HypeMetric(label: "Confirmed news", level: "Low", fraction: 0.28, color: Color(hex: 0x9BA6A3))
                HStack(alignment: .top, spacing: 9) {
                    Icon(.spark).foregroundStyle(Theme.green)
                    Text("Would you still invest if the stock had not risen this week?")
                        .font(Theme.display(12, .semibold))
                        .lineSpacing(4)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Theme.pale, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .padding(16)
            .card(radius: 15)
        }
    }

    private var recentContext: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeading("Recent context", action: "See all")
            ContextItem(day: "18", tag: "CONFIRMED NEWS", tone: .green,
                        title: "Major cloud providers signal sustained AI infrastructure spending", source: "Reuters · 2h ago")
            ContextItem(day: "17", tag: "MARKET CONTEXT", tone: .neutral,
                        title: "Semiconductor index rises as rate expectations ease", source: "Market Brief · Yesterday")
        }
    }

    private var communityPreview: some View {
        Button {} label: {
            HStack(spacing: 11) {
                HStack(spacing: -8) {
                    ForEach(["JL", "AM", "SR"], id: \.self) { initials in
                        Text(initials)
                            .font(Theme.body(7))
                            .frame(width: 27, height: 27)
                            .background(Circle().fill(Color(hex: 0xC6DDD6)))
                            .overlay(Circle().strokeBorder(.white, lineWidth: 2))
                    }
                }
                .frame(width: 60, alignment: .leading)
                VStack(alignment: .leading, spacing: 3) {
                    Text("1,284 people discussing NVDA").font(Theme.body(10, .bold))
                    Text("Top post: “Is demand durable past 2026?”").font(Theme.body(10)).foregroundStyle(Theme.muted)
                }
                Spacer(minLength: 0)
                Icon(.arrow)
            }
            .padding(13)
            .card(radius: 13, fill: .clear)
        }
        .padding(.top, 20)
    }
}

private struct CaseCard: View {
    let bull: Bool
    let title: String
    let detail: String
    let link: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            IconTile(
                icon: bull ? .up : .down,
                side: 28,
                iconSize: 20,
                foreground: bull ? Theme.green : Theme.red,
                background: bull ? Color(hex: 0xE5F1ED) : Color(hex: 0xF8E9E6)
            )
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .font(Theme.display(14))
                    .padding(.top, 2)
                    .padding(.bottom, 5)
                Text(detail)
                    .font(Theme.body(11))
                    .lineSpacing(3)
                    .foregroundStyle(Theme.muted)
                    .padding(.bottom, 8)
                TextLink(title: link, size: 10, icon: .down)
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(.white, in: RoundedRectangle(cornerRadius: 13, style: .continuous))
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(bull ? Theme.green2 : Theme.red)
                .frame(width: 3)
        }
        .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
        .padding(.top, 10)
    }
}

private struct HypeMetric: View {
    let label: String
    let level: String
    let fraction: CGFloat
    let color: Color

    var body: some View {
        VStack(spacing: 7) {
            HStack {
                Text(label).font(Theme.body(11))
                Spacer()
                Text(level).font(Theme.body(10, .bold))
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color(hex: 0xE9EEEC))
                    Capsule().fill(color).frame(width: geo.size.width * fraction)
                }
            }
            .frame(height: 5)
        }
    }
}

private struct ContextItem: View {
    let day: String
    let tag: String
    let tone: TagTone
    let title: String
    let source: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 0) {
                Text(day).font(Theme.body(16, .bold))
                Text("MAR").font(Theme.body(8)).foregroundStyle(Theme.muted)
            }
            .frame(width: 42, height: 48)
            .card(radius: 8, fill: .clear)
            VStack(alignment: .leading, spacing: 0) {
                Tag(tag, tone: tone)
                Text(title)
                    .font(Theme.display(12))
                    .lineSpacing(3)
                    .padding(.top, 7)
                    .padding(.bottom, 3)
                Text(source).font(Theme.body(9)).foregroundStyle(Theme.muted)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 14)
        .rowDivider(color: Theme.line)
    }
}

#Preview("Discover") { DiscoverView() }
#Preview("Stock") { StockView() }
