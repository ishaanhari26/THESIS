import SwiftUI

/// DEV ONLY — not app navigation. A list of every screen so you can click through the
/// port on a device or simulator. Screens open as sheets (swipe down or tap the back
/// chevron to close). The real app now starts at AppRootView (App/Navigation).
///
/// Use it by setting your ContentView's body to `ScreenGallery()`.
struct ScreenGallery: View {
    private enum Entry: String, CaseIterable, Identifiable {
        case home = "Home"
        case discover = "Discover"
        case stock = "Stock detail"
        case coach = "THESIS Coach"
        case thesis = "Investment thesis"
        case trade = "Trade"
        case tradeShort = "Trade – needs funding"
        case funding = "Add money"
        case fundingDone = "Add money – confirmed"
        case risk = "Risk preview"
        case review = "Review order"
        case success = "Order filled"
        case portfolio = "Portfolio"
        case learnEducation = "Learn – Education"
        case learnCoach = "Learn – Coach"
        case learnSim = "Learn – StockSim"
        case library = "Video library"
        case moneyHub = "Money Hub"
        case send = "Send money"
        case sendDone = "Send money – sent"
        case moneyCoach = "Money Coach"
        case community = "Community"

        var id: String { rawValue }

        @ViewBuilder var view: some View {
            switch self {
            case .home: HomeView()
            case .discover: DiscoverView()
            case .stock: StockView()
            case .coach: CoachView()
            case .thesis: ThesisView()
            case .trade: TradeView()
            case .tradeShort: TradeView(amount: "40")
            case .funding: FundingView()
            case .fundingDone: FundingView(confirmed: true)
            case .risk: RiskView()
            case .review: ReviewView()
            case .success: SuccessView()
            case .portfolio: PortfolioView()
            case .learnEducation: LearnView()
            case .learnCoach: LearnView(section: .coach)
            case .learnSim: LearnView(section: .stockSim)
            case .library: VideoLibraryView()
            case .moneyHub: MoneyHubView()
            case .send: SendMoneyView()
            case .sendDone: SendMoneyView(sent: true)
            case .moneyCoach: MoneyCoachView()
            case .community: CommunityView()
            }
        }
    }

    @State private var presented: Entry?

    var body: some View {
        NavigationStack {
            List(Entry.allCases) { entry in
                Button(entry.rawValue) { presented = entry }
                    .foregroundStyle(Theme.ink)
            }
            .navigationTitle("THESIS screens")
        }
        .sheet(item: $presented) { entry in
            entry.view
                .presentationDragIndicator(.visible)
        }
        .preferredColorScheme(.light)
    }
}

#Preview { ScreenGallery() }
