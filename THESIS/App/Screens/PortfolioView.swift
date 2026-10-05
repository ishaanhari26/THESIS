import SwiftUI

struct PortfolioView: View {
    @State private var tab = "Investments"

    var body: some View {
        ThesisScreen {
            TopBar(title: "Portfolio") { IconButton(.wallet) } // → wallet
        } content: {
            VStack(spacing: 4) {
                Text("Total value").font(Theme.body(10)).foregroundStyle(Theme.muted)
                Text("$1,284.62").font(Theme.display(31))
                HStack(spacing: 2) {
                    Icon(.up, size: 13)
                    Text("$84.20 (7.01%) all time")
                }
                .font(Theme.body(10))
                .foregroundStyle(Theme.green2)
                PriceChart(height: 100).padding(.top, 11)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 15)

            portfolioTabs

            HStack {
                MoneyFigure(label: "Invested", value: "$1,267.44")
                MoneyFigure(label: "Available cash", value: "$17.18")
                Spacer()
                Button {} label: {
                    Icon(.arrow)
                        .foregroundStyle(Theme.green)
                        .frame(width: 30, height: 30)
                        .background(Circle().fill(.white))
                }
            }
            .padding(13)
            .background(Theme.pale, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .padding(.top, 17)

            SectionHeading("Your positions", action: "Sort")

            PositionRow(
                icon: AnyView(StockLogo(size: .small)), name: "NVIDIA", shares: "0.2056 shares", value: "$25.00", change: "+0.04%", isNew: true
            ) // → stock
            PositionRow(icon: AnyView(TickerIcon(ticker: "VOO")), name: "Vanguard S&P 500 ETF", shares: "1.24 shares", value: "$653.24", change: "+8.10%")
                .padding(.top, 4)
            PositionRow(icon: AnyView(TickerIcon(ticker: "AAPL")), name: "Apple", shares: "1.76 shares", value: "$376.82", change: "+4.28%")

            SectionHeading("Saved thesis", action: "View all")
            savedThesis
        } footer: {
            BottomNav(active: .portfolio)
        }
    }

    private var portfolioTabs: some View {
        HStack(spacing: 0) {
            ForEach(["Investments", "Theses"], id: \.self) { item in
                let active = item == tab
                Button { tab = item } label: {
                    HStack(spacing: 4) {
                        Text(item)
                        if item == "Theses" {
                            Text("1")
                                .padding(.horizontal, 5)
                                .padding(.vertical, 1)
                                .background(Capsule().fill(Color(hex: 0xE3EEEA)))
                        }
                    }
                    .font(Theme.body(10, active ? .bold : .regular))
                    .foregroundStyle(active ? Theme.green : Theme.muted)
                    .frame(maxWidth: .infinity)
                    .padding(11)
                    .overlay(alignment: .bottom) {
                        if active {
                            GeometryReader { geo in
                                Rectangle().fill(Theme.green)
                                    .frame(width: geo.size.width / 2, height: 2)
                                    .frame(maxWidth: .infinity)
                            }
                            .frame(height: 2)
                        }
                    }
                    .contentShape(Rectangle())
                }
            }
        }
        .overlay(alignment: .bottom) { Rectangle().fill(Theme.line).frame(height: 1) }
    }

    private var savedThesis: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 9) {
                StockLogo(size: .small)
                VStack(alignment: .leading, spacing: 3) {
                    Text("NVIDIA thesis").font(Theme.body(11, .bold))
                    Text("Created today · 1–3 years").font(Theme.body(8)).foregroundStyle(Theme.muted)
                }
                Spacer()
                Tag("ACTIVE", tone: .green)
            }

            Text("“AI infrastructure spending will continue growing, and NVIDIA is positioned to capture…”")
                .font(Theme.body(10))
                .lineSpacing(4)
                .foregroundStyle(Color(hex: 0x53635F))
                .padding(.leading, 11)
                .overlay(alignment: .leading) { Rectangle().fill(Theme.green).frame(width: 2) }
                .padding(.vertical, 14)

            HStack {
                Text("Next check-in").foregroundStyle(Theme.muted)
                Spacer()
                Text("After earnings · May 28").bold()
            }
            .font(Theme.body(9))
            .padding(.top, 10)
            .topDivider()
        }
        .padding(14)
        .card(radius: 14)
    }
}

private struct MoneyFigure: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(Theme.body(8)).foregroundStyle(Theme.muted)
            Text(value).font(Theme.body(11, .bold))
        }
        .frame(width: 130, alignment: .leading)
    }
}

private struct PositionRow: View {
    let icon: AnyView
    let name: String
    let shares: String
    let value: String
    let change: String
    var isNew = false

    var body: some View {
        Button {} label: {
            HStack(spacing: 10) {
                icon
                VStack(alignment: .leading, spacing: 3) {
                    Text(name).font(Theme.display(11))
                    Text(shares).font(Theme.body(9)).foregroundStyle(Theme.muted)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 3) {
                    Text(value).font(Theme.display(13))
                    Text(change).font(Theme.body(10)).foregroundStyle(Theme.green2)
                }
            }
            .padding(isNew ? 13 : 0)
            .padding(.vertical, isNew ? 0 : 14)
            .background {
                if isNew {
                    RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color(hex: 0xF0F6F3))
                }
            }
            .overlay {
                if isNew {
                    RoundedRectangle(cornerRadius: 12, style: .continuous).strokeBorder(Color(hex: 0xC9DED7))
                }
            }
            .overlay(alignment: .topTrailing) {
                if isNew {
                    Text("NEW")
                        .font(Theme.body(7, .heavy))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Theme.green, in: RoundedRectangle(cornerRadius: 5))
                        .offset(x: -10, y: -6)
                }
            }
            .rowDivider(!isNew, color: Theme.line)
            .contentShape(Rectangle())
        }
    }
}

#Preview { PortfolioView() }
