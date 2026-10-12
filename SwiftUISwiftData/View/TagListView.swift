//
//  TagListView.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/10.
//

import SwiftUI

struct TagListView<Item: Hashable, Content: View>: View {
    private let items: [Item]
    private let horizontalSpacing: CGFloat
    private let verticalSpacing: CGFloat
    private let content: (Item) -> Content
    private let viewHeight: (CGFloat) -> Void

    init(
        items: [Item],
        horizontalSpacing: CGFloat = 8,
        verticalSpacing: CGFloat = 8,
        content: @escaping (Item) -> Content,
        viewHeight: @escaping (CGFloat) -> Void
    ) {
        self.items = items
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
        self.content = content
        self.viewHeight = viewHeight
    }

    var body: some View {
        GeometryReader { proxy in
            WrappingTagList(
                items: items,
                horizontalSpacing: horizontalSpacing,
                verticalSpacing: verticalSpacing,
                content: content
            )
            .frame(width: proxy.size.width, alignment: .leading)
            .background(
                GeometryReader { innerProxy in
                    Color.clear
                        .onAppear {
                            viewHeight(innerProxy.size.height)
                        }
                        .onChange(of: innerProxy.size.height) { _, newValue in
                            viewHeight(newValue)
                        }
                }
            )
        }
    }
}

private struct WrappingTagList<Item: Hashable, Content: View>: View {
    let items: [Item]
    let horizontalSpacing: CGFloat
    let verticalSpacing: CGFloat
    let content: (Item) -> Content

    var body: some View {
        WrappingLayout(
            horizontalSpacing: horizontalSpacing,
            verticalSpacing: verticalSpacing
        ) {
            ForEach(items, id: \.self) { item in
                content(item)
            }
        }
    }
}

private struct WrappingLayout: Layout {
    let horizontalSpacing: CGFloat
    let verticalSpacing: CGFloat

    struct Cache {}

    func makeCache(subviews: Subviews) -> Cache { Cache() }
    func updateCache(_ cache: inout Cache, subviews: Subviews) {}

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Cache
    ) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            let isFirstInRow = x == 0
            let spacingBefore = isFirstInRow ? 0 : horizontalSpacing

            if !isFirstInRow && x + spacingBefore + size.width > maxWidth {
                x = 0
                y += rowHeight + verticalSpacing
                rowHeight = 0
            }

            let currentSpacing = (x == 0) ? 0 : horizontalSpacing
            x += currentSpacing + size.width
            rowHeight = max(rowHeight, size.height)
        }

        return CGSize(width: proposal.width ?? x, height: y + rowHeight)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Cache
    ) {
        let maxWidth = bounds.width
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            let isFirstInRow = x == 0
            let spacingBefore = isFirstInRow ? 0 : horizontalSpacing

            if !isFirstInRow && x + spacingBefore + size.width > maxWidth {
                x = 0
                y += rowHeight + verticalSpacing
                rowHeight = 0
            }

            let placeSpacing = (x == 0) ? 0 : horizontalSpacing
            let placeX = bounds.minX + x + placeSpacing

            subview.place(
                at: CGPoint(x: placeX, y: bounds.minY + y),
                proposal: ProposedViewSize(width: size.width, height: size.height)
            )

            x += placeSpacing + size.width
            rowHeight = max(rowHeight, size.height)
        }
    }
}
