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
            let maxTagWidth = max(.zero, proxy.size.width - horizontalSpacing)

            WrappingTagList(
                items: items,
                horizontalSpacing: horizontalSpacing,
                verticalSpacing: verticalSpacing,
                maxTagWidth: maxTagWidth,
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
    let maxTagWidth: CGFloat
    let content: (Item) -> Content

    var body: some View {
        WrappingLayout(
            horizontalSpacing: horizontalSpacing,
            verticalSpacing: verticalSpacing
        ) {
            ForEach(items, id: \.self) { item in
                content(item)
                    .frame(maxWidth: maxTagWidth, alignment: .leading)
            }
        }
    }
}

private struct WrappingLayout: Layout {
    let horizontalSpacing: CGFloat
    let verticalSpacing: CGFloat

    struct Cache {}

    private struct Row {
        var indices: [Int] = []
        var width: CGFloat = 0
        var height: CGFloat = 0
    }

    func makeCache(subviews: Subviews) -> Cache { Cache() }
    func updateCache(_ cache: inout Cache, subviews: Subviews) {}

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Cache
    ) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        let rows = rows(for: subviews, maxWidth: maxWidth)
        let contentWidth = rows.map(\.width).max() ?? 0
        let contentHeight =
            rows.reduce(CGFloat.zero) { partialResult, row in
                partialResult + row.height
            } + verticalSpacing * CGFloat(max(0, rows.count - 1))

        return CGSize(width: proposal.width ?? contentWidth, height: contentHeight)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Cache
    ) {
        let rows = rows(for: subviews, maxWidth: bounds.width)
        var y = bounds.minY

        for row in rows {
            var x = bounds.minX

            for (position, index) in row.indices.enumerated() {
                let size = subviews[index].sizeThatFits(.unspecified)
                if position > 0 {
                    x += horizontalSpacing
                }

                subviews[index]
                    .place(
                        at: CGPoint(x: x, y: y),
                        proposal: ProposedViewSize(width: size.width, height: size.height)
                    )
                x += size.width
            }

            y += row.height + verticalSpacing
        }
    }

    private func rows(for subviews: Subviews, maxWidth: CGFloat) -> [Row] {
        guard !subviews.isEmpty else {
            return []
        }

        var rows: [Row] = []
        var currentRow = Row()

        for index in subviews.indices {
            let size = subviews[index].sizeThatFits(.unspecified)
            let spacing = currentRow.indices.isEmpty ? 0 : horizontalSpacing
            let proposedWidth = currentRow.width + spacing + size.width

            if !currentRow.indices.isEmpty && proposedWidth > maxWidth {
                rows.append(currentRow)
                currentRow = Row()
            }

            let nextSpacing = currentRow.indices.isEmpty ? 0 : horizontalSpacing
            currentRow.indices.append(index)
            currentRow.width += nextSpacing + size.width
            currentRow.height = max(currentRow.height, size.height)
        }

        rows.append(currentRow)
        return rows
    }
}
