//
//  CommunityView.swift
//  THESIS
//
//  Created by Ishaan Hari on 10/5/26.
//

import SwiftUI

struct CommunityView: View {
    var body: some View {
        ThesisScreen {
            TopBar(title: "Community")
        } content: {
            VStack(alignment: .leading, spacing: 0) {
                Tag("USEFUL ANALYSIS", tone: .green)
                Text("Think better, together.")
                    .font(Theme.display(26))
                    .padding(.top, 10)
                    .padding(.bottom, 5)
                Text("Explore ideas ranked by evidence and clarity—not hype or portfolio returns.")
                    .font(Theme.body(11))
                    .lineSpacing(3)
                    .foregroundStyle(Color(hex: 0xB5C4C1))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 22)
            .padding(.vertical, 28)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.ink)
            .fullBleed()

            ScrollView(.horizontal) {
                HStack(spacing: 7) {
                    TopicChip("For you", selected: true)
                    TopicChip("Beginner Investors")
                    TopicChip("AI & Semiconductors")
                }
            }
            .scrollIndicators(.hidden)
            .padding(.top, 16)
            .padding(.bottom, 24)

            PostCard(
                initials: "JL", author: "Jordan Lee", meta: "AI & Semiconductors · 22m", tag: "BEAR CASE", tone: .red,
                title: "Are we underestimating custom chips?",
                excerpt: "Cloud providers are NVIDIA’s biggest customers—and increasingly its competitors. Here are three data points I’m watching...",
                stats: ["42 useful", "18 counterarguments", "Save"]
            )
            PostCard(
                initials: "AM", author: "Aisha M.", meta: "Long-Term Investing · 1h", tag: "THESIS", tone: .blue,
                title: "My case for boring consistency",
                excerpt: "Why I chose a broad market ETF while I learn to evaluate individual companies.",
                stats: ["87 useful", "12 replies", "Save"]
            )
        } footer: {
            BottomNav(active: .community)
        }
    }
}

private struct PostCard: View {
    let initials: String
    let author: String
    let meta: String
    let tag: String
    let tone: TagTone
    let title: String
    let excerpt: String
    let stats: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 9) {
                Avatar(initials, small: true)
                VStack(alignment: .leading, spacing: 1) {
                    Text(author).font(Theme.body(10, .bold))
                    Text(meta).font(Theme.body(8)).foregroundStyle(Theme.muted)
                }
                Spacer()
                Tag(tag, tone: tone)
            }
            Text(title)
                .font(Theme.display(15))
                .padding(.top, 14)
                .padding(.bottom, 6)
            Text(excerpt)
                .font(Theme.body(10))
                .lineSpacing(3)
                .foregroundStyle(Theme.muted)
                .padding(.bottom, 12)
            HStack(spacing: 18) {
                ForEach(stats, id: \.self) { stat in
                    Button {} label: { Text(stat) }
                }
            }
            .font(Theme.body(9))
            .foregroundStyle(Theme.green)
            .padding(.top, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .topDivider()
        }
        .padding(15)
        .card(radius: 14)
        .padding(.bottom, 12)
    }
}

#Preview { CommunityView() }
