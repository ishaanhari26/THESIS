import SwiftUI

// MARK: - Learn

struct LearnView: View {
    enum Pane: String, CaseIterable {
        case coach = "Coach"
        case education = "Education"
        case stockSim = "StockSim"

        var icon: ThesisIcon {
            switch self {
            case .coach: .spark
            case .education: .play
            case .stockSim: .pie
            }
        }
    }

    @State private var section: Pane
    @State private var query = ""
    @State private var simStarting = "10000"

    init(section: Pane = .education) {
        _section = State(initialValue: section)
    }

    var body: some View {
        ThesisScreen {
            TopBar(title: "Learn") { IconButton(.bell) }
        } content: {
            SegmentedPills(
                options: Pane.allCases,
                selection: $section,
                height: 39,
                fontSize: 9,
                activeColor: Theme.green,
                inactiveColor: Theme.muted
            ) { item in
                AnyView(HStack(spacing: 5) {
                    Icon(item.icon, size: 15)
                    Text(item.rawValue)
                })
            }
            .padding(.top, 4)
            .padding(.bottom, 20)

            switch section {
                case .coach: coachSection
                case .education: educationSection
                case .stockSim: StockSimSection(simStarting: $simStarting)
            }
        } footer: {
            BottomNav(active: .learn)
        }
    }

    // MARK: Coach

    private var coachSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(spacing: 0) {
                CoachOrb().padding(.bottom, 8)
                Tag("CHALLENGE MODE", tone: .green)
                Text("Improve the thinking behind your trades.")
                    .font(Theme.display(23))
                    .tracking(Theme.tracking(-0.04, 23))
                    .multilineTextAlignment(.center)
                    .padding(.top, 10)
                    .padding(.bottom, 7)
                Text("THESIS Coach helps you examine evidence, uncover assumptions, and understand what could prove you wrong.")
                    .font(Theme.body(10))
                    .lineSpacing(3)
                    .foregroundStyle(Theme.muted)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 16)
                PrimaryButton(title: "Open THESIS Coach") // → coach
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 18)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(colors: [Color(hex: 0xEDF6F2), Color(hex: 0xF8FAF8)], startPoint: .topLeading, endPoint: .bottomTrailing),
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(Color(hex: 0xCDE0DA)))

            SectionHeading("Ways Coach can help", action: "Coach settings")
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 9), GridItem(.flexible())], spacing: 9) {
                CoachTool(icon: .spark, title: "Challenge a thesis", detail: "Pressure-test why you want to invest.") // → coach
                CoachTool(icon: .wallet, title: "Review spending", detail: "Understand habits across your accounts.") // → moneyCoach
                CoachTool(icon: .shield, title: "Check portfolio risk", detail: "See concentration and scenario impact.")
                CoachTool(icon: .news, title: "Explain market news", detail: "Separate confirmed facts from attention.")
            }

            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    Eyebrow("RECENT COACH SESSION", size: 7)
                    Text("Your NVIDIA reasoning")
                        .font(Theme.display(11))
                        .padding(.top, 4)
                        .padding(.bottom, 2)
                    Text("3 assumptions identified · Thesis saved")
                        .font(Theme.body(8))
                        .foregroundStyle(Theme.muted)
                }
                Spacer()
                Tag("CONTINUE", tone: .green)
            }
            .padding(14)
            .card(radius: 12)
            .padding(.top, 18)
        }
    }

    // MARK: Education

    private var filteredLessons: [LessonItem] {
        sampleLessons.filter { "\($0.title) \($0.category)".localizedCaseInsensitiveContains(query) }
    }

    private var educationSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 6) {
                Eyebrow("THESIS ACADEMY", size: 8, trackingEm: 0.1)
                Text("Learn the decision, then practice the trade.")
                    .font(Theme.display(23))
                    .tracking(Theme.tracking(-0.04, 23))
                Text("Short, practical lessons without promises, hype, or jargon.")
                    .font(Theme.body(10))
                    .foregroundStyle(Theme.muted)
            }
            .padding(.top, 6)
            .padding(.bottom, 14)

            SearchField(placeholder: "Search the video library...", text: $query)
                .padding(.bottom, 14)

            if !query.isEmpty { searchResults }

            featuredLesson

            SectionHeading("Explore by asset", action: "View all") // → library
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 9), GridItem(.flexible())], spacing: 9) {
                AssetLesson(symbol: "STK", icon: .up, color: Color(hex: 0x2E756B), title: "Stocks", detail: "Ownership, valuation, earnings", count: "8 lessons")
                AssetLesson(symbol: "ETF", icon: .pie, color: Color(hex: 0x4F7087), title: "ETFs", detail: "Funds, fees, diversification", count: "6 lessons")
                AssetLesson(symbol: "₿", icon: .up, color: Color(hex: 0xB47B36), title: "Crypto", detail: "Networks, custody, volatility", count: "7 lessons")
                AssetLesson(symbol: "BND", icon: .down, color: Color(hex: 0x765D89), title: "Bonds", detail: "Yield, rates, credit risk", count: "5 lessons")
            }

            SectionHeading("Practice with a live demo", action: "How demos work")
            liveDemoCard

            SectionHeading("Continue learning", action: "See library") // → library
            ScrollView(.horizontal) {
                HStack(alignment: .top, spacing: 10) {
                    ForEach(sampleLessons.prefix(3), id: \.self) { VideoCard(lesson: $0) }
                }
                .padding(.horizontal, 20)
            }
            .scrollIndicators(.hidden)
            .fullBleed()
        }
    }

    private var searchResults: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("\(filteredLessons.count) matching lessons").font(Theme.display(14))
                Spacer()
                Button {} label: { // → library
                    HStack(spacing: 3) {
                        Text("Full library")
                        Icon(.arrow, size: 14)
                    }
                    .font(Theme.body(8))
                    .foregroundStyle(Theme.green)
                }
            }
            .padding(.bottom, 2)

            let shown = Array(filteredLessons.prefix(3))
            ForEach(shown, id: \.self) { lesson in
                VideoResultRow(lesson: lesson, showsDivider: lesson != shown.last)
            }
            if filteredLessons.isEmpty {
                Text("No lessons match “\(query)”.")
                    .font(Theme.body(9))
                    .foregroundStyle(Theme.muted)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
        .card(radius: 13, fill: Color(hex: 0xF7FAF8))
        .padding(.bottom, 14)
    }

    private var featuredLesson: some View {
        Button {} label: {
            VStack(alignment: .leading, spacing: 0) {
                ZStack {
                    LinearGradient(colors: [Theme.ink, Color(hex: 0x276E63)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    DecorRings(diameter: 190, opacity: 0.125, spread: false)
                        .offset(x: 30, y: -100)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    DecorRings(diameter: 120, opacity: 0.125, spread: false)
                        .offset(x: -40, y: 70)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                    Icon(.play, size: 23)
                        .foregroundStyle(Theme.green)
                        .frame(width: 48, height: 48)
                        .background(Circle().fill(Color.white.opacity(0.93)))
                    Tag("START HERE", tone: .green)
                        .padding(13)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    Text("12:08")
                        .font(Theme.body(8))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color(hex: 0x0D211F, alpha: 0.81), in: RoundedRectangle(cornerRadius: 5))
                        .padding(.trailing, 12)
                        .padding(.bottom, 10)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                }
                .frame(height: 145)
                .clipped()

                VStack(alignment: .leading, spacing: 0) {
                    Eyebrow("INVESTING FOUNDATIONS", size: 8)
                    Text("What are you really buying?")
                        .font(Theme.display(16))
                        .padding(.top, 6)
                        .padding(.bottom, 4)
                    Text("Learn how stocks, ETFs, crypto, and bonds differ before choosing what fits your goal.")
                        .font(Theme.body(10))
                        .lineSpacing(3)
                        .foregroundStyle(Theme.muted)
                        .padding(.bottom, 9)
                    HStack(spacing: 4) {
                        Text("Watch lesson")
                        Icon(.arrow, size: 15)
                    }
                    .font(Theme.body(9, .bold))
                    .foregroundStyle(Theme.green)
                }
                .padding(15)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .card(radius: 15)
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        }
    }

    private var liveDemoCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color(hex: 0x62C6AD))
                        .frame(width: 6, height: 6)
                        .background(Circle().fill(Color(hex: 0x62C6AD, alpha: 0.15)).padding(-3))
                    Text("LIVE MARKET DEMO")
                }
                .font(Theme.body(8, .heavy))
                .tracking(Theme.tracking(0.08, 8))
                .foregroundStyle(Color(hex: 0x9FC9BE))
                Spacer()
                Tag("NO REAL MONEY", tone: .blue)
            }

            HStack(spacing: 9) {
                TickerIcon(ticker: "VOO")
                VStack(alignment: .leading, spacing: 3) {
                    Text("Practice buying an ETF").font(Theme.body(11, .bold))
                    Text("Vanguard S&P 500 ETF · VOO").font(Theme.body(8)).foregroundStyle(Color(hex: 0x9FB0AD))
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 3) {
                    Text("$526.14").font(Theme.display(11))
                    Text("+0.42%").font(Theme.body(8)).foregroundStyle(Color(hex: 0x77C4B1))
                }
            }
            .padding(.top, 17)
            .padding(.bottom, 12)

            Text("Follow a guided example using a $25 practice order. Choose dollars or shares, compare order types, and preview portfolio impact.")
                .font(Theme.body(9))
                .lineSpacing(3)
                .foregroundStyle(Color(hex: 0xAEC0BC))
                .padding(.bottom, 12)

            Button {} label: {
                HStack(spacing: 6) {
                    Text("Start guided demo")
                    Icon(.arrow, size: 16)
                }
                .font(Theme.body(9, .bold))
                .frame(maxWidth: .infinity)
                .frame(height: 38)
                .card(radius: 9, fill: Color.white.opacity(0.063), stroke: Color.white.opacity(0.125))
            }
        }
        .foregroundStyle(.white)
        .padding(14)
        .background(Color(hex: 0x172F2D), in: RoundedRectangle(cornerRadius: 15, style: .continuous))
    }
}

private struct CoachTool: View {
    let icon: ThesisIcon
    let title: String
    let detail: String

    var body: some View {
        Button {} label: {
            VStack(alignment: .leading, spacing: 0) {
                IconTile(icon: icon)
                Text(title)
                    .font(Theme.body(10, .bold))
                    .padding(.top, 10)
                Text(detail)
                    .font(Theme.body(8))
                    .lineSpacing(2)
                    .foregroundStyle(Theme.muted)
                    .padding(.top, 3)
                    .padding(.trailing, 18)
                Spacer(minLength: 0)
            }
            .padding(13)
            .frame(maxWidth: .infinity, minHeight: 134, alignment: .topLeading)
            .overlay(alignment: .bottomTrailing) {
                Icon(.arrow, size: 14).foregroundStyle(Theme.green).padding(12)
            }
            .card(radius: 12)
        }
    }
}

private struct AssetLesson: View {
    let symbol: String
    let icon: ThesisIcon
    let color: Color
    let title: String
    let detail: String
    let count: String

    var body: some View {
        Button {} label: {
            HStack(spacing: 9) {
                VStack(spacing: 2) {
                    Text(symbol).font(Theme.body(9, .bold))
                    Icon(icon, size: 14)
                }
                .foregroundStyle(.white)
                .frame(width: 39, height: 48)
                .background(color, in: RoundedRectangle(cornerRadius: 9, style: .continuous))
                VStack(alignment: .leading, spacing: 3) {
                    Text(title).font(Theme.body(10, .bold))
                    Text(detail).font(Theme.body(7)).foregroundStyle(Theme.muted).lineLimit(2)
                    Text(count).font(Theme.body(7)).foregroundStyle(Theme.green)
                }
                Spacer(minLength: 0)
            }
            .padding(11)
            .card(radius: 12)
        }
    }
}

// MARK: - StockSim section

private struct StockSimSection: View {
    @Binding var simStarting: String

    private var startingValue: Double { max(Double(simStarting) ?? 0, 0) }
    private var simGain: Double { startingValue * 0.0284 }
    private var simCash: Double { startingValue * 0.318 }

    private func money(_ value: Double, fixed: Bool = false) -> String {
        "$" + value.formatted(.number.precision(.fractionLength(fixed ? 2...2 : 0...2)))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 0) {
                    Eyebrow("FAKE MONEY · REAL MARKET DATA", size: 7)
                    Text("StockSim Portfolio")
                        .font(Theme.display(23))
                        .tracking(Theme.tracking(-0.04, 23))
                        .padding(.top, 5)
                        .padding(.bottom, 4)
                    Text("Practice decisions and learn from outcomes without risking real money.")
                        .font(Theme.body(9))
                        .foregroundStyle(Theme.muted)
                        .padding(.trailing, 18)
                }
                Spacer(minLength: 0)
                Tag("MARKET OPEN", tone: .green).padding(.top, 3)
            }
            .padding(.top, 5)
            .padding(.bottom, 15)

            startingControl
            portfolioCard

            HStack(spacing: 7) {
                SimStat(label: "Buying power", value: money(simCash))
                SimStat(label: "Invested", value: money(startingValue - simCash + simGain))
                SimStat(label: "Today", value: "+$42.16", valueColor: Theme.green2)
            }
            .padding(.top, 9)

            HStack(spacing: 7) {
                SimAction(icon: .search, title: "Find a stock")
                SimAction(icon: .send, title: "Practice trade")
                SimAction(icon: .clock, title: "Order history")
            }
            .padding(.top, 10)

            SectionHeading("Your simulated positions", action: "Allocation")
            ListCard(horizontalPadding: 12, radius: 13) {
                SimPosition(ticker: "VOO", name: "S&P 500 ETF", shares: "6.42 shares", value: "$3,377.82", change: "+4.21%")
                SimPosition(ticker: "NVDA", name: "NVIDIA", shares: "12.5 shares", value: "$1,520.88", change: "+8.42%")
                SimPosition(ticker: "AAPL", name: "Apple", shares: "8.1 shares", value: "$1,734.21", change: "-1.08%", down: true, showsDivider: false)
            }

            missionCard

            SectionHeading("Practice watchlist", action: "Edit")
            ListCard {
                StockRow(ticker: "AMD", name: "AMD", price: "$112.48", change: "+4.06%")
                StockRow(ticker: "TSLA", name: "Tesla", price: "$238.01", change: "-0.62%", down: true)
                StockRow(ticker: "PLTR", name: "Palantir", price: "$91.36", change: "+6.12%", showsDivider: false)
            }

            HStack(alignment: .top, spacing: 8) {
                Icon(.shield, size: 17).foregroundStyle(Theme.green)
                Text("StockSim uses fake money and delayed market data. Performance here does not predict real-world results.")
                    .font(Theme.body(7))
                    .lineSpacing(2)
                    .foregroundStyle(Theme.muted)
            }
            .padding(.horizontal, 4)
            .padding(.top, 16)
        }
    }

    private var startingControl: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Simulation starting amount").font(Theme.body(9, .bold))
                Text("Set any practice balance").font(Theme.body(7)).foregroundStyle(Theme.muted)
            }
            Spacer()
            HStack(spacing: 2) {
                Text("$").foregroundStyle(Theme.green)
                TextField("0", text: $simStarting)
                    .keyboardType(.numberPad)
                    .onChange(of: simStarting) { _, new in
                        let digits = new.filter(\.isNumber)
                        if digits != new { simStarting = digits }
                    }
            }
            .font(Theme.display(11))
            .padding(.horizontal, 9)
            .frame(width: 118, height: 35)
            .card(radius: 8, fill: Theme.pale)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
        .card(radius: 12)
        .padding(.bottom, 10)
    }

    private var portfolioCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("SIMULATED PORTFOLIO")
                    .font(Theme.body(7, .bold))
                    .tracking(Theme.tracking(0.08, 7))
                Spacer()
                Icon(.more)
            }
            .foregroundStyle(Color(hex: 0xAABBB7))

            Text(money(startingValue + simGain, fixed: true))
                .font(Theme.display(26))
                .foregroundStyle(.white)
                .padding(.top, 5)

            HStack(spacing: 2) {
                Icon(.up, size: 12)
                Text("+\(money(simGain)) (2.84%) all time")
            }
            .font(Theme.body(8))
            .foregroundStyle(Color(hex: 0x79C3B0))

            SVGPath("M0 66 C22 61 37 67 55 54 S87 57 106 42 S142 51 163 35 S194 41 219 25 S253 31 276 17 S319 18 350 5",
                    viewBox: CGSize(width: 350, height: 78))
                .stroke(Color(hex: 0x6BB5A2), lineWidth: 2)
                .frame(height: 70)
                .padding(.horizontal, -15)
                .padding(.top, 3)

            HStack {
                ForEach(["1D", "1W", "1M", "ALL"], id: \.self) { range in
                    Text(range)
                        .font(Theme.body(7, range == "ALL" ? .bold : .regular))
                        .foregroundStyle(range == "ALL" ? .white : Color(hex: 0x899B97))
                        .frame(maxWidth: .infinity)
                        .padding(.top, 7)
                        .padding(.bottom, 2)
                }
            }
            .topDivider(Color.white.opacity(0.07))
        }
        .padding(.horizontal, 15)
        .padding(.top, 15)
        .padding(.bottom, 10)
        .background(Theme.ink, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
    }

    private var missionCard: some View {
        HStack(spacing: 13) {
            ZStack {
                RingProgress(progress: 0.5, lineWidth: 4, track: Color(hex: 0xD5DFDC))
                Text("2/4").font(Theme.body(9, .bold))
            }
            .frame(width: 51, height: 51)
            VStack(alignment: .leading, spacing: 0) {
                Tag("LEARNING MISSION", tone: .blue)
                Text("Build a diversified practice portfolio")
                    .font(Theme.display(11))
                    .padding(.top, 6)
                    .padding(.bottom, 3)
                Text("Add a fourth position without letting one stock exceed 25%.")
                    .font(Theme.body(8))
                    .foregroundStyle(Theme.muted)
                    .padding(.bottom, 6)
                TextLink(title: "Continue mission", size: 8)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .card(radius: 13, fill: Color(hex: 0xF0F4F8), stroke: Color(hex: 0xCFDBEB))
        .padding(.top, 13)
    }
}

private struct SimStat: View {
    let label: String
    let value: String
    var valueColor: Color = Theme.ink

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(Theme.body(7)).foregroundStyle(Theme.muted)
            Text(value).font(Theme.body(9, .bold)).foregroundStyle(valueColor).lineLimit(1).minimumScaleFactor(0.7)
        }
        .padding(9)
        .frame(maxWidth: .infinity, alignment: .leading)
        .card(radius: 10)
    }
}

private struct SimAction: View {
    let icon: ThesisIcon
    let title: String

    var body: some View {
        Button {} label: {
            VStack(spacing: 4) {
                Icon(icon, size: 16)
                Text(title).font(Theme.body(7, .bold))
            }
            .foregroundStyle(Theme.green)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .card(radius: 10, fill: Color(hex: 0xEBF4F1), stroke: Color(hex: 0xC9DDD7))
        }
    }
}

private struct SimPosition: View {
    let ticker: String
    let name: String
    let shares: String
    let value: String
    let change: String
    var down = false
    var showsDivider = true

    var body: some View {
        Button {} label: {
            HStack(spacing: 8) {
                TickerIcon(ticker: ticker)
                VStack(alignment: .leading, spacing: 2) {
                    Text(ticker).font(Theme.body(9, .bold))
                    Text("\(name) · \(shares)").font(Theme.body(7)).foregroundStyle(Theme.muted).lineLimit(1)
                }
                .frame(width: 104, alignment: .leading)
                Spacer(minLength: 0)
                Sparkline(down: down, width: 48, compact: true)
                VStack(alignment: .trailing, spacing: 2) {
                    Text(value).font(Theme.body(9, .bold))
                    Text(change).font(Theme.body(7)).foregroundStyle(down ? Theme.red : Theme.green2)
                }
                .frame(minWidth: 60, alignment: .trailing)
            }
            .padding(.vertical, 11)
            .rowDivider(showsDivider)
            .contentShape(Rectangle())
        }
    }
}

// MARK: - Video library

struct VideoLibraryView: View {
    @State private var query = ""
    @State private var category = "All"

    private var visibleLessons: [LessonItem] {
        sampleLessons.filter {
            (category == "All" || $0.category == category)
                && (query.isEmpty || "\($0.title) \($0.category)".localizedCaseInsensitiveContains(query))
        }
    }

    var body: some View {
        ThesisScreen {
            TopBar(title: "Video library", showsBack: true) { IconButton(.more) }
        } content: {
            VStack(alignment: .leading, spacing: 0) {
                Eyebrow("THESIS ACADEMY", size: 8, trackingEm: 0.1)
                Text("All lessons")
                    .font(Theme.display(26))
                    .tracking(Theme.tracking(-0.04, 26))
                    .padding(.top, 5)
                    .padding(.bottom, 4)
                Text("Build investing skills at your own pace with practical, prerecorded tutorials.")
                    .font(Theme.body(10))
                    .lineSpacing(3)
                    .foregroundStyle(Theme.muted)
            }
            .padding(.top, 15)
            .padding(.bottom, 17)

            SearchField(placeholder: "Search all videos...", text: $query)

            FilterPills(options: ["All", "Stocks", "ETFs", "Crypto", "Bonds"], selection: $category, fontSize: 8)
                .padding(.top, 11)

            HStack {
                Text("\(visibleLessons.count) lessons").font(Theme.body(9, .bold))
                Spacer()
                Button {} label: {
                    HStack(spacing: 4) {
                        Text("Sort: Recommended")
                        Icon(.down, size: 13)
                    }
                    .font(Theme.body(8))
                    .foregroundStyle(Theme.green)
                }
            }
            .padding(.top, 15)
            .padding(.bottom, 5)
            .rowDivider(color: Theme.line)

            ForEach(visibleLessons, id: \.self) { lesson in
                VideoResultRow(lesson: lesson)
            }
            if visibleLessons.isEmpty {
                VStack(spacing: 0) {
                    Icon(.search, size: 28)
                    Text("No lessons found")
                        .font(Theme.display(13))
                        .foregroundStyle(Theme.ink)
                        .padding(.top, 10)
                        .padding(.bottom, 4)
                    Text("Try a different topic or category.").font(Theme.body(9))
                }
                .foregroundStyle(Theme.muted)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 48)
            }

            LessonCard(
                number: "01",
                tag: "RECOMMENDED PATH",
                tagTone: .green,
                title: "New to investing?",
                detail: "Start with our six-part foundations course and finish with a guided StockSim trade.",
                background: Color(hex: 0xE9F2EF),
                showsArrow: false
            ) {
                TextLink(title: "View learning path", size: 8).padding(.top, 6)
            }
            .padding(.top, 22)
        }
    }
}

#Preview("Learn – Education") { LearnView() }
#Preview("Learn – Coach") { LearnView(section: .coach) }
#Preview("Learn – StockSim") { LearnView(section: .stockSim) }
#Preview("Video library") { VideoLibraryView() }
