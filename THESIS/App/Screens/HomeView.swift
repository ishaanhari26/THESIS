import SwiftUI

struct HomeView: View {
    var body: some View {
        ThesisScreen {
            TopBar()
        } content: {
            greeting
            Button {} label: { SearchBoxLabel(placeholder: "Search stocks, ETFs, or market topics") } // → stock search
                .padding(.bottom, 12)
            balanceCards
            SectionHeading("Today’s focus", action: "Search stocks")
            focusCard
            SectionHeading("Your watchlist", action: "View all")
            ListCard {
                StockRow(ticker: "AAPL", name: "Apple", price: "$214.10", change: "+1.24%")
                StockRow(ticker: "NVDA", name: "NVIDIA", price: "$121.67", change: "+3.80%") // → stock
                StockRow(ticker: "TSLA", name: "Tesla", price: "$238.01", change: "-0.62%", down: true, showsDivider: false)
            }
            SectionHeading("Worth understanding", action: "All news")
            newsCard
        } footer: {
            BottomNav(active: .home)
        }
    }

    private var greeting: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("TUESDAY, MARCH 18")
                    .font(Theme.body(12))
                    .tracking(Theme.tracking(0.08, 12))
                    .foregroundStyle(Theme.muted)
                Text("Good morning, Maya.")
                    .font(Theme.display(24))
                    .tracking(Theme.tracking(-0.04, 24))
            }
            Spacer()
            Avatar("MK")
        }
        .padding(.top, 12)
        .padding(.bottom, 20)
    }

    private var balanceCards: some View {
        HStack(spacing: 10) {
            BalanceCard(
                title: "Portfolio value", icon: .pie, amount: "$1,259.62", background: Theme.ink, footer: "Invested assets"
            ) {
                HStack(spacing: 2) {
                    Icon(.up, size: 11)
                    Text("7.16% all time")
                }
                .font(Theme.body(8))
                .foregroundStyle(Color(hex: 0x95CBBD))
                .padding(.top, 2)

                SVGPath("M0 30 C16 27 24 30 38 23 S62 25 76 17 S100 19 113 11 S139 12 160 3", viewBox: CGSize(width: 160, height: 34))
                    .stroke(Color(hex: 0x64AA99), lineWidth: 1.8)
                    .frame(height: 35)
                    .padding(.horizontal, -14)
                    .padding(.top, 8)
            } // → portfolio

            BalanceCard(
                title: "Money balance", icon: .wallet, amount: "$4,382.71", background: Theme.tealCard, footer: "Money Hub"
            ) {
                Text("Across 5 accounts")
                    .font(Theme.body(8))
                    .foregroundStyle(Color(hex: 0x95CBBD))
                    .padding(.top, 2)
                HStack(spacing: -5) {
                    ForEach([0x5B8CBA, 0x7E5B91, 0x3185D5], id: \.self) { hex in
                        Circle()
                            .fill(Color(hex: UInt32(hex)))
                            .overlay(Circle().strokeBorder(Theme.tealCard, lineWidth: 2))
                            .frame(width: 19, height: 19)
                    }
                    Text("All accounts synced")
                        .font(Theme.body(7))
                        .foregroundStyle(Color(hex: 0xBCD2CD))
                        .lineLimit(1)
                        .padding(.leading, 14)
                }
                .padding(.top, 19)
            } // → wallet
        }
    }

    private var focusCard: some View {
        Button {} label: { // → stock
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .leading) {
                    LinearGradient(colors: [Color(hex: 0x153B36), Color(hex: 0x256E63)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    DecorRings()
                        .offset(x: 28, y: -62)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    StockLogo().padding(20)
                    HStack(spacing: 2) {
                        Icon(.up, size: 11)
                        Text("8.4% this week")
                    }
                    .font(Theme.body(10))
                    .foregroundStyle(Color(hex: 0xD2EDE5))
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(Color.white.opacity(0.08)))
                    .overlay(Capsule().strokeBorder(Color.white.opacity(0.125)))
                    .padding(15)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                }
                .frame(height: 94)
                .clipped()

                VStack(alignment: .leading, spacing: 0) {
                    Tag("TRENDING", tone: .gold)
                    Text("NVIDIA is moving. Do you know why?")
                        .font(Theme.display(17))
                        .lineSpacing(4)
                        .padding(.top, 10)
                        .padding(.bottom, 6)
                    Text("AI demand is only one part of the story. See what changed—and what didn’t.")
                        .font(Theme.body(12))
                        .lineSpacing(4)
                        .foregroundStyle(Theme.muted)
                        .padding(.bottom, 12)
                    HStack(spacing: 5) {
                        Text("Understand the move")
                        Icon(.arrow, size: 16)
                    }
                    .font(Theme.body(12, .bold))
                    .foregroundStyle(Theme.green)
                }
                .padding(16)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .card(radius: 17)
            .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var newsCard: some View {
        HStack(spacing: 14) {
            Text("THE\nMARKET\nBRIEF")
                .font(.custom("Manrope", size: Theme.scaled(13)).weight(.heavy))
                .foregroundStyle(Color(hex: 0x374D48))
                .padding(12)
                .frame(width: 100, height: 92, alignment: .bottomLeading)
                .background(Color(hex: 0xE8DDD0), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            VStack(alignment: .leading, spacing: 6) {
                Eyebrow("4 MIN READ", color: Theme.muted)
                Text("Why chip stocks rallied after the latest cloud spending data")
                    .font(Theme.display(13))
                    .lineSpacing(3)
                Text("Reuters · 1h ago")
                    .font(Theme.body(10))
                    .foregroundStyle(Theme.muted)
            }
            Spacer(minLength: 0)
        }
        .padding(10)
        .card(radius: 15)
    }
}

/// One of the two dark summary cards at the top of Home.
private struct BalanceCard<Middle: View>: View {
    let title: String
    let icon: ThesisIcon
    let amount: String
    let background: Color
    let footer: String
    @ViewBuilder let middle: Middle

    var body: some View {
        Button {} label: {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(title).font(Theme.body(9))
                    Spacer()
                    Icon(icon, size: 17)
                }
                .foregroundStyle(Color(hex: 0xB8C7C4))

                Text(amount)
                    .font(Theme.display(20))
                    .tracking(Theme.tracking(-0.04, 20))
                    .foregroundStyle(.white)
                    .padding(.top, 8)

                middle

                Spacer(minLength: 0)

                HStack {
                    Text(footer)
                    Spacer()
                    Icon(.arrow, size: 14)
                }
                .font(Theme.body(8))
                .foregroundStyle(Color(hex: 0xDBE7E4))
                .padding(.top, 8)
                .topDivider(Color.white.opacity(0.094))
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 168)
            .background(background, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

#Preview { HomeView() }
