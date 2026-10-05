import SwiftUI

// MARK: - Screen scaffold

/// Every screen: pinned top bar, scrolling content with 20pt side padding, optional pinned footer.
struct ThesisScreen<Top: View, Content: View, Footer: View>: View {
    var background: Color
    var horizontalPadding: CGFloat
    let top: Top
    let content: Content
    let footer: Footer

    init(
        background: Color = Theme.paper,
        horizontalPadding: CGFloat = 20,
        @ViewBuilder top: () -> Top,
        @ViewBuilder content: () -> Content,
        @ViewBuilder footer: () -> Footer
    ) {
        self.background = background
        self.horizontalPadding = horizontalPadding
        self.top = top()
        self.content = content()
        self.footer = footer()
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                content
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.bottom, 28)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.interactively)
        .background(background.ignoresSafeArea())
        .safeAreaInset(edge: .top, spacing: 0) { top }
        .safeAreaInset(edge: .bottom, spacing: 0) { footer }
        .foregroundStyle(Theme.ink)
        .buttonStyle(.plain)
        .toolbar(.hidden, for: .navigationBar)
    }
}

extension ThesisScreen where Footer == EmptyView {
    init(
        background: Color = Theme.paper,
        horizontalPadding: CGFloat = 20,
        @ViewBuilder top: () -> Top,
        @ViewBuilder content: () -> Content
    ) {
        self.init(background: background, horizontalPadding: horizontalPadding, top: top, content: content, footer: { EmptyView() })
    }
}

// MARK: - Top bar

struct TopBar<Trailing: View>: View {
    var title: String?
    var showsBack: Bool
    let trailing: Trailing

    @Environment(\.dismiss) private var dismiss

    init(title: String? = nil, showsBack: Bool = false, @ViewBuilder trailing: () -> Trailing) {
        self.title = title
        self.showsBack = showsBack
        self.trailing = trailing()
    }

    var body: some View {
        ZStack {
            HStack {
                if showsBack {
                    // dismiss() is a no-op unless the screen was pushed (e.g. from ScreenGallery).
                    IconButton(.back) { dismiss() }
                        .accessibilityLabel("Go back")
                } else {
                    LogoView()
                }
                Spacer()
                HStack(spacing: 4) { trailing }
                    .frame(minWidth: 34, alignment: .trailing)
            }
            if let title {
                Text(title)
                    .font(Theme.display(15))
                    .lineLimit(1)
            }
        }
        .frame(height: 66)
        .padding(.horizontal, 18)
        .background(Theme.paper.opacity(0.95))
        .foregroundStyle(Theme.ink)
        .buttonStyle(.plain)
    }
}

extension TopBar where Trailing == DefaultTopBarTrailing {
    init(title: String? = nil, showsBack: Bool = false) {
        self.init(title: title, showsBack: showsBack) { DefaultTopBarTrailing(showsBack: showsBack) }
    }
}

/// Bell with an unread dot on root screens; empty spacer on pushed screens.
struct DefaultTopBarTrailing: View {
    let showsBack: Bool

    var body: some View {
        if showsBack {
            Color.clear.frame(width: 34, height: 34)
        } else {
            IconButton(.bell) {}
                .overlay(alignment: .topTrailing) {
                    Circle()
                        .fill(Color(hex: 0xD48B4D))
                        .frame(width: 6, height: 6)
                        .overlay(Circle().stroke(.white, lineWidth: 1))
                        .offset(x: -7, y: 6)
                }
                .accessibilityLabel("Notifications")
        }
    }
}

struct IconButton: View {
    let icon: ThesisIcon
    var action: () -> Void

    init(_ icon: ThesisIcon, action: @escaping () -> Void = {}) {
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Icon(icon)
                .frame(width: 36, height: 36)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

struct TextAction: View {
    let title: String
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Theme.body(10, .bold))
                .foregroundStyle(Theme.green)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Logo

struct LogoView: View {
    var body: some View {
        HStack(spacing: 9) {
            UnevenRoundedRectangle(topLeadingRadius: 12, bottomLeadingRadius: 3, bottomTrailingRadius: 12, topTrailingRadius: 12)
                .stroke(Theme.green, lineWidth: 1.8)
                .frame(width: 24, height: 24)
                .overlay(Circle().fill(Theme.green).frame(width: 8, height: 8))
                .rotationEffect(.degrees(-45))
            Text("THESIS")
                .font(Theme.display(14, .heavy))
                .tracking(Theme.tracking(0.16, 14))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("THESIS")
    }
}

// MARK: - Bottom navigation

enum AppTab: String, CaseIterable {
    case home = "Home"
    case moneyHub = "Money Hub"
    case learn = "Learn"
    case community = "Community"
    case portfolio = "Portfolio"

    var icon: ThesisIcon {
        switch self {
        case .home: .home
        case .moneyHub: .wallet
        case .learn: .play
        case .community: .users
        case .portfolio: .pie
        }
    }
}

/// Visual-only tab bar matching the prototype. Later you can keep this as a custom
/// tab bar or swap it for TabView.
struct BottomNav: View {
    let active: AppTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                let isActive = tab == active
                Button {} label: {
                    VStack(spacing: 3) {
                        Icon(tab.icon, size: 21, weight: isActive ? .semibold : .regular)
                        Text(tab.rawValue)
                            .font(Theme.body(10, isActive ? .bold : .regular))
                    }
                    .foregroundStyle(isActive ? Theme.green : Color(hex: 0x83908E))
                    .frame(maxWidth: .infinity)
                    .padding(.top, 12)
                    .padding(.bottom, 6)
                    .overlay(alignment: .top) {
                        if isActive {
                            Rectangle().fill(Theme.green).frame(width: 26, height: 2)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .background(Theme.paper.opacity(0.96).ignoresSafeArea(edges: .bottom))
        .background(.ultraThinMaterial)
        .topDivider()
    }
}

// MARK: - Footers & buttons

/// Pinned bottom action area (trade-dock / sticky-single / action-stack in the CSS).
struct StickyFooter<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) { content }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 12)
            .frame(maxWidth: .infinity)
            .background(Theme.paper.opacity(0.96).ignoresSafeArea(edges: .bottom))
            .background(.ultraThinMaterial)
            .topDivider()
            .foregroundStyle(Theme.ink)
            .buttonStyle(.plain)
    }
}

struct PrimaryButton: View {
    let title: String
    var showsArrow = true
    var capsule = false
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(title)
                if showsArrow { Icon(.arrow, size: 18) }
            }
            .font(Theme.body(13, .bold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(Theme.green, in: RoundedRectangle(cornerRadius: capsule ? 24 : 12, style: .continuous))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct SecondaryButton: View {
    let title: String
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Theme.body(13, .bold))
                .foregroundStyle(Theme.green)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .card(radius: 12, fill: .white, stroke: Theme.green)
        }
        .buttonStyle(.plain)
    }
}

/// Green inline link with trailing arrow ("Understand the move →").
struct TextLink: View {
    let title: String
    var size: CGFloat = 12
    var icon: ThesisIcon = .arrow
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Text(title)
                Icon(icon, size: Theme.scaled(size) + 3)
            }
            .font(Theme.body(size, .bold))
            .foregroundStyle(Theme.green)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Labels

enum TagTone {
    case neutral, green, red, gold, blue

    var background: Color {
        switch self {
        case .neutral: Color(hex: 0xEEF2F1)
        case .green: Color(hex: 0xE0F0EB)
        case .red: Color(hex: 0xF8E6E3)
        case .gold: Color(hex: 0xF8EDD8)
        case .blue: Color(hex: 0xE5EDF3)
        }
    }

    var foreground: Color {
        switch self {
        case .neutral: Color(hex: 0x60706D)
        case .green: Theme.green
        case .red: Color(hex: 0xA6504B)
        case .gold: Theme.goldText
        case .blue: Color(hex: 0x496C82)
        }
    }
}

struct Tag: View {
    let text: String
    var tone: TagTone = .neutral
    var size: CGFloat = 9

    init(_ text: String, tone: TagTone = .neutral, size: CGFloat = 9) {
        self.text = text
        self.tone = tone
        self.size = size
    }

    var body: some View {
        Text(text)
            .font(Theme.body(size, .bold))
            .tracking(Theme.tracking(0.06, size))
            .foregroundStyle(tone.foreground)
            .padding(.horizontal, size < 8 ? 4 : 7)
            .padding(.vertical, size < 8 ? 2 : 4)
            .background(tone.background, in: RoundedRectangle(cornerRadius: 5, style: .continuous))
            .fixedSize()
    }
}

/// Pill used in horizontal topic rows ("Trending", "Technology", ...).
struct TopicChip: View {
    let text: String
    var selected = false

    init(_ text: String, selected: Bool = false) {
        self.text = text
        self.selected = selected
    }

    var body: some View {
        Text(text)
            .font(Theme.body(10, .bold))
            .foregroundStyle(selected ? .white : Color(hex: 0x60706D))
            .padding(.horizontal, 11)
            .padding(.vertical, 7)
            .background(Capsule().fill(selected ? Theme.green : .white))
            .overlay(Capsule().strokeBorder(selected ? Theme.green : Theme.line))
            .fixedSize()
    }
}

/// Small all-caps label above headings.
struct Eyebrow: View {
    let text: String
    var color: Color = Theme.green
    var size: CGFloat = 9
    var trackingEm: CGFloat = 0.08

    init(_ text: String, color: Color = Theme.green, size: CGFloat = 9, trackingEm: CGFloat = 0.08) {
        self.text = text
        self.color = color
        self.size = size
        self.trackingEm = trackingEm
    }

    var body: some View {
        Text(text)
            .font(Theme.body(size, .heavy))
            .tracking(Theme.tracking(trackingEm, size))
            .foregroundStyle(color)
    }
}

struct SectionHeading: View {
    let title: String
    var action: String?
    var topPadding: CGFloat = 28
    var bottomPadding: CGFloat = 12

    init(_ title: String, action: String? = nil, topPadding: CGFloat = 28, bottomPadding: CGFloat = 12) {
        self.title = title
        self.action = action
        self.topPadding = topPadding
        self.bottomPadding = bottomPadding
    }

    var body: some View {
        HStack {
            Text(title)
                .font(Theme.display(17))
                .tracking(Theme.tracking(-0.02, 17))
            Spacer()
            if let action {
                Button {} label: {
                    Text(action)
                        .font(Theme.body(12, .semibold))
                        .foregroundStyle(Theme.green)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, topPadding)
        .padding(.bottom, bottomPadding)
    }
}

/// Large section title without an action (CSS .page-section-title).
struct PageSectionTitle: View {
    let title: String

    init(_ title: String) { self.title = title }

    var body: some View {
        Text(title)
            .font(Theme.display(17))
            .tracking(Theme.tracking(-0.02, 17))
            .padding(.top, 24)
            .padding(.bottom, 12)
    }
}

// MARK: - Badges, logos, avatars

struct Avatar: View {
    let initials: String
    var small = false

    init(_ initials: String, small: Bool = false) {
        self.initials = initials
        self.small = small
    }

    var body: some View {
        Text(initials)
            .font(Theme.body(12, .bold))
            .foregroundStyle(.white)
            .frame(width: small ? 34 : 42, height: small ? 34 : 42)
            .background(Circle().fill(Color(hex: 0xD5A87B)))
            .overlay(Circle().strokeBorder(Color(hex: 0xF0DED0), lineWidth: small ? 2 : 3))
    }
}

/// The green "N" NVIDIA mark.
struct StockLogo: View {
    enum Size { case small, regular, large }
    var size: Size = .regular

    private var spec: (side: CGFloat, radius: CGFloat, font: CGFloat) {
        switch size {
        case .small: (40, 11, 19)
        case .regular: (50, 13, 24)
        case .large: (65, 17, 29)
        }
    }

    var body: some View {
        Text("N")
            .font(.custom("Manrope", size: spec.font).weight(.heavy))
            .foregroundStyle(.white)
            .frame(width: spec.side, height: spec.side)
            .background(Color(hex: 0x74AA3D), in: RoundedRectangle(cornerRadius: spec.radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: spec.radius, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.21), lineWidth: 1)
            )
    }
}

/// Rounded square with a ticker's first letter.
struct TickerIcon: View {
    let ticker: String
    var side: CGFloat = 34
    var radius: CGFloat = 9

    private var colors: (bg: Color, fg: Color) {
        switch ticker.uppercased() {
        case "AAPL": (Color(hex: 0x1D2524), .white)
        case "NVDA": (Color(hex: 0x75A943), .white)
        case "TSLA": (Color(hex: 0xE84035), .white)
        case "PLTR": (Color(hex: 0x111111), .white)
        case "AMD": (Color(hex: 0x222222), .white)
        default: (Color(hex: 0xEDF0EF), Theme.ink)
        }
    }

    var body: some View {
        Text(String(ticker.prefix(1)))
            .font(Theme.body(13, .heavy))
            .foregroundStyle(colors.fg)
            .frame(width: side, height: side)
            .background(colors.bg, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
    }
}

/// Venmo / PayPal / Chase / Zelle style letter mark.
struct PaymentLogo: View {
    let letter: String
    let color: Color
    var side: CGFloat = 38
    var radius: CGFloat = 9
    var fontSize: CGFloat = 17

    var body: some View {
        Text(letter)
            .font(.custom("Manrope", size: Theme.scaled(fontSize)).weight(.heavy))
            .foregroundStyle(.white)
            .frame(width: side, height: side)
            .background(color, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
    }
}

struct BankMark: View {
    let color: Color
    var side: CGFloat = 36
    var iconSize: CGFloat = 20

    var body: some View {
        Icon(.bank, size: iconSize)
            .foregroundStyle(.white)
            .frame(width: side, height: side)
            .background(color, in: RoundedRectangle(cornerRadius: 9, style: .continuous))
    }
}

/// Green circle with a sparkle — the Coach's avatar.
struct CoachOrb: View {
    var side: CGFloat = 48
    var halo: CGFloat = 7
    var iconSize: CGFloat = 20

    var body: some View {
        Icon(.spark, size: iconSize)
            .foregroundStyle(Color(hex: 0xD6EFE8))
            .frame(width: side, height: side)
            .background(Circle().fill(Theme.green))
            .background(Circle().fill(Color(hex: 0xE4F1ED)).padding(-halo))
            .padding(halo)
    }
}

/// Square tinted icon tile used across cards.
struct IconTile: View {
    let icon: ThesisIcon
    var side: CGFloat = 30
    var radius: CGFloat = 8
    var iconSize: CGFloat = 16
    var foreground: Color = Theme.green
    var background: Color = Theme.pale

    var body: some View {
        Icon(icon, size: iconSize)
            .foregroundStyle(foreground)
            .frame(width: side, height: side)
            .background(background, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
    }
}

/// Selection radio used in method lists.
struct RadioDot: View {
    let selected: Bool

    var body: some View {
        Circle()
            .strokeBorder(selected ? Theme.green : Color(hex: 0xAAB6B3), lineWidth: selected ? 5 : 1)
            .frame(width: 16, height: 16)
    }
}

// MARK: - Rows

/// Label on the left, value on the right.
struct KVRow: View {
    let label: String
    let value: String
    var size: CGFloat = 10
    var valueSize: CGFloat?
    var valueColor: Color = Theme.ink
    var valueWeight: Font.Weight = .bold
    var verticalPadding: CGFloat = 11
    var showsDivider = false

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .foregroundStyle(Theme.muted)
            Spacer(minLength: 12)
            Text(value)
                .font(Theme.body(valueSize ?? size, valueWeight))
                .foregroundStyle(valueColor)
                .multilineTextAlignment(.trailing)
        }
        .font(Theme.body(size))
        .padding(.vertical, verticalPadding)
        .rowDivider(showsDivider)
    }
}

/// White rounded container for stacked rows (CSS .watch-list and friends).
struct ListCard<Content: View>: View {
    var horizontalPadding: CGFloat = 14
    var radius: CGFloat = 15
    let content: Content

    init(horizontalPadding: CGFloat = 14, radius: CGFloat = 15, @ViewBuilder content: () -> Content) {
        self.horizontalPadding = horizontalPadding
        self.radius = radius
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) { content }
            .padding(.horizontal, horizontalPadding)
            .card(radius: radius)
    }
}

struct StockRow: View {
    let ticker: String
    let name: String
    let price: String
    let change: String
    var down = false
    var showsDivider = true

    var body: some View {
        Button {} label: {
            HStack(spacing: 10) {
                TickerIcon(ticker: ticker)
                VStack(alignment: .leading, spacing: 2) {
                    Text(ticker).font(Theme.body(12, .bold))
                    Text(name).font(Theme.body(10)).foregroundStyle(Theme.muted)
                }
                .frame(width: 76, alignment: .leading)
                Spacer(minLength: 0)
                Sparkline(down: down)
                VStack(alignment: .trailing, spacing: 2) {
                    Text(price).font(Theme.body(12, .bold))
                    Text(change).font(Theme.body(10)).foregroundStyle(down ? Theme.red : Theme.green2)
                }
                .frame(minWidth: 64, alignment: .trailing)
            }
            .padding(.vertical, 13)
            .rowDivider(showsDivider)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

/// Non-interactive search field look (search-box).
struct SearchBoxLabel: View {
    let placeholder: String

    var body: some View {
        HStack(spacing: 10) {
            Icon(.search)
            Text(placeholder)
            Spacer()
        }
        .font(Theme.body(12))
        .foregroundStyle(Color(hex: 0x899592))
        .padding(.horizontal, 14)
        .frame(height: 46)
        .card(radius: 12)
    }
}

/// Real text field with the same look (learn-search-box).
struct SearchField: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        HStack(spacing: 9) {
            Icon(.search, size: 18).foregroundStyle(Theme.muted)
            TextField(placeholder, text: $text)
                .font(Theme.body(10))
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            if !text.isEmpty {
                Button("Clear") { text = "" }
                    .font(Theme.body(8, .bold))
                    .foregroundStyle(Theme.green)
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 46)
        .card(radius: 12)
    }
}

/// Grey track with a white sliding selection (segmented / period-toggle / learn-tabs).
struct SegmentedPills<Option: Hashable>: View {
    let options: [Option]
    @Binding var selection: Option
    var height: CGFloat = 34
    var fontSize: CGFloat = 11
    var activeColor: Color = Theme.ink
    var inactiveColor: Color = Theme.ink
    let label: (Option) -> AnyView

    var body: some View {
        HStack(spacing: 0) {
            ForEach(options, id: \.self) { option in
                let active = option == selection
                Button {
                    withAnimation(.snappy(duration: 0.2)) { selection = option }
                } label: {
                    label(option)
                        .font(Theme.body(fontSize, active ? .bold : .regular))
                        .foregroundStyle(active ? activeColor : inactiveColor)
                        .frame(maxWidth: .infinity)
                        .frame(height: height)
                        .background {
                            if active {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(.white)
                                    .shadow(color: Color(hex: 0x273B35, alpha: 0.12), radius: 2, y: 1)
                            }
                        }
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(3)
        .background(Theme.segmentTrack, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

extension SegmentedPills where Option == String {
    init(_ options: [String], selection: Binding<String>, height: CGFloat = 34, fontSize: CGFloat = 11,
         activeColor: Color = Theme.ink, inactiveColor: Color = Theme.ink) {
        self.init(options: options, selection: selection, height: height, fontSize: fontSize,
                  activeColor: activeColor, inactiveColor: inactiveColor) { AnyView(Text($0)) }
    }
}

/// Underlined tab row (range-tabs / portfolio-tabs).
struct UnderlineTabs: View {
    let options: [String]
    @Binding var selection: String
    var stretch = false
    var fontSize: CGFloat = 10

    var body: some View {
        HStack(spacing: 0) {
            ForEach(options, id: \.self) { option in
                let active = option == selection
                Button { selection = option } label: {
                    Text(option)
                        .font(Theme.body(fontSize, active ? .bold : .regular))
                        .foregroundStyle(active ? Theme.green : Theme.muted)
                        .padding(.horizontal, 7)
                        .padding(.top, 9)
                        .padding(.bottom, 11)
                        .frame(maxWidth: stretch ? .infinity : nil)
                        .overlay(alignment: .bottom) {
                            if active { Rectangle().fill(Theme.green).frame(height: 2) }
                        }
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                if !stretch && option != options.last { Spacer(minLength: 0) }
            }
        }
        .overlay(alignment: .bottom) { Rectangle().fill(Theme.line).frame(height: 1) }
    }
}

/// Horizontal pill filters (transaction-filters / library-filters).
struct FilterPills: View {
    let options: [String]
    @Binding var selection: String
    var fontSize: CGFloat = 9

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 6) {
                ForEach(options, id: \.self) { option in
                    let active = option == selection
                    Button { selection = option } label: {
                        Text(option)
                            .font(Theme.body(fontSize))
                            .foregroundStyle(active ? .white : Theme.muted)
                            .padding(.horizontal, 11)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(active ? Theme.green : .white))
                            .overlay(Capsule().strokeBorder(active ? Theme.green : Theme.line))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
        }
        .scrollIndicators(.hidden)
        .fullBleed()
    }
}
