import SwiftUI

/// App-wide navigation state: which bottom-nav tab is showing, plus a separate
/// navigation stack per tab so each tab remembers where you were.
@Observable
final class AppRouter {
    var selectedTab: AppTab = .home
    var paths: [AppTab: NavigationPath] = Dictionary(
        uniqueKeysWithValues: AppTab.allCases.map { ($0, NavigationPath()) }
    )

    /// Bottom-nav tap. Switches tabs, or pops back to the tab's root screen if it's
    /// already the one showing (standard iOS tab bar behavior).
    func select(_ tab: AppTab) {
        if tab == selectedTab {
            paths[tab] = NavigationPath()
        } else {
            selectedTab = tab
        }
    }

    func path(for tab: AppTab) -> Binding<NavigationPath> {
        Binding(
            get: { self.paths[tab] ?? NavigationPath() },
            set: { self.paths[tab] = $0 }
        )
    }
}

extension AppTab {
    /// The screen each bottom-nav tab opens to.
    @ViewBuilder var rootView: some View {
        switch self {
        case .home: HomeView()
        case .moneyHub: MoneyHubView()
        case .learn: LearnView()
        case .community: CommunityView()
        case .portfolio: PortfolioView()
        }
    }
}

/// Root of the app. All five tabs stay alive (only the selected one is visible) so
/// switching tabs keeps each screen's scroll position and state. The tab bar itself
/// is the `BottomNav` each screen already draws in its footer; it talks to the
/// router through the environment.
struct AppRootView: View {
    @State private var router = AppRouter()

    var body: some View {
        ZStack {
            ForEach(AppTab.allCases, id: \.self) { tab in
                let isSelected = tab == router.selectedTab
                NavigationStack(path: router.path(for: tab)) {
                    tab.rootView
                }
                .opacity(isSelected ? 1 : 0)
                .allowsHitTesting(isSelected)
                .accessibilityHidden(!isSelected)
                .zIndex(isSelected ? 1 : 0)
            }
        }
        .environment(router)
        .preferredColorScheme(.light)
    }
}

#Preview { AppRootView() }
